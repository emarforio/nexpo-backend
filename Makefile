# This file contains all commands needed to start your dev environment!

.PHONY: fresh-install-linux install-mac install-linux install-deps reset-db create-db-user

create-db-user:
	psql -c "CREATE USER nexpo PASSWORD 'nexpo' CREATEDB;"

reset-db:
	psql -c "DROP DATABASE IF EXISTS nexpo_dev;"
	psql -c "DROP DATABASE IF EXISTS nexpo_test;"
	psql -c "DROP USER IF EXISTS nexpo;"

install-deps:
	mix local.hex --force && \
	mix local.rebar --force && \
	wget https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez && \
	mix archive.install --force ./phoenix_new.ez && \
	rm ./phoenix_new.ez && \
	npm run install-deps && \
	mkdir -p $(HOME)/.s3bucket/nexpo-test && \
	mix ecto.setup

install-linux: create-db-user install-deps

install-mac: install-deps

fresh-install-linux: reset-db create-db-user install-deps
