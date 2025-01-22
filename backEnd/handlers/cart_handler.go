package handlers

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary Add product to user's cart
// @Description Adds a product to the authenticated user's cart
// @Tags Cart
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param productID path string true "Product ID"
// @Param quantity query int true "Quantity to add" minimum(1)
// @Success 200 "Success"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 404 "Product not found"
// @Failure 400 "Insufficient product quantity"
// @Failure 500 "Internal server error"
// @Router /Cart/add-to-cart{productID} [post]
func AddToCart(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Token missing"})
		return
	}

	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Invalid token"})
		return
	}

	userID := claim.Subject
	productID := c.Param("productID")

	quantityStr := c.Query("quantity")
	quantity, err := strconv.Atoi(quantityStr)
	if err != nil || quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid quantity. Must be a positive number"})
		return
	}

	var product models.Product
	productQuery := `SELECT id, name, image, description, quantity, price, isWishlist FROM Product WHERE id = ?`
	err = database.DB.QueryRow(productQuery, productID).Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Quantity, &product.Price, &product.IsWishList)
	if err == sql.ErrNoRows {
		log.Println("Product not found for productID:", productID)
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found"})
		return
	} else if err != nil {
		log.Println("Database query error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}

	var cartQuantity int
	cartQuery := `SELECT quantity FROM Cart WHERE userID = ? AND productID = ?`
	err = database.DB.QueryRow(cartQuery, userID, productID).Scan(&cartQuantity)
	if err != nil && err != sql.ErrNoRows {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}

	newQuantity := quantity
	if cartQuantity > 0 {
		newQuantity += cartQuantity
	}

	if newQuantity > product.Quantity {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  "error",
			"message": fmt.Sprintf("Insufficient stock. Available: %d, Requested: %d", product.Quantity, newQuantity),
		})
		return
	}

	if cartQuantity > 0 {
		updateCartQuery := `UPDATE Cart SET quantity = ? WHERE userID = ? AND productID = ?`
		_, err = database.DB.Exec(updateCartQuery, newQuantity, userID, productID)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to update cart"})
			return
		}
	} else {
		id := uuid.NewString()
		insertCartQuery := `INSERT INTO Cart (id, userID, productID, quantity) VALUES (?, ?, ?, ?)`
		_, err = database.DB.Exec(insertCartQuery, id, userID, productID, quantity)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to add to cart"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Product added to cart"})
}

// @Summary Remove product from user's cart
// @Description Removes a product from the authenticated user's cart
// @Tags Cart
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param productID path string true "Product ID"
// @Success 200 "Success"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 404 "Product not found in cart"
// @Failure 500 "Internal server error"
// @Router /Cart/remove-to-cart{productID} [delete]
func RemoveFromCart(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Token missing"})
		return
	}

	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Invalid token"})
		return
	}

	userID := claim.Subject
	productID := c.Param("productID")

	var cartQuantity int
	cartQuery := `SELECT quantity FROM Cart WHERE userID = ? AND productID = ?`
	err = database.DB.QueryRow(cartQuery, userID, productID).Scan(&cartQuantity)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found in cart"})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}

	deleteCartQuery := `DELETE FROM Cart WHERE userID = ? AND productID = ?`
	_, err = database.DB.Exec(deleteCartQuery, userID, productID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to remove from cart"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Product removed from cart"})
}

// @Summary Get all items in user's cart
// @Description Retrieves all items in the authenticated user's cart
// @Tags Cart
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 500 "Internal server error"
// @Router /Cart/get-cart-items [get]
func GetCartItems(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Token missing"})
		return
	}

	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "Invalid token"})
		return
	}

	userID := claim.Subject

	cartQuery := `SELECT c.id, c.productID, p.name, p.image, p.description, c.quantity, p.price
                  FROM Cart c
                  JOIN Product p ON c.productID = p.id
                  WHERE c.userID = ?`
	rows, err := database.DB.Query(cartQuery, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}
	defer rows.Close()

	var cartItems []models.CartItem
	var overallTotalPrice float32
	for rows.Next() {
		var item models.CartItem
		err := rows.Scan(&item.ID, &item.ProductID, &item.Name, &item.Image, &item.Description, &item.Quantity, &item.Price)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to scan cart item"})
			return
		}
		item.TotalPrice = item.Price * float32(item.Quantity)
		overallTotalPrice += item.TotalPrice
		cartItems = append(cartItems, item)
	}

	c.JSON(http.StatusOK, gin.H{
		"status":     "success",
		"data":       cartItems,
		"totalPrice": overallTotalPrice,
	})
}
