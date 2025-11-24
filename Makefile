SHELL=/bin/bash

.PHONY: import-faq

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)

# -- Start Docker
start:
	@docker compose up -d

stop:
	@docker compose down

restart: stop start

# -- Start Environment
build: stop
	@docker compose build --pull

build\:no-cache: stop
	@docker compose build --pull --no-cache

pint:
	@docker ./vendor/bin/pint

cache:
	@bin/artisan cache:clearall

telescope:
	@bin/artisan telescope:install

db: start
	@sleep 1s
	@bin/artisan db:wipe
	@bin/artisan migrate

db\:test: start
	@sleep 1s
	@bin/artisan db:wipe --env=test
	@bin/artisan migrate --env=test

install: start db rights
	@sleep 1s
	@bin/composer install
	@npm i

fixture: db
	@bin/artisan db:seed

rights: start
	@sudo chmod -R 777 storage
	@sudo chmod -R 777 bootstrap/cache
	@sudo chown -R ${CURRENT_UID}:${CURRENT_GID} ./

# Nettoyer les données de visites
clean-visits:
	@bin/artisan visits:clean

# Nettoyer les données de visites plus anciennes que X jours
clean-old-visits:
	@bin/artisan visits:clean --days=30

# Commande qui combine plusieurs nettoyages
clean-all: clean-visits
	@echo "✓ Nettoyage terminé"

# Installation des dépendances Composer
install-composer:
	@echo "🚀 Installation des dépendances Composer..."
	@composer install
	@echo "✓ Dépendances Composer installées"

# Installation des dépendances NPM
install-npm:
	@echo "🚀 Installation des dépendances NPM..."
	@npm install
	@echo "✓ Dépendances NPM installées"

# Nettoyage des répertoires et fichiers temporaires
clean:
	@echo "🧹 Nettoyage des fichiers temporaires..."
	@rm -rf node_modules
	@rm -rf vendor
	@rm -rf bootstrap/cache/*.php
	@rm -rf storage/framework/cache/*
	@rm -rf storage/framework/sessions/*
	@rm -rf storage/framework/views/*
	@rm -rf storage/logs/*
	@rm -rf public/hot
	@rm -rf public/storage
	@rm -f composer.lock
	@rm -f package-lock.json
	@echo "✓ Nettoyage terminé"

# Installation complète (composer + npm + nettoyage)
install-all: clean install-composer install-npm
	@echo "✨ Installation complète terminée"

# Reset database and migrations
db\:reset: start
	@echo "🔄 Réinitialisation de la base de données..."
	@bin/artisan migrate:fresh
	@echo "✓ Base de données réinitialisée"

import-faq:
	@bin/artisan faq:import-markdown