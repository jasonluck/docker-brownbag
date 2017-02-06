package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"

	"net/http"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

type config struct {
	dbUser     string
	dbPassword string
	dbHost     string
	dbPort     int
	dbName     string
}

/*
Guest of the docker brownbag
*/
type Guest struct {
	Firstname string `json:"firstname"`
	Lastname  string `json:"lastname"`
	Date      string `json:"time"`
}

/*
AllGuestResponse to request for all guests
*/
type AllGuestResponse struct {
	Guest []Guest `json:"guest"`
}

var version = "1.0.0"
var dbConfig config

func getDbConnection() (*sql.DB, error) {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		dbConfig.dbUser, dbConfig.dbPassword, dbConfig.dbHost,
		dbConfig.dbPort, dbConfig.dbName)
	db, err := sql.Open("mysql", connectionString)
	if err == nil {
		err = db.Ping()
	}

	return db, err
}

func getGuestList() ([]Guest, error) {
	db, err := getDbConnection()
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query("select date, first_name, last_name from registry")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	var guests []Guest
	for rows.Next() {
		var date string
		var firstName string
		var lastName string

		err = rows.Scan(&date, &firstName, &lastName)
		if err != nil {
			log.Fatal(err)
		}
		guest := Guest{
			Date:      date,
			Firstname: firstName,
			Lastname:  lastName,
		}
		guests = append(guests, guest)
	}

	return guests, err

}

func getGuestsEndpoint(w http.ResponseWriter, r *http.Request) {
	guests, err := getGuestList()
	response := AllGuestResponse{guests}
	statusCode := http.StatusOK
	if err != nil {
		log.Fatal(err)
		statusCode = http.StatusInternalServerError
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	data, err := json.MarshalIndent(&response, "", " ")
	if err != nil {
		log.Println(err)
	}
	w.Write(data)
}

func createGuestEndpoint(w http.ResponseWriter, r *http.Request) {
	guests, err := getGuestList()
	response := AllGuestResponse{guests}
	statusCode := http.StatusOK
	if err != nil {
		log.Fatal(err)
		statusCode = http.StatusInternalServerError
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	data, err := json.MarshalIndent(&response, "", " ")
	if err != nil {
		log.Println(err)
	}
	w.Write(data)
}

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

	dbConfig = config{
		dbHost:     dbHost,
		dbPort:     dbPort,
		dbUser:     dbUsername,
		dbPassword: dbPassword,
		dbName:     dbName,
	}
	if dbConfig.dbPort == 0 {
		dbConfig.dbPort = 3306
	}

	router := mux.NewRouter()
	router.HandleFunc("/guest", getGuestsEndpoint).Methods("GET")
	router.HandleFunc("/guest", createGuestEndpoint).Methods("POST")

	/* Default Handler */
	router.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, html, hostname, version)
	}).Methods("GET")

	/*
		Start the HTTP Server
	*/
	log.Printf("HTTP Service listening on %s", httpAddr)
	httpErr := http.ListenAndServe(httpAddr, router)
	if httpErr != nil {
		log.Fatal(httpErr)
	}

}
