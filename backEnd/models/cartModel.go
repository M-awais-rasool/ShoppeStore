package models

type CartItem struct {
	ID          string  `json:"id"`
	ProductID   string  `json:"productID"`
	Name        string  `json:"name"`
	Image       string  `json:"image"`
	Description string  `json:"description"`
	Quantity    int     `json:"quantity"`
	Price       float32 `json:"price"`
	TotalPrice  float32 `json:"totalPrice"`
}
