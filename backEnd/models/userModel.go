package models

import "github.com/google/uuid"

// User represents the user registration details.
// @Description Model for user registration
// @type User
// @property {string} name The name of the user
// @property {string} email The email of the user
// @property {string} password The password of the user
// @property {string} image The image of the user
type User struct {
	ID       uuid.UUID `json:"id"`
	Name     string    `json:"name"`
	Email    string    `json:"email"`
	Password string    `json:"password"`
	Image    string    `json:"image"`
}

// User represents the user registration details.
// @Description Model for user registration
// @type User
// @property {string} email The email of the user
// @property {string} password The password of the user
type UserSignIn struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// User represents the user registration details.
// @Description Model for user registration
// @type User
// @property {string} email The email of the user
type EmailSignIn struct {
	Email string `json:"email" binding:"required"`
}

// User represents the user registration details.
// @Description Model for user registration
// @type User
// @property {string} name The name of the user
// @property {string} email The email of the user
// @property {string} password The password of the user
// @property {string} image The image of the user
type SignUp struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
	Image    string `json:"image" binding:"required"`
}
