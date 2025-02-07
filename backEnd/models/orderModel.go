package models

type OrderRequest struct {
	ProductID  string `json:"productID" binding:"required"`
	Size       string `json:"size" binding:"required" example:"S M L XL XXL XXXL"`
	Quantity   int    `json:"quantity" binding:"required"`
	DeliveryID int    `json:"deliveryID" binding:"required"`
}

type MultiOrderRequest struct {
	UserID     int           `json:"user_id" binding:"required"`
	Products   []OrderDetail `json:"products" binding:"required"`
	TotalPrice float64       `json:"total_price" binding:"required"`
}

type OrderDetail struct {
	ProductID int     `json:"product_id" binding:"required"`
	Quantity  int     `json:"quantity" binding:"required"`
	Price     float64 `json:"price"`
}

type OrderStatus struct {
	OrderID string `json:"orderID"`
}

type ChangeStatus struct {
	OrderID string `json:"orderID"`
	Status  string `json:"status" example:"Confirmed, Packed, Shipped, Delivered, Canceled"`
}
