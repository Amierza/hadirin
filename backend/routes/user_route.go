package routes

import (
	"log"

	"github.com/Amierza/hadirin/backend/handler"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/gin-gonic/gin"
)

func User(route *gin.Engine, userHandler handler.IUserHandler, jwtService service.IJWTService) {
	routes := route.Group("/api/v1/user")
	log.Println(routes)
	{

	}
}
