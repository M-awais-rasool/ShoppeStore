package main

import (
	"log"
	"shoppeStore/database"
	_ "shoppeStore/docs"
	"shoppeStore/envConfig"
	"shoppeStore/routes"
)

// @title Demo API
// @version 1.0
// @description This is a sample server for a demo application
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	log.Println("Initializing application...")

	// Initialize environment variables
	envConfig.LoadEnv()

	// Connect to database
	log.Println("Connecting to database...")
	database.ConnectDB()

	// Set up routes
	log.Println("Setting up routes...")
	router := routes.SetRoutes()

	// Start server
	serverPort := ":8080"
	log.Printf("Starting server on %s", serverPort)
	log.Println("Swagger UI available at http://localhost:8080/swagger/index.html")

	if err := router.Run(serverPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
