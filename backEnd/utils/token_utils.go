package utils

import (
	"errors"

	"github.com/golang-jwt/jwt/v5"
)

var jwtKey = []byte("agfgdfdsgfdfgdertwcvb")

func ValidateToken(tokenString string) (*jwt.RegisteredClaims, error) {
	if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
		tokenString = tokenString[7:]
	}

	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})
	if err != nil || !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}
