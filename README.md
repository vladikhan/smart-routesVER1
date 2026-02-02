 Smart Routes
Travel route sharing platform for Osaka, Kyoto, and Nara. 大阪・京都・奈良向け旅行ルート共有プラットフォーム

 Overview / 概要
Smart Routes is a platform to create, share, and search for travel routes that combine sightseeing spots with local gourmet experiences. Smart Routesは、観光地とローカルグルメを組み合わせた旅行ルートを作成・共有・検索できるプラットフォームです。

 Key Features / 主な機能
AI Route Generation: Create routes based on city, preferences, and budget. (AIによるルート生成：都市・好み・予算を考慮)

Verified Routes: User-created and community-verified travel plans. (ユーザー作成＆検証済みルート)

Interactive Maps: Navigation powered by Google Maps API. (Google Maps API連動ナビゲーション)

Social Features: Follow, save, and messaging functionality. (フォロー・保存・メッセージ機能)

 Tech Stack / 技術スタック
Backend: Ruby on Rails (Trailblazer), PostgreSQL, Redis

Infrastructure: Docker, AWS (EC2, RDS, S3, Route53)

CI/CD: Docker-based deployment

How to Run with Docker / Dockerでの起動方法
1. Prerequisites / 前提条件
Docker & Docker Compose installed.

2. Setup Environment / 環境設定
Create a .env file in the root directory and add your keys (Refer to .env.example): ルートディレクトリに.envファイルを作成し、キーを追加してください（.env.exampleを参照）:

Bash

GOOGLE_MAPS_API_KEY=your_api_key_here
DATABASE_URL=postgres://postgres:password@db:5432/smart_routes_dev
3. Build and Start / ビルドと起動
Bash

docker-compose up --build
The app will be available at http://localhost:3000.

Deployment / デプロイ
The project is deployed using a custom shell script that manages Docker containers on the server. 本プロジェクトは、サーバー上のDockerコンテナを管理するカスタムシェルスクリプトを使用してデプロイされています。