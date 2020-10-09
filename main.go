package main

import (
	"crypto/tls"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/NYTimes/gziphandler"
	"github.com/bradfitz/gomemcache/memcache"
	"github.com/gorilla/mux"
)

var configPath = flag.String("config", "./goroute.json", "Config File For Router")
var envFilePath = flag.String("env", "NONE", "Environment variables list file path")

var tLSVersion = map[string]uint16{
	"TLS 1.0": tls.VersionTLS10,
	"TLS 1.1": tls.VersionTLS11,
	"TLS 1.2": tls.VersionTLS12,
	"TLS 1.3": tls.VersionTLS13,
}

func main() {
	flag.Parse()
	fmt.Println("Changes Added")
	data, err := ioutil.ReadFile(*configPath)
	jsonContent := string(data)
	if err != nil {
		panic(fmt.Sprintf("Reading config file failed : %s", err.Error()))
	}
	if *envFilePath != "NONE" {
		log.Println("ENV File")
		env := map[string]string{}
		envBytes, err := ioutil.ReadFile(*envFilePath)
		if err != nil {
			panic(fmt.Sprintf("Reading env file failed : %s", err.Error()))
		}
		err = json.Unmarshal(envBytes, &env)
		if err != nil {
			panic(fmt.Sprintf("Unable to unmarshal content from env file : %s", err.Error()))
		}
		for k, v := range env {
			environmentValue := os.Getenv(v)
			log.Println("Replaces Env Value = ", "$"+k+"$", " = ", environmentValue)
			jsonContent = strings.Replace(jsonContent, "$"+k+"$", environmentValue, -1)
		}
		log.Println("Final Config Content = ", jsonContent)
	}
	config := Config{}
	err = json.Unmarshal([]byte(jsonContent), &config)
	if err != nil {
		panic(fmt.Sprintf("Unable to unmarshal content from conf file : %s", err.Error()))
	}
	err = StartRouter(config)
	if err != nil {
		panic(fmt.Sprintf("Unable to start router : %s", err.Error()))
	}
}

//StartRouter - start router
func StartRouter(config Config) error {
	r := mux.NewRouter()
	r.StrictSlash(false)

	// liveness probe
	r.HandleFunc("/health/live", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
	}).Methods("GET")

	// readiness probe
	r.HandleFunc("/health/ready", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
	}).Methods("GET")

	var cachingClient *memcache.Client
	if config.Cache.Enabled {
		cachingClient = GetCachingClient(config)
	}
	routes := config.Routes
	for _, route := range routes {
		if route.TargetType == "URL" {
			func(route Route) {
				wz := http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
					temp := route
					if strings.Split(req.RequestURI, "/")[1] != strings.Split(temp.Path, "/")[1] {
						http.NotFound(w, req)
					} else {
						log.Println("Request URL : ", req.RequestURI)
						headers := temp.Headers
						for k, v := range headers.Request {
							req.Header.Add(k, v)
						}
						url, _ := url.Parse(temp.Target)
						proxy := NewSingleHostReverseProxy(url)
						req.URL.Host = url.Host
						req.URL.Scheme = url.Scheme
						req.URL.Path = req.URL.Path[len(route.Path):len(req.URL.Path)]
						req.Header.Set("X-Forwarded-Host", req.Header.Get("Host"))
						req.Host = url.Host
						proxy.ServeHTTP(w, req, headers.Response)
					}
				})
				if config.Compression {
					r.PathPrefix(route.Path).Handler(gziphandler.GzipHandler(wz))
				} else {
					r.PathPrefix(route.Path).Handler(wz)
				}
			}(route)
		} else {
			func(route Route) {
				if config.Cache.Enabled {
					if config.Compression {
						r.PathPrefix(route.Path).Handler(gziphandler.GzipHandler(http.StripPrefix(route.Path, FileServerWithCache(Dir(route.Target), cachingClient, route.CacheExpiry, route.Headers))))
					} else {
						r.PathPrefix(route.Path).Handler(http.StripPrefix(route.Path, FileServerWithCache(Dir(route.Target), cachingClient, route.CacheExpiry, route.Headers)))
					}
				} else {
					if config.Compression {
						r.PathPrefix(route.Path).Handler(gziphandler.GzipHandler(http.StripPrefix(route.Path, FileServerWithCache(Dir(route.Target), nil, 0, route.Headers))))
					} else {
						r.PathPrefix(route.Path).Handler(http.StripPrefix(route.Path, FileServerWithCache(Dir(route.Target), nil, 0, route.Headers)))
					}
				}
			}(route)
		}
	}
	log.Println("Starting server at " + config.Host + ":" + config.Port)
	if config.Security.Enabled {
		cipherSuites := []uint16{
			tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,
			tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,
			tls.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,
			tls.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
			tls.TLS_RSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_RSA_WITH_AES_256_GCM_SHA384,
		}
		cfg := &tls.Config{
			MinVersion:               tLSVersion[config.Security.MinTLSVersion],
			MaxVersion:               tLSVersion[config.Security.MaxTLSVersion],
			InsecureSkipVerify:       true,
			CipherSuites:             cipherSuites,
			PreferServerCipherSuites: true,
		}
		srv := &http.Server{
			Addr:      config.Host + ":" + config.Port,
			Handler:   r,
			TLSConfig: cfg,
		}
		return srv.ListenAndServeTLS(config.Security.CertPath, config.Security.KeyPath)
	}
	return http.ListenAndServe(config.Host+":"+config.Port, r)
}

//GetCachingClient - get etcd caching client
func GetCachingClient(config Config) *memcache.Client {
	mc := memcache.New(config.Cache.EndPoint)
	return mc
}
