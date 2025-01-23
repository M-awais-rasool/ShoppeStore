package models

type Address struct {
	Name      string `json:"name"`
	Address   string `json:"address"`
	Apartment string `json:"apartment"`
	Phone     string `json:"phone"`
	City      string `json:"city"`
	District  string `json:"district"`
}
