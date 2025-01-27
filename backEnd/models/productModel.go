package models

type Product struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Image       string  `json:"image"`
	Description string  `json:"description"`
	Price       float32 `json:"price"`
	Category    string  `json:"category"`
	Quantity    int     `json:"quantity"`
	IsWishList  bool    `json:"isWishList"`
}
