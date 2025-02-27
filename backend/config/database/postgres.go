package database

import (
	"fmt"
	"log"
	"os"

	"github.com/Amierza/hadirin/backend/constants"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func SetUpPostgreSQLConnection() *gorm.DB {
	if os.Getenv("APP_ENV") != constants.ENUM_RUN_PRODUCTION {
		if err := godotenv.Load(".env"); err != nil {
			panic(fmt.Errorf("failed to laod .env file: %v", err))
		}
	}

	dbHost := os.Getenv("DB_HOST")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	dbName := os.Getenv("DB_NAME")
	dbPort := os.Getenv("DB_PORT")

	dsn := fmt.Sprintf("host=%v, user=%v password=%v dbname=%v port=%v TimeZone=Asia/Jakarta", dbHost, dbUser, dbPass, dbName, dbPort)
	log.Printf("connecting to postgres: %v", dsn)

	db, err := gorm.Open(postgres.New(postgres.Config{
		DSN:                  dsn,
		PreferSimpleProtocol: true,
	}), &gorm.Config{})
	if err != nil {
		panic(fmt.Errorf("failed to connect postgres: %v", err))
	}

	log.Println("postgres connection established")
	return db
}

func ClosePostgreSQLConnection(db *gorm.DB) {
	dbSQL, err := db.DB()
	if err != nil {
		panic(fmt.Errorf("error closing postgres connection: %v", err))
	}

	dbSQL.Close()
	log.Println("postgres connection closed")
}
