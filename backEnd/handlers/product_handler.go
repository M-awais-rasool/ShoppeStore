package handlers

import (
	"fmt"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"

	"github.com/gin-gonic/gin"
)

// @Summary Get all products
// @Description Retrieve all products from the database
// @Tags Products
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Product/get-products [get]
func GetAllProduct(c *gin.Context) {
	token := c.GetHeader("Authorization")

	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Unauthorized"})
		return
	}

	_, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "invalid token"})
		return
	}

	query := `SELECT * FROM Product`

	rows, err := database.DB.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": fmt.Sprintf("Failed to retrieve items: %s", err.Error()),
		})
		return
	}
	defer rows.Close()

	var products []models.Product

	for rows.Next() {
		var product models.Product
		if err := rows.Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Quantity, &product.Price, &product.IsWishList); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"status":  "error",
				"message": fmt.Sprintf("Failed to scan item: %s", err.Error()),
			})
			return
		}
		products = append(products, product)
	}

	if err := rows.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": fmt.Sprintf("Error iterating rows: %s", err.Error()),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   products,
	})
}
