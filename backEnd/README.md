# ShoppeStore Backend

This is the backend for the ShoppeStore application.

## Setup and Running

### Requirements

- Docker and Docker Compose
- Go 1.23 or higher

### Starting the application

To start both the database and the application in one go:

```bash
./start.sh
```

This script will:
1. Start the SQL Server container using Docker Compose
2. Wait for the database to initialize
3. Start the Go application

### Starting just the database

If you want to start only the database:

```bash
docker-compose up -d
```

This will start the SQL Server container in detached mode. The database will be initialized with the required tables and sample product data.

### Starting just the application

If the database is already running and you only want to start the application:

```bash
go run main.go
```

### Docker Environment

If you are running the application in Docker, you may need to use the Docker-specific environment file:

```bash
cp .env.docker .env
```

## API Documentation

Swagger UI is available at: http://localhost:8080/swagger/index.html when the application is running.

## Database

The database is automatically created and initialized with tables and sample data when you start the Docker container. The initialization script is located at `sql/init.sql`.

## Environment Variables

Environment variables are stored in the `.env` file. The following variables are used:

### Database Configuration
- `DB_SERVER`: SQL Server hostname or IP
- `DB_USER`: SQL Server username
- `DB_PASSWORD`: SQL Server password
- `DB_PORT`: SQL Server port
- `DB_NAME`: Database name
- `DB_ENCRYPT`: Whether to use encryption for SQL Server connection

### AWS S3 Configuration
- `S3_REGION`: AWS S3 region
- `ACCESS_KEY_ID`: AWS access key ID
- `S3_BUCKET`: AWS S3 bucket name
- `SECRET_KEY`: AWS secret key
