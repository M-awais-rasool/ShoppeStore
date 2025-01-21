package handlers

import (
	"database/sql"
	"log"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

var jwtKey = []byte("agfgdfdsgfdfgdertwcvb")

// @Summary Check User Email
// @Description Check if the user email exists in the database
// @Tags Auth
// @Accept json
// @Produce json
// @Param user body models.EmailSignIn true "User Email Details"
// @Success 200 "Success"
// @Failure 404 "User not found"
// @Failure 500 "Internal Server Error"
// @Router /Auth/email-check [post]
func EmailCheck(c *gin.Context) {
	var reqUser models.EmailSignIn
	var storeUser models.User

	err := c.ShouldBindJSON(&reqUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Invalid input data"})
		return
	}
	query := `SELECT id, name, email, password, image FROM users WHERE email = ?`

	err = database.DB.QueryRow(query, reqUser.Email).Scan(&storeUser.ID, &storeUser.Name, &storeUser.Email, &storeUser.Image, &storeUser.Password)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Email does not exist"})
		return
	} else if err != nil {
		log.Printf("Database query error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": gin.H{
		"email": storeUser.Email,
	}})
}

// @Summary User Login
// @Description Authenticate user and return JWT token
// @Tags Auth
// @Accept json
// @Produce json
// @Param user body models.UserSignIn true "User Login Details"
// @Success 200 "Success"
// @Failure 404 "User not found"
// @Failure 500 "Internal Server Error"
// @Router /Auth/login [post]
func Login(c *gin.Context) {
	var reqUser models.UserSignIn
	var storeUser models.User

	if err := c.ShouldBindJSON(&reqUser); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Invalid input data"})
	}
	query := `SELECT id, name, email, password, image FROM users WHERE email = ?`

	err := database.DB.QueryRow(query, reqUser.Email).Scan(&storeUser.ID, &storeUser.Name, &storeUser.Email, &storeUser.Password, &storeUser.Image)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Email does not exist"})
		return
	} else if err != nil {
		log.Printf("Database query error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(storeUser.Password), []byte(reqUser.Password)); err != nil {
		log.Println("Password mismatch:", err)
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Invalid password"})
		return
	}

	claims := &jwt.RegisteredClaims{
		Subject: storeUser.ID.String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Sign in successful",
		"data": gin.H{
			"name":   storeUser.Name,
			"email":  storeUser.Email,
			"image":  storeUser.Image,
			"token":  tokenString,
			"userId": storeUser.ID.String(),
		},
	})
}

// @Summary Sign up a new user
// @Description Register a new user
// @Tags Auth
// @Accept json
// @Produce json
// @Param name formData string true "Name"
// @Param email formData string true "Email"
// @Param password formData string true "Password"
// @Param image formData file true "Image"
// @Success 200 "Success"
// @Failure 400 "Image upload failed"
// @Failure 500 "Internal Server Error"
// @Router /Auth/sign-up [post]
func SignUp(c *gin.Context) {
	name := c.PostForm("name")
	email := c.PostForm("email")
	password := c.PostForm("password")
	file, fileHeader, err := c.Request.FormFile("image")

	if name == "" || email == "" || password == "" || err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "All fields are required"})
		return
	}
	defer file.Close()

	var exists bool
	err = database.DB.QueryRow("SELECT COUNT(1) FROM users WHERE email = ?", email).Scan(&exists)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check email"})
		return
	}
	if exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email already exists"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	imageURL, err := Upload_Image(c, file, fileHeader)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload image"})
		return
	}

	query := "INSERT INTO users (id, name, email, password, image) VALUES (?, ?, ?, ?, ?)"
	id := uuid.NewString()
	_, err = database.DB.Exec(query, id, name, email, string(hashedPassword), imageURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User signed up successfully"})
}
