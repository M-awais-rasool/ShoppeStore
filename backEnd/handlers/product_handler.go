package handlers

import (
	"fmt"
	"log"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"
	"strings"

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

// @Summary Get related products by name
// @Description Retrieve related products from the database by matching name or description
// @Tags Products
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param name query string true "Product name to search for related items"
// @Success 200 "Success"
// @Failure 400 "Bad Request"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Product/get-related-products [get]
func GetSimilarProducts(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Unauthorized"})
		return
	}

	_, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Invalid token"})
		return
	}

	productNames := c.Query("name")
	if productNames == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Query parameter 'name' is required"})
		return
	}

	nameList := strings.Split(productNames, ",")
	for i := range nameList {
		nameList[i] = strings.TrimSpace(nameList[i])
	}

	query := `
		SELECT id, name, image, description, quantity, price, isWishlist
		FROM Product
		WHERE
	`
	queryParts := []string{}
	args := []interface{}{}

	for _, name := range nameList {
		queryParts = append(queryParts, "(CHARINDEX(?, Name) > 0 OR CHARINDEX(?, Description) > 0)")
		args = append(args, name, name)
	}

	query += strings.Join(queryParts, " OR ")

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error fetching products from database"})
		return
	}
	defer rows.Close()

	products := []models.Product{}
	for rows.Next() {
		var product models.Product
		if err := rows.Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Quantity, &product.Price, &product.IsWishList); err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error reading database results"})
			return
		}
		products = append(products, product)
	}

	if len(products) == 0 {
		c.JSON(http.StatusOK, gin.H{"status": "success", "data": nil})
	} else {
		c.JSON(http.StatusOK, gin.H{"status": "success", "data": products})
	}
}
