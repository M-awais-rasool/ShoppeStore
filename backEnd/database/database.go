package database

import (
	"database/sql"
	"fmt"
	"log"
	"shoppeStore/envConfig"
)

var DB *sql.DB

func ConnectDB() {
	var err error

	envConfig.LoadEnv()
	_, _, _, _, dbServer, dbUser, dbPassword, dbPort, dbName, dbEncrypt := envConfig.GetEnvVars()

	connString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%s;database=%s;encrypt=%s",
		dbServer, dbUser, dbPassword, dbPort, dbName, dbEncrypt)

	DB, err = sql.Open("mssql", connString)
	if err != nil {
		log.Fatalf("Error opening connection to database: %v", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatalf("Error pinging database: %v", err)
	}
	log.Println("Connected to the database successfully!")
}
