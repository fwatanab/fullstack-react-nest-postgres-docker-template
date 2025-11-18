# React (Vite) + NestJS + PostgreSQL Docker テンプレート

フロントエンド (Vite/React)・バックエンド (NestJS)・DB (PostgreSQL) を Docker Compose で横断的に起動できるテンプレートです。`Makefile` によってよく使うコマンドを短縮しているため、フロント／バックエンド双方のセットアップや確認を素早く行えます。

## サービス構成

| サービス | 役割 | 主なポート |
| --- | --- | --- |
| frontend | Vite の開発サーバー | `5173` |
| backend | NestJS (npm run start:dev) | `3000` |
| db | PostgreSQL 15 | `5432` |

## 前提条件

- Docker Desktop もしくは Docker Engine + Docker Compose v2
- `make` が利用できる環境 (macOS / Linux / WSL)

## セットアップ手順

1. **環境変数の確認**  
   - ルートの `.env` に PostgreSQL の接続情報を記述しています。必要に応じて `POSTGRES_PASSWORD` などを変更してください。  
   - `backend/.env` は NestJS アプリ側の環境変数です。API ポートや DB 情報を上記と揃えてください。
2. **依存パッケージのインストール**  
   ```bash
   make frontend-install
   make backend-install
   ```
   それぞれのコンテナ内で `npm install` が走り、ソースと同期された volume (`./frontend`, `./backend`) に対して `node_modules` が作成されます。
3. **ビルド & 起動**  
   ```bash
   make build
   make up
   ```
   ブラウザで `http://localhost:5173` を開くとフロントエンド、`http://localhost:3000` で NestJS API を確認できます。ログを確認したい場合は `make logs` または `make logs-frontend` / `make logs-backend` を使用します。
4. **停止/再起動**  
   - 停止: `make down`
   - 再起動: `make restart`

## テスト方法

- **バックエンドのユニットテスト**  
  ```bash
  make backend-test
  ```
  → `npm run test` が実行され、NestJS のテストスイートが走ります。E2E テストなど別スクリプトを用意した場合は `docker compose exec backend npm run test:e2e` などで呼び出してください。

- **フロントエンドのテスト**  
  Vite プロジェクトで Vitest 等を導入している場合は:
  ```bash
  docker compose exec frontend npm run test
  ```
  template にはテストフレームワークの依存は含まれていないため、お好みのテスティングツールを `package.json` に追加してください。画面の動作確認は `make frontend-dev` でホットリロード環境を起動し、ブラウザから手動で行うのが簡単です。

## データベース操作

- `make db-cli` : PostgreSQL CLI (`psql`) に接続  
- `make db-list` : DB 一覧表示 (`\l`)  
- `make db-reset` : ボリューム付きで `docker compose down -v` → `up -d` を実行し、データをリセット  

DB のデータは `docker/db/data` に永続化されます。テンプレートをクリーンに保ちたい場合や不要になった場合はデータディレクトリを削除してください。

## コンテナへのシェルアクセス

```
make sh-frontend   # frontend コンテナ
make sh-backend    # backend コンテナ
make sh-db         # db コンテナ
```

それぞれ `sh` で入れるため、依存の確認や手動操作が必要な場合に便利です。

## メンテナンス

- 使わなくなったボリューム／イメージをまとめて掃除したい場合は `make clean` (`docker system prune -a --volumes -f`) を利用してください。
- テンプレートをプロジェクトにコピーした後は、`README.md` や `.env` の値をプロジェクト固有の内容に調整することを推奨します。

このテンプレートを Git リポジトリに追加し、上記のコマンド群でサーバーが立ち上がることを確認した上で運用を開始してください。Docker 上でフルスタック開発を行う際のベースとして活用できます。
