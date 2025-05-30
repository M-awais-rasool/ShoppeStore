#!/bin/bash

# Start the SQL Server Docker container
echo "Starting SQL Server container..."
docker-compose up -d

# Wait for database to be fully initialized
echo "Waiting for database to initialize (30 seconds)..."
sleep 30

# Run the Go application
echo "Starting the Go application..."
go run main.go
