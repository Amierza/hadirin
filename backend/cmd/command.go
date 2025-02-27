package cmd

import (
	"log"
	"os"

	"github.com/Amierza/hadirin/backend/migrations"
	"gorm.io/gorm"
)

func Command(db *gorm.DB) {
	migrate := false
	seed := false
	rollback := false

	for _, arg := range os.Args[1:] {
		if arg == "--migrate" {
			migrate = true
		}

		if arg == "--seed" {
			seed = true
		}

		if arg == "--rollback" {
			rollback = true
		}
	}

	if migrate {
		if err := migrations.Migrate(db); err != nil {
			log.Fatalf("error migrations: %v", err)
		}

		log.Println("migrations complete successfully")
	}

	if seed {
		if err := migrations.Seed(db); err != nil {
			log.Printf("error migration seeder: %v", err)
		}

		log.Println("migration seeder complete successfully")
	}

	if rollback {
		if err := migrations.Rollback(db); err != nil {
			log.Printf("error rollback: %v", err)
		}

		log.Println("rollback complete successfully")
	}
}
