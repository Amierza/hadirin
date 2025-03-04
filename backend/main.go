package main

import (
	"log"
	"os"

	"github.com/Amierza/hadirin/backend/cmd"
	"github.com/Amierza/hadirin/backend/config/database"
	"github.com/Amierza/hadirin/backend/handler"
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
		jwtService      = service.NewJWTService()
		employeeRepo    = repository.NewEmployeeRepository(db)
		employeeService = service.NewEmployeeService(employeeRepo, jwtService)
		employeeHandler = handler.NewEmployeeHandler(employeeService)
	)

	server := gin.Default()

	routes.Employee(server, employeeHandler, jwtService)

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
