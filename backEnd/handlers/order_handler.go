package handlers

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"shoppeStore/database"
	"shoppeStore/models"
	"shoppeStore/utils"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var sizes = []string{"S", "M", "L", "XL", "XXL", "XXXL"}

func GenerateOrderID() string {
	rand.Seed(time.Now().UnixNano())
	return fmt.Sprintf("#%d", rand.Intn(1_000_000))
}

func GetSizes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"sizes": sizes})
}

// @Summary Place a single order
// @Description Places an order for a single product
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body models.OrderRequest true "Order Details"
// @Success 200 "Success"
// @Failure 400 "Invalid input data"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Orders/place-single-order [post]
func PlaceSingleOrder(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token messing"})
		return
	}
	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "invalid token"})
		return
	}

	var req models.OrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	sizeValid := false
	for _, size := range sizes {
		if size == req.Size {
			sizeValid = true
			break
		}
	}
	if !sizeValid {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid size"})
		return
	}

	var deliveryStatus = []map[string]interface{}{
		{
			"id":     1,
			"status": "Standard",
			"price":  20.0,
		},
		{
			"id":     2,
			"status": "Express",
			"price":  30.0,
		},
	}

	var deliveryPrice float64
	var DelStatus string
	deliveryFound := false
	for _, delivery := range deliveryStatus {
		if delivery["id"].(int) == req.DeliveryID {
			deliveryPrice = delivery["price"].(float64)
			DelStatus = delivery["status"].(string)
			deliveryFound = true
			break
		}
	}
	if !deliveryFound {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid delivery option"})
		return
	}

	var price float64
	var productName string
	var productImage string
	err = database.DB.QueryRow("SELECT price, name, image FROM products WHERE id = $1", req.ProductID).Scan(&price, &productName, &productImage)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Product not found"})
		return
	}

	userID := claim.Subject
	id := uuid.NewString()
	OrderItemId := uuid.NewString()
	orderID := GenerateOrderID()
	totalPrice := (price * float64(req.Quantity)) + deliveryPrice
	status := "Pending"

	_, err = database.DB.Exec("INSERT INTO orders (id, orderID, userID, totalPrice, status, DeliveryStatus) VALUES ($1, $2, $3, $4, $5, $6)",
		id, orderID, userID, totalPrice, status, DelStatus)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to place order"})
		return
	}

	_, err = database.DB.Exec("INSERT INTO orderItems (id, productID, image, name, quantity, price, orderID, size) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
		OrderItemId, req.ProductID, productImage, productName, req.Quantity, price, orderID, req.Size)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to place order item"})
		return
	}
	// Order placed successfully
	c.JSON(http.StatusOK, gin.H{"status": "success", "orderID": orderID})
}

// @Summary Place cart orders
// @Description Places orders for all items in user's cart
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Orders/place-cart-order [post]
func PlaceCartOrder(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token missing"})
		return
	}
	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "invalid token"})
		return
	}

	userID := claim.Subject
	orderID := GenerateOrderID()
	id := uuid.NewString()
	status := "Pending"

	rows, err := database.DB.Query("SELECT productID, quantity FROM cart WHERE userID = ?", userID)
	if err != nil || err == sql.ErrNoRows {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to fetch cart"})
		return
	}
	defer rows.Close()

	var totalPrice float64
	var orderItems []struct {
		productID    string
		productImage string
		productName  string
		quantity     int
		price        float64
	}

	for rows.Next() {
		var productID string
		var quantity int
		var price float64
		var productName, productImage string

		err := rows.Scan(&productID, &quantity)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to read cart items"})
			return
		}

		err = database.DB.QueryRow("SELECT price, name, image FROM products WHERE id = $1", productID).
			Scan(&price, &productName, &productImage)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to get product details"})
			return
		}

		itemTotal := price * float64(quantity)
		totalPrice += itemTotal

		orderItems = append(orderItems, struct {
			productID    string
			productImage string
			productName  string
			quantity     int
			price        float64
		}{productID, productImage, productName, quantity, price})
	}

	_, err = database.DB.Exec("INSERT INTO orders (id, orderID, userID, totalPrice, status) VALUES ($1, $2, $3, $4, $5)",
		id, orderID, userID, totalPrice, status)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to create order"})
		return
	}

	for _, item := range orderItems {
		id := uuid.NewString()
		_, err = database.DB.Exec("INSERT INTO orderItems (id, productID, image, name, quantity, price, orderID) VALUES ($1, $2, $3, $4, $5, $6, $7)",
			id, item.productID, item.productImage, item.productName, item.quantity, item.price, orderID)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to create order items"})
			return
		}
	}

	_, err = database.DB.Exec("DELETE FROM cart WHERE userID = $1", userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to clear cart"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "orderID": orderID})
}

// @Summary Get User Orders
// @Description Get all orders placed by the user
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 400 "Invalid input data"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Orders/get-user-orders [get]
func GetOrders(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "token messing"})
		return
	}
	claim, err := utils.ValidateToken(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "error", "message": "invalid token"})
		return
	}
	userID := claim.Subject

	rows, err := database.DB.Query(`
		SELECT o.id, o.orderID, o.totalPrice, o.status, o.DeliveryStatus, oi.productID, oi.image, oi.name, oi.quantity, oi.price, oi.size
		FROM orders o
		JOIN orderItems oi ON o.orderID = oi.orderID
		WHERE o.userID = $1
		ORDER BY o.orderID`, userID)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to fetch orders"})
		return
	}
	defer rows.Close()

	orderMap := make(map[string]gin.H)
	for rows.Next() {
		var orderID, productID, id, image, name, status, size, DeliveryStatus string
		var totalPrice float64
		var quantity int
		var price float64

		err := rows.Scan(&id, &orderID, &totalPrice, &status, &DeliveryStatus, &productID, &image, &name, &quantity, &price, &size)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse order data"})
			return
		}

		if _, exists := orderMap[orderID]; !exists {
			orderMap[orderID] = gin.H{
				"id":             id,
				"orderID":        orderID,
				"totalPrice":     totalPrice,
				"status":         status,
				"DeliveryStatus": DeliveryStatus,
				"products":       []gin.H{},
			}
		}

		product := gin.H{
			"productID": productID,
			"image":     image,
			"name":      name,
			"quantity":  quantity,
			"price":     price,
			"size":      size,
		}

		products := orderMap[orderID]["products"].([]gin.H)
		products = append(products, product)
		orderMap[orderID]["products"] = products
	}

	orders := make([]gin.H, 0, len(orderMap))
	for _, order := range orderMap {
		orders = append(orders, order)
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": orders})
}
