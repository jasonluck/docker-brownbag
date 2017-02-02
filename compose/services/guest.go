package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
)

/*
Config for the handler
*/
type Config struct {
	DbUser     string //Database user
	DbPassword string //Database password
	DbHost     string //Database host
	DbPort     int    //Database port
	DbName     string //Database name
}

type handler struct {
	dbUser     string
	dbPassword string
	dbHost     string
	dbPort     int
	dbName     string
}

/*
Handler for healthz service requests
*/
func Handler(hc *Config) (http.Handler, error) {
	h := &handler{hc.DbUser, hc.DbPassword, hc.DbHost, hc.DbPort, hc.DbName}

	if h.dbPort == 0 {
		h.dbPort = 3306
	}
	return h, nil
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

func (h *handler) getDbConnection() (*sql.DB, error) {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		h.dbUser, h.dbPassword, h.dbHost, h.dbPort, h.dbName)
	db, err := sql.Open("mysql", connectionString)
	if err == nil {
		err = db.Ping()
	}

	return db, err
}

func (h *handler) getGuestList() ([]Guest, error) {
	db, err := h.getDbConnection()
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

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	guests, err := h.getGuestList()
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
