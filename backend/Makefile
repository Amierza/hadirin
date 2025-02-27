dep:
	@go mod tidy

run:
	@go run main.go

build:
	@go build -o main main.go

run-build: build
	@./main

test:
	@go test -v ./tests

init-docker:
	@docker compose up -d --build

up:
	@docker-compose up -d

down:
	@docker-compose down

logs:
	@docker-compose logs -f

migrate:
	@go run main.go --migrate

seed:
	@go run main.go --seed

rollback:
	@go run main.go --rollback