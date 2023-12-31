DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

postgres:
	docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=root --owner=root simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

dropdb:
	docker exec -it postgres12 dropdb simple_bank

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

start:
	docker compose up -d

stop:
	docker compose down

dev:
	docker compose -f docker-compose.dev.yml up -d

stopdev:
	docker compose -f docker-compose.dev.yml down

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/shouta0715/simple-bank/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/distributor.go github.com/shouta0715/simple-bank/worker TaskDistributor

db_docs:
	dbdocs build doc/db.dbml

db_schme:
	dbml2sql --postgres -o doc/shema.sql doc/db.dbml

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
    --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
		--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
    proto/*.proto
		statik -src=./doc/swagger -dest=./doc 

evans:
	evans -r repl --host localhost --port 9090 -r repl

.PHONY: postgres createdb migrateup migratedown dropdb sqlc test server mock migratedown1 migrateup1 start stop dev db_docs db_schme proto evans  new_migration
