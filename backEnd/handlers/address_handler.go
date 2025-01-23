package handlers

import (
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary Add or Update Address
// @Description Add or update address for the user
// @Tags Address
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param address body models.Address true "Address Details"
// @Success 200 "Success"
// @Failure 400 "Invalid input data"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Address/add-address [post]
func AddAddress(c *gin.Context) {
	token := c.GetHeader("Authorization")

	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token messing"})
		return
	}
	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token invalid"})
		return
	}
	userId := claim.Subject

	var address models.Address
	err = c.ShouldBindJSON(&address)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid input data"})
		return
	}

	query := `SELECT id FROM address WHERE userID = ?`
	var existingID string
	err = database.DB.QueryRow(query, userId).Scan(&existingID)

	if err == nil {
		updateQuery := `UPDATE address SET name=?, address=?, apartment=?, phone=?, city=?, district=? WHERE id=?`
		_, err = database.DB.Exec(updateQuery, address.Name, address.Address, address.Apartment, address.Phone, address.City, address.District, existingID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Address updated successfully"})
		return
	}

	id := uuid.NewString()
	insertQuery := `INSERT INTO address (id, userID, name, address, apartment, phone, city, district) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
	_, err = database.DB.Exec(insertQuery, id, userId, address.Name, address.Address, address.Apartment, address.Phone, address.City, address.District)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Address added successfully"})
}

// @Summary Get Address
// @Description Get address for the user
// @Tags Address
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Address/get-address [get]
func GetAddress(c *gin.Context) {
	token := c.GetHeader("Authorization")

	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token messing"})
		return
	}
	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token invalid"})
		return
	}
	userId := claim.Subject

	query := `SELECT id, name, address, apartment, phone, city, district FROM address WHERE userID = ?`
	var address models.Address
	var ID string

	err = database.DB.QueryRow(query, userId).Scan(&ID, &address.Name, &address.Address, &address.Apartment, &address.Phone, &address.City, &address.District)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}
	data := gin.H{
		"id":        ID,
		"name":      address.Name,
		"address":   address.Address,
		"apartment": address.Apartment,
		"phone":     address.Phone,
		"city":      address.City,
		"district":  address.District,
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": data})
}
