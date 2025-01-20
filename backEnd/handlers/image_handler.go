package handlers

import (
	"context"
	"fmt"
	"mime/multipart"
	"time"

	"shoppeStore/envConfig"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gin-gonic/gin"
)

func Upload_Image(c *gin.Context, file multipart.File, header *multipart.FileHeader) (string, error) {
	s3Region, accessKeyID, s3Bucket, secretKey, _, _, _, _, _, _ := envConfig.GetEnvVars()

	if file == nil {
		return "", fmt.Errorf("no file uploaded")
	}
	defer file.Close()

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(s3Region),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(
			accessKeyID,
			secretKey,
			"",
		)),
	)
	if err != nil {
		return "", fmt.Errorf("failed to configure AWS: %v", err)
	}

	s3Client := s3.NewFromConfig(cfg)

	filename := time.Now().Format("20060102150405") + "-" + header.Filename

	_, err = s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(s3Bucket),
		Key:    aws.String(filename),
		Body:   file,
	})
	if err != nil {
		return "", fmt.Errorf("failed to upload to S3: %v", err)
	}

	publicURL := fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s",
		s3Bucket,
		s3Region,
		filename,
	)

	return publicURL, nil
}
