package models

type WishList struct {
	ID        string  `json:"id"`
	ProductID string  `json:"productID"`
	Image     string  `json:"image"`
	Name      string  `json:"name"`
	Price     float32 `json:"Price"`
	Size      string  `json:"size"`
}
