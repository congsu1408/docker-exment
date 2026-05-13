mysql-up:
	docker compose -f docker-compose.yml -f docker-compose.mysql.yml up -d
mariadb-up:
	docker compose -f docker-compose.yml -f docker-compose.mariadb.yml up -d
sqlsrv-up:
	docker compose -f docker-compose.yml -f docker-compose.sqlsrv.yml up -d
php:
	docker compose  -f docker-compose.yml exec php bash
down:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml  down
destroy:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml down --rmi all --volumes --remove-orphans
ps:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml ps
logs:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml logs
exec:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml exec
logs-watch:
	docker compose logs --follow
mysql-init:
	@make down
	@make mysql-up
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.mysql .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force

mariadb-init:
	@make down
	@make mariadb-up
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.mariadb .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force

sqlsrv-init:
	@make down
	@make sqlsrv-up
	@make ps
	@make logs
	sleep 30
	docker compose -f docker-compose.yml -f docker-compose.sqlsrv.yml run -T sqlsrv-create-db
	@make ps
	@make logs
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.sqlsrv .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force
