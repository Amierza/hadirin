package main

import (
	"log"
	"os"

	"github.com/Amierza/hadirin/backend/cmd"
	"github.com/Amierza/hadirin/backend/config/database"
	"github.com/Amierza/hadirin/backend/handler"
	"github.com/Amierza/hadirin/backend/middleware"
	"github.com/Amierza/hadirin/backend/repository"
	"github.com/Amierza/hadirin/backend/routes"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/gin-gonic/gin"
)

func main() {
	db := database.SetUpPostgreSQLConnection()
	defer database.ClosePostgreSQLConnection(db)

	if len(os.Args) > 1 {
		cmd.Command(db)
		return
	}

	var (
		jwtService  = service.NewJWTService()
		userRepo    = repository.NewUserRepository(db)
		userService = service.NewUserService(userRepo, jwtService)
		userHandler = handler.NewUserHandler(userService)
	)

	server := gin.Default()
	server.Use(middleware.CORSMiddleware())

	routes.User(server, userHandler, jwtService)

	server.Static("/assets", "./assets")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	var serve string
	if os.Getenv("APP_ENV") == "localhost" {
		serve = "127.0.0.1:" + port
	} else {
		serve = ":" + port
	}

	if err := server.Run(serve); err != nil {
		log.Fatalf("error running server: %v", err)
	}
}
