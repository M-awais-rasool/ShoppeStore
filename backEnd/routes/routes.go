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
	router.DELETE("Auth/delete-account", handlers.DeleteAccount)

	router.GET("Product/get-products", handlers.GetAllProduct)
	router.GET("Product/get-related-products", handlers.GetSimilarProducts)
	router.GET("Product/get-by-category:category", handlers.GetProductByCategory)
	router.GET("Product/get-by-id/:id", handlers.GetProductById)

	router.GET("WishList/get-wishList", handlers.GetWishList)
	router.POST("WishList/add-wishList:productID", handlers.AddWishList)
	router.DELETE("WishList/remove-wishList:productID", handlers.RemoveFromWishList)

	router.POST("Cart/add-to-cart:productID", handlers.AddToCart)
	router.DELETE("Cart/remove-to-cart:productID", handlers.RemoveFromCart)
	router.GET("Cart/get-cart-items", handlers.GetCartItems)

	router.POST("Address/add-address", handlers.AddAddress)
	router.GET("Address/get-address", handlers.GetAddress)

	router.GET("Profile/get-profile", handlers.GetProfileData)

	router.POST("Orders/place-single-order", handlers.PlaceSingleOrder)
	router.POST("Orders/place-cart-order", handlers.PlaceCartOrder)
	router.POST("Orders/get-order-status", handlers.GetOrderStatus)
	router.POST("Orders/change-order-status", handlers.ChangeOrderStatus)
	router.GET("Orders/get-user-orders", handlers.GetOrders)
	router.GET("Orders/get-active-orders", handlers.GetActiveOrder)
	router.GET("Orders/get-canceled-orders", handlers.GetCanceledOrder)

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	return router
}
