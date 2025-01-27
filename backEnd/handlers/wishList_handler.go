package handlers

import (
	"database/sql"
	"log"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary Add product to user's wishlist
// @Description Adds a product to the authenticated user's wishlist
// @Tags wishlist
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param productID path string true "Product ID"
// @Success 200 "Success"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 404 "Product not found"
// @Failure 500 "Internal server error"
// @Router /WishList/add-wishList{productID} [post]
func AddWishList(c *gin.Context) {
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

	var product models.Product
	productQuery := `SELECT id, name, image, description, price FROM products WHERE id = ?`
	err = database.DB.QueryRow(productQuery, productID).Scan(&product.ID, &product.Name, &product.Image, &product.Description, &product.Price)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found"})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}

	id := uuid.NewString()
	wishlistQuery := `INSERT INTO wishlist (id, userID, productID, image, name, price) VALUES (?, ?, ?, ?, ?, ?)`
	_, err = database.DB.Exec(wishlistQuery, id, userID, product.ID, product.Image, product.Name, product.Price)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to add to wishlist"})
		return
	}

	updateProductQuery := `UPDATE products SET isWishlist = 1 WHERE id = ?`
	_, err = database.DB.Exec(updateProductQuery, productID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to update product status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Product added to wishlist"})
}

// @Summary Remove product from user's wishlist
// @Description Removes a product from the authenticated user's wishlist
// @Tags wishlist
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param productID path string true "Product ID"
// @Success 200 "Product successfully removed from wishlist"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 404 "Product not found in wishlist"
// @Failure 500 "Internal server error"
// @Router /WishList/remove-wishList{productID} [delete]
func RemoveFromWishList(c *gin.Context) {
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

	var exists int
	wishlistQuery := `SELECT COUNT(1) FROM wishlist WHERE userID = ? AND productID = ?`
	err = database.DB.QueryRow(wishlistQuery, userID, productID).Scan(&exists)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database error"})
		return
	}
	if exists == 0 {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found in wishlist"})
		return
	}

	deleteQuery := `DELETE FROM wishlist WHERE userID = ? AND productID = ?`
	_, err = database.DB.Exec(deleteQuery, userID, productID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to remove from wishlist"})
		return
	}

	updateProductQuery := `UPDATE products SET isWishlist = 0 WHERE id = ?`
	_, err = database.DB.Exec(updateProductQuery, productID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to update product status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Product removed from wishlist"})
}

// @Summary Get user's wishlist
// @Description Fetches the authenticated user's wishlist
// @Tags wishlist
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized - Token missing or invalid"
// @Failure 500 "Internal server error"
// @Router /WishList/get-wishList [get]
func GetWishList(c *gin.Context) {
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

	wishlistQuery := `SELECT id, productID, image, name, price FROM wishlist WHERE userID = ?`
	rows, err := database.DB.Query(wishlistQuery, userID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to fetch wishlist"})
		return
	}
	defer rows.Close()

	var wishList []models.WishList
	for rows.Next() {
		var wish models.WishList
		err := rows.Scan(&wish.ID, &wish.ProductID, &wish.Image, &wish.Name, &wish.Price)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to fetch wishlist"})
			return
		}
		wishList = append(wishList, wish)
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": wishList})
}
