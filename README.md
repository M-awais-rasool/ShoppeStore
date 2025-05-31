# ShoppeStore - Full Stack E-commerce Application

ShoppeStore is a full-stack e-commerce application built with SwiftUI for the frontend and Golang for the backend. The app enables users to manage orders, cart, and wishlist with AI-powered product recommendations and secure authentication.

## Key Features
- **Order, Cart, and Wishlist Management**: Users can seamlessly add, update, and manage their orders, cart, and wishlist.
- **AI-Powered Recommendations**: Integrated MobileNetV2 to provide smart product suggestions based on user preferences.
- **Secure Authentication**: Implemented robust authentication to protect user data and ensure privacy.
- **SwiftUI & Golang Integration**: Leveraged SwiftUI for a modern UI and Golang for a scalable and efficient backend.

## App Screens

### Landing Screen
<img width="403" alt="Image" src="https://github.com/user-attachments/assets/056ab66b-0383-4656-adbb-f87a107142fa" />

### Login Screen
<img width="390" alt="Image" src="https://github.com/user-attachments/assets/695d19a0-adb1-4511-8ad5-2a26175529b8" />

### Home Screen
<img width="399" alt="Image" src="https://github.com/user-attachments/assets/6cea2177-1040-4634-b456-89c351c4e56b" />

### Product Details Screen
<img width="399" alt="Image" src="https://github.com/user-attachments/assets/a332858f-a087-4536-aa2b-2a48d77c7824" />

### Category Screen
<img width="394" alt="Image" src="https://github.com/user-attachments/assets/76ba7a51-3431-454c-a4ce-84826d76296d" />

### Product Scan Screen
<img width="391" alt="Image" src="https://github.com/user-attachments/assets/ab0d5c8c-9b84-4bc8-999a-b2b20973a343" />

### Setting Screen
<img width="403" alt="Image" src="https://github.com/user-attachments/assets/77611b22-fb64-49d1-b83f-a7e3d3888956" />

## Tech Stack
- **Frontend**: SwiftUI
- **Backend**: Golang (Gin framework)
- **AI Integration**: MobileNetV2
- **Storage & Database**: S3, RDS, Dockerized SQL Server
- **Documentation**: Swagger

## Backend Setup

### Requirements
- Docker and Docker Compose
- Go 1.23 or higher

### Starting the application

To start both the database and the application in one go:

```bash
cd backEnd
./start.sh
```

This script will:
1. Start the SQL Server container using Docker Compose
2. Wait for the database to initialize
3. Start the Go application

### Starting just the database

If you want to start only the database:

```bash
cd backEnd
docker-compose up -d
```

This will start the SQL Server container in detached mode. The database will be initialized with the required tables and sample product data.

### Starting just the application

If the database is already running and you only want to start the application:

```bash
cd backEnd
go run main.go
```

### API Documentation

Swagger UI is available at: http://localhost:8080/swagger/index.html when the application is running.

### Database

The database is automatically created and initialized with tables and sample data when you start the Docker container. The initialization script is located at `backEnd/sql/init.sql`.

### Environment Variables

Environment variables are stored in the `.env` file. The following variables are used:

#### Database Configuration
- `DB_SERVER`: SQL Server hostname or IP
- `DB_USER`: SQL Server username
- `DB_PASSWORD`: SQL Server password
- `DB_PORT`: SQL Server port
- `DB_NAME`: Database name
- `DB_ENCRYPT`: Whether to use encryption for SQL Server connection

#### AWS S3 Configuration
- `S3_REGION`: AWS S3 region
- `ACCESS_KEY_ID`: AWS access key ID
- `S3_BUCKET`: AWS S3 bucket name
- `SECRET_KEY`: AWS secret key
