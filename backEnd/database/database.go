package database

import (
	"database/sql"
	"fmt"
	"log"
	"shoppeStore/envConfig"
	"time"

	_ "github.com/denisenkom/go-mssqldb"
)

var DB *sql.DB

func ConnectDB() {

	envConfig.LoadEnv()

	_, _, _, _, dbServer, dbUser, dbPassword, dbPort, dbName, dbEncrypt := envConfig.GetEnvVars()

	masterConnString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%s;database=master;encrypt=%s;trustservercertificate=true",
		dbServer, dbUser, dbPassword, dbPort, dbEncrypt)

	maxRetries := 5
	for i := 0; i < maxRetries; i++ {
		log.Printf("Attempting to connect to database server (attempt %d/%d)...", i+1, maxRetries)

		tempDB, err := sql.Open("mssql", masterConnString)
		if err != nil {
			log.Printf("Error opening connection to database: %v", err)
			time.Sleep(3 * time.Second)
			continue
		}

		err = tempDB.Ping()
		if err != nil {
			log.Printf("Error pinging database: %v", err)
			tempDB.Close()
			time.Sleep(3 * time.Second)
			continue
		}

		checkDbQuery := fmt.Sprintf("IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '%s') CREATE DATABASE %s", dbName, dbName)
		_, err = tempDB.Exec(checkDbQuery)
		if err != nil {
			log.Printf("Error creating database if not exists: %v", err)
			tempDB.Close()
			time.Sleep(3 * time.Second)
			continue
		}

		tempDB.Close()

		connString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%s;database=%s;encrypt=%s;trustservercertificate=true",
			dbServer, dbUser, dbPassword, dbPort, dbName, dbEncrypt)

		DB, err = sql.Open("mssql", connString)
		if err != nil {
			log.Printf("Error opening connection to application database: %v", err)
			time.Sleep(3 * time.Second)
			continue
		}

		err = DB.Ping()
		if err != nil {
			log.Printf("Error pinging application database: %v", err)
			time.Sleep(3 * time.Second)
			continue
		}

		log.Println("Connected to the database successfully!")
		return
	}

	log.Fatalf("Failed to connect to database after %d attempts", maxRetries)
}
