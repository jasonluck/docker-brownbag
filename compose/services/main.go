package main

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"net/http"
)

var version = "1.0.0"

func main() {
	log.Println("Starting app...")

	/*
	   Configure the application here. This could include reading ENV variables, loading
	   a configuration files, etc.
	*/
	httpAddr := os.Getenv("HTTP_ADDR")
	dbHost := os.Getenv("DB_HOST")
	dbPort, err := strconv.Atoi(os.Getenv("DB_PORT"))
	dbUsername := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_DATABASE")

	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	/*
		Setup the /guest service handler
	*/
	hc := &Config{
		DbHost:     dbHost,
		DbPort:     dbPort,
		DbUser:     dbUsername,
		DbPassword: dbPassword,
		DbName:     dbName,
	}

	guestHandler, err := Handler(hc)
	if err != nil {
		log.Fatal(err)
	}

	http.Handle("/guest", guestHandler)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, html, hostname, version)
	})

	/*
		Create any additional service handlers here
		...
	*/

	/*
		Start the HTTP Server
	*/
	log.Printf("HTTP Service listening on %s", httpAddr)
	httpErr := http.ListenAndServe(httpAddr, nil)
	if httpErr != nil {
		log.Fatal(httpErr)
	}

}
