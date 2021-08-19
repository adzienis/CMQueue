prod_server_id:=docker ps | grep production_server | sed 's/ .*//'

# make all these be phony

###############################################

# LOAD ENV CONFIG

-include .env.dev
-include .env.test
-include .env.prod

load_dev_env: 
	@export $(shell cat .env.dev)
load_prod_env: 
	@export $(shell cat .env.prod)
load_test_env: 
	@export $(shell cat .env.test)

###############################################

# PRODUCTION COMMANDS
run_prod:
	docker-compose -p production -f docker-compose.prod.yml up --force-recreate --remove-orphans
stop_prod:
	docker-compose -p production stop
down_prod:
	docker-compose -p production down
build_prod:
	docker-compose -p production -f docker-compose.prod.yml build
console_prod:
	docker exec -it $(shell ${prod_server_id}) bash -c "bundle exec rails c"
deploy:
	git rebase master production && \
	git checkout master && \
	git push origin production --force  

###############################################

# DEVELOPMENT COMMANDS
run_dev:
	docker-compose -p development up --force-recreate --remove-orphans
stop_dev:
	docker-compose -p development stop
down_dev:
	docker-compose -p development down
console_dev:
	cd OH-Queuing-Server; bundle exec rails c
server_dev:
	cd OH-Queuing-Server; bundle exec rails s --binding=0.0.0.0
migrate_dev:
	cd OH-Queuing-Server; bundle exec rails db:migrate

###############################################

# TEST COMMANDS
run_test:
	docker-compose -p test -f docker-compose.test.yml up --force-recreate --remove-orphans
stop_test:
	docker-compose -p test stop
down_test:
	docker-compose -p test down

###############################################

# UTILITY

kill_server:
	kill -s SIGKILL $(shell cat ./tmp/pids/server.pid)
