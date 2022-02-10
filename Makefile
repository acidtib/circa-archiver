run: docker.dev.run docker.dev.logs

docker.dev.run:
	docker-compose up --build -d

docker.dev.logs:
	docker-compose logs -f

db.create:
	docker-compose run --rm web bundle exec rails db:create

db.migrate:
	docker-compose run --rm web bundle exec rails db:migrate

db.seed:
	docker-compose run --rm web bundle exec rails db:seed

db.rollback:
	docker-compose run --rm web bundle exec rails db:rollback STEP=1

docker.dev.console:
	docker-compose run --rm web bundle exec rails c

prod.build:
	docker-compose -f docker-compose.prod.yml build

prod.logs:
	docker-compose -f docker-compose.prod.yml logs --follow

prod.run:
	docker-compose -f docker-compose.prod.yml up -d

prod.console:
	docker-compose -f docker-compose.prod.yml run --rm web bundle exec rails c