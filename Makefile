.PHONY: up down logs shell-db shell-api

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f api

shell-db:
	docker compose exec db psql -U appuser -d rando

shell-api:
	docker compose exec api bash