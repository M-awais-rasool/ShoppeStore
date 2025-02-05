package handlers

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"

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
		"name":  storeUser.Name,
		"image": storeUser.Image,
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
		log.Println("All fields are required")
		c.JSON(http.StatusBadRequest, gin.H{"error": "All fields are required"})
		return
	}
	defer file.Close()

	var exists bool
	err = database.DB.QueryRow("SELECT COUNT(1) FROM users WHERE email = ?", email).Scan(&exists)
	if err != nil {
		log.Println("Failed to check email:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check email"})
		return
	}
	if exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email already exists"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Println("Failed to hash password:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	imageURL, err := Upload_Image(c, file, fileHeader)
	if err != nil {
		log.Println("Failed to upload image:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload image"})
		return
	}

	query := "INSERT INTO users (id, name, email, password, image) VALUES (?, ?, ?, ?, ?)"
	id := uuid.NewString()
	_, err = database.DB.Exec(query, id, name, email, string(hashedPassword), imageURL)
	if err != nil {
		log.Println("Failed to insert data:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "User signed up successfully"})
}

// @Summary Delete User Account
// @Description Permanently delete user account and all related data
// @Tags Auth
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Auth/delete-account [delete]
func DeleteAccount(c *gin.Context) {
	token := c.GetHeader("Authorization")

	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token missing"})
		return
	}

	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token invalid"})
		return
	}
	userID := claim.Subject

	tx, err := database.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}

	_, err = tx.Exec("DELETE FROM orderItems WHERE orderID IN (SELECT id FROM orders WHERE userID = ?)", userID)
	if err != nil {
		tx.Rollback()
		log.Println("Error deleting orderItems:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete from order_items"})
		return
	}

	_, err = tx.Exec("DELETE FROM orders WHERE userID = ?", userID)
	if err != nil {
		tx.Rollback()
		log.Println("Error deleting orders:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete from orders"})
		return
	}

	tables := []string{"cart", "wishlist", "address"}
	for _, table := range tables {
		query := fmt.Sprintf("DELETE FROM %s WHERE userID = ?", table)
		if _, err := tx.Exec(query, userID); err != nil {
			tx.Rollback()
			log.Println("Error deleting from", table, ":", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete from " + table})
			return
		}
	}

	_, err = tx.Exec("DELETE FROM users WHERE id = ?", userID)
	if err != nil {
		tx.Rollback()
		log.Println("Error deleting user:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
		return
	}

	err = tx.Commit()
	if err != nil {
		log.Println("Error committing transaction:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Account deleted successfully"})
}
