package handlers

import (
	"net/http"
	"shoppeStore/database"
	"shoppeStore/utils"

	"github.com/gin-gonic/gin"
)

// @Summary Get user profile data
// @Description Get user profile data
// @Tags profile
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Profile/get-profile [get]
func GetProfileData(c *gin.Context) {
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

	userID := claim.Subject
	query := `SELECT id, name, email, image FROM users WHERE id = ?`
	var id, name, email, image string
	err = database.DB.QueryRow(query, userID).Scan(&id, &name, &email, &image)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "internal server error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": gin.H{
		"id":    id,
		"name":  name,
		"email": email,
		"image": image,
	}})
}
