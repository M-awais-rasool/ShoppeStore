package envConfig

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadEnv() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}
}

func GetEnvVars() (string, string, string, string, string, string, string, string, string, string) {
	s3Region := os.Getenv("S3_REGION")
	accessKeyID := os.Getenv("ACCESS_KEY_ID")
	s3Bucket := os.Getenv("S3_BUCKET")
	secretKey := os.Getenv("SECRET_KEY")

	dbServer := os.Getenv("DB_SERVER")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbPort := os.Getenv("DB_PORT")
	dbName := os.Getenv("DB_NAME")
	dbEncrypt := os.Getenv("DB_ENCRYPT")

	return s3Region, accessKeyID, s3Bucket, secretKey, dbServer, dbUser, dbPassword, dbPort, dbName, dbEncrypt
}
