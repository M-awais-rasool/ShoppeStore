package routes

import (
	"shoppeStore/handlers"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetRoutes() *gin.Engine {
	router := gin.Default()

	router.POST("/Auth/email-check", handlers.EmailCheck)
	router.POST("/Auth/login", handlers.Login)
	router.POST("Auth/sign-up", handlers.SignUp)

	router.GET("Product/get-products", handlers.GetAllProduct)

	router.GET("WishList/get-wishList", handlers.GetWishList)
	router.POST("WishList/add-wishList:productID", handlers.AddWishList)
	router.DELETE("WishList/remove-wishList:productID", handlers.RemoveFromWishList)

	router.POST("Cart/add-to-cart:productID", handlers.AddToCart)
	router.DELETE("Cart/remove-to-cart:productID", handlers.RemoveFromCart)
	router.GET("Cart/get-cart-items", handlers.GetCartItems)

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	return router
}
