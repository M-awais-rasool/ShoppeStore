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
// @Param deliveryId query int true "Delivery ID (1 for Standard, 2 for Express)"
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

	deliveryID := c.Query("deliveryId")
	var deliveryPrice float64
	var deliveryStatus string

	deliveryOptions := []map[string]interface{}{
		{
			"id":     "1",
			"status": "Standard",
			"price":  20.0,
		},
		{
			"id":     "2",
			"status": "Express",
			"price":  30.0,
		},
	}

	deliveryFound := false
	for _, delivery := range deliveryOptions {
		if delivery["id"].(string) == deliveryID {
			deliveryPrice = delivery["price"].(float64)
			deliveryStatus = delivery["status"].(string)
			deliveryFound = true
			break
		}
	}
	if !deliveryFound {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid delivery option"})
		return
	}

	userID := claim.Subject
	orderID := GenerateOrderID()
	id := uuid.NewString()
	status := "Pending"

	rows, err := database.DB.Query("SELECT productID, quantity, size FROM cart WHERE userID = ?", userID)
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
		size         string
	}

	for rows.Next() {
		var productID string
		var quantity int
		var price float64
		var productName, productImage, size string

		err := rows.Scan(&productID, &quantity, &size)
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

			quantity int
			price    float64
			size     string
		}{productID, productImage, productName, quantity, price, size})
	}

	totalPrice += deliveryPrice

	_, err = database.DB.Exec("INSERT INTO orders (id, orderID, userID, totalPrice, status, DeliveryStatus) VALUES ($1, $2, $3, $4, $5, $6)",
		id, orderID, userID, totalPrice, status, deliveryStatus)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to create order"})
		return
	}

	for _, item := range orderItems {
		id := uuid.NewString()
		_, err = database.DB.Exec("INSERT INTO orderItems (id, productID, image, name, quantity, price, orderID, size) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
			id, item.productID, item.productImage, item.productName, item.quantity, item.price, orderID, item.size)
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

// @Summary Get Order Status
// @Description Get the status of a specific order
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body models.OrderStatus true "Order ID"
// @Success 200 "Success"
// @Failure 400 "Invalid input data"
// @Failure 401 "Unauthorized"
// @Failure 404 "Order not found"
// @Failure 500 "Internal Server Error"
// @Router /Orders/get-order-status [post]
func GetOrderStatus(c *gin.Context) {
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

	var request models.OrderStatus

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid request body"})
		return
	}

	var status, deliveryStatus string
	err = database.DB.QueryRow("SELECT status, DeliveryStatus FROM orders WHERE orderID = $1 AND userID = $2",
		request.OrderID, userID).Scan(&status, &deliveryStatus)
	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Order not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to fetch order status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":      "success",
		"orderStatus": status,
	})
}

// @Summary Change Order Status
// @Description Change the status of a specific order
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body models.ChangeStatus true "Order ID and New Status"
// @Success 200 "Success"
// @Failure 400 "Invalid input data"
// @Failure 401 "Unauthorized"
// @Failure 404 "Order not found"
// @Failure 500 "Internal Server Error"
// @Router /Orders/change-order-status [post]
func ChangeOrderStatus(c *gin.Context) {
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

	var request models.ChangeStatus
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid request body"})
		return
	}
	var OrderStatus = struct {
		Confirmed string
		Packed    string
		Shipped   string
		Delivered string
		Canceled  string
	}{
		Confirmed: "Confirmed",
		Packed:    "Packed",
		Shipped:   "Shipped",
		Delivered: "Delivered",
		Canceled:  "Canceled",
	}
	validStatuses := []string{OrderStatus.Confirmed, OrderStatus.Packed, OrderStatus.Shipped, OrderStatus.Delivered, OrderStatus.Canceled}
	isValidStatus := false
	for _, status := range validStatuses {
		if request.Status == status {
			isValidStatus = true
			break
		}
	}

	if !isValidStatus {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid order status"})
		return
	}

	result, err := database.DB.Exec("UPDATE orders SET status = $1 WHERE orderID = $2 AND userID = $3",
		request.Status, request.OrderID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to update order status"})
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Failed to get affected rows"})
		return
	}
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Order not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Order status updated successfully"})
}

// @Summary Get Active Orders
// @Description Get all active orders (not delivered or canceled)
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Orders/get-active-orders [get]
func GetActiveOrder(c *gin.Context) {
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
	rows, err := database.DB.Query(`
		SELECT o.id, o.orderID, o.totalPrice, o.status, o.DeliveryStatus, oi.productID, oi.image, oi.name, oi.quantity, oi.price, oi.size
		FROM orders o
		JOIN orderItems oi ON o.orderID = oi.orderID
		WHERE o.userID = $1 AND o.status != 'Delivered' AND o.status != 'Canceled'
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

// @Summary Get Canceled Orders
// @Description Get all canceled orders
// @Tags Orders
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 "Success"
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /Orders/get-canceled-orders [get]
func GetCanceledOrder(c *gin.Context) {
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

	rows, err := database.DB.Query(`
		SELECT o.id, o.orderID, o.totalPrice, o.status, o.DeliveryStatus, oi.productID, oi.image, oi.name, oi.quantity, oi.price, oi.size
		FROM orders o
		JOIN orderItems oi ON o.orderID = oi.orderID
		WHERE o.userID = $1 AND o.status = 'Canceled'
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
