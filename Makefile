# ============================================
# フルスタック開発用 Makefile
# React (Vite) + NestJS + PostgreSQL
# Docker Compose の操作をまとめて簡略化
# ============================================

DC = docker compose

ifneq (,$(wildcard .env))
include .env
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' .env)
endif

# --------------------------------------------
# 使用可能なコマンド一覧を表示
# --------------------------------------------

## コマンド一覧を表示（help）
help:
	@grep -E '(^[a-zA-Z_-]+:)|(^##)' Makefile | sed -e 's/:.*##/: ##/' | column -t -s '##'

# --------------------------------------------
# Docker の基本操作
# --------------------------------------------

## Docker イメージのビルド
build:
	$(DC) build

## コンテナの起動（バックグラウンド）
up:
	$(DC) up -d

## コンテナの停止・削除（ボリュームは残す）
down:
	$(DC) down

## 再起動（down → up）
restart:
	$(DC) down
	$(DC) up -d

## コンテナ状態の一覧表示
ps:
	$(DC) ps

## すべてのログを表示（リアルタイム）
logs:
	$(DC) logs -f

## backend（NestJS）のログのみ表示 logs-backend:
	$(DC) logs backend -f

## frontend（Vite）のログのみ表示
logs-frontend:
	$(DC) logs frontend -f

## db（PostgreSQL）のログのみ表示
logs-db:
	$(DC) logs db -f

## コンテナとボリュームを全削除
clean:
	$(DC) down -v --remove-orphans

# --------------------------------------------
# NestJS（backend）用コマンド
# --------------------------------------------

## npm install を実行
backend-install:
	$(DC) exec backend npm install

## ビルドを実行
backend-build:
	$(DC) exec backend npm run build

## NestJS の開発サーバーを起動
backend-dev:
	$(DC) exec backend npm run start:dev

## NestJS のテストを実行
backend-test:
	$(DC) exec backend npm run test


# --------------------------------------------
# React（frontend）用コマンド
# --------------------------------------------

## npm install を実行
frontend-install:
	$(DC) exec frontend npm install

## フロントエンドのビルド
frontend-build:
	$(DC) exec frontend npm run build

## Vite dev サーバーをコンテナ内で起動
frontend-dev:
	$(DC) exec frontend npm run dev


# --------------------------------------------
# PostgreSQL 用コマンド
# --------------------------------------------

## PostgreSQL CLI に接続
db-cli:
	$(DC) exec db psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}

## データベース一覧を表示
db-list:
	$(DC) exec db psql -U $${POSTGRES_USER} -c '\l'

## データベースを完全リセット（危険）
db-reset:
	$(DC) down -v
	$(DC) up -d


# --------------------------------------------
# コンテナ内に入るためのコマンド
# --------------------------------------------

## backend コンテナに入る
sh-backend:
	$(DC) exec backend sh

## frontend コンテナに入る
sh-frontend:
	$(DC) exec frontend sh

## db コンテナに入る
sh-db:
	$(DC) exec db sh
