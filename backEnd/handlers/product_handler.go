package handlers

import (
	"database/sql"
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

	query := `SELECT * FROM products`

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
		if err := rows.Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Price, &product.Quantity, &product.IsWishList, &product.Category); err != nil {
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
// @Description Retrieve related products from the database by matching name or description, excluding specified product ID
// @Tags Products
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param name query string true "Product name to search for related items"
// @Param productId query string true "Product ID to exclude from results"
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
	productID := c.Query("productId")
	if productNames == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Query parameter 'name' is required"})
		return
	}

	nameList := strings.Split(productNames, ",")
	for i := range nameList {
		nameList[i] = strings.TrimSpace(nameList[i])
	}

	query := `
		SELECT id, name, image, description, price, quantity, isWishlist, category
		FROM products
		WHERE id != ? AND (
	`
	queryParts := []string{}
	args := []interface{}{productID}

	for _, name := range nameList {
		queryParts = append(queryParts, "(LOWER(CAST(Name AS VARCHAR(255))) LIKE LOWER(?) OR LOWER(CAST(Description AS VARCHAR(255))) LIKE LOWER(?) OR LOWER(CAST(Category AS VARCHAR(255))) LIKE LOWER(?))")
		searchTerm := "%" + name + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
	}

	query += strings.Join(queryParts, " OR ") + ")"

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
		if err := rows.Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Price, &product.Quantity, &product.IsWishList, &product.Category); err != nil {
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

// @Summary Get products by category
// @Description Retrieve products from the database by category, or all products if no category specified
// @Tags Products
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param category path string false "Category"
// @Success 200 "Success"
// @Failure 500 "Internal Server Error"
// @Router /Product/get-by-category{category} [get]
func GetProductByCategory(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token missing"})
		return
	}
	_, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "invalid token"})
		return
	}

	category := c.Param("category")
	log.Println("category", category)
	var query string
	var rows *sql.Rows
	if category == "" || category == "all" {
		query = `SELECT * FROM products`
		rows, err = database.DB.Query(query)
	} else {
		query = `SELECT * FROM products WHERE category = ?`
		rows, err = database.DB.Query(query, category)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "failed to retrieve items"})
		return
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var product models.Product
		if err := rows.Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Price, &product.Quantity, &product.IsWishList, &product.Category); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "failed to scan item"})
			return
		}
		products = append(products, product)
	}
	if err := rows.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "error iterating rows"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": products})
}

// @Summary Get product by ID
// @Description Retrieve a product from the database by its ID
// @Tags Products
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Product ID"
// @Success 200 "Success"
// @Failure 400 "Bad Request"
// @Failure 401 "Unauthorized"
// @Failure 404 "Not Found"
// @Failure 500 "Internal Server Error"
// @Router /Product/get-by-id/{id} [get]
func GetProductById(c *gin.Context) {
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

	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Product ID is required"})
		return
	}

	query := `SELECT * FROM products WHERE id = ?`
	var product models.Product
	err = database.DB.QueryRow(query, id).Scan(
		&product.ID,
		&product.Name,
		&product.Image,
		&product.Description,
		&product.Price,
		&product.Quantity,
		&product.IsWishList,
		&product.Category,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": fmt.Sprintf("Database error: %v", err)})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": product})
}
