# Smart Routes 🗺️
**Travel route sharing platform for Osaka, Kyoto, and Nara**
大阪・京都・奈良向け旅行ルート共有プラットフォーム

## Overview / 概要

Smart Routes lets travelers create, share, and discover routes combining sightseeing spots with local food experiences across Kansai region.
観光地とローカルグルメを組み合わせた旅行ルートを作成・共有・検索できるプラットフォームです。

> 🚧 Currently migrating from Rails monolith → Rails API + Next.js frontend

---

## Architecture / アーキテクチャ

smart-routes-frontend/ # Next.js 16 (App Router, TypeScript, Tailwind v4)
smartRoutesReact/ # Rails 6.1 Pure API (Trailblazer, PostgreSQL, Redis)


**Frontend** → SSR/SEO-optimized pages, JWT auth via httpOnly cookies
**Backend** → JSON API, Trailblazer operations, Devise JWT

---

## Key Features / 主な機能

- 🤖 **AI Route Generation** — routes based on city, preferences, and budget
- ✅ **Verified Routes** — community-created and verified travel plans
- 🗺️ **Interactive Maps** — Google Maps API navigation
- 👥 **Social Features** — follow, bookmark, messaging, reviews

---

## Tech Stack / 技術スタック

| Layer | Tech |
|---|---|
| Frontend | Next.js 16, TypeScript, Tailwind CSS v4 |
| Backend | Ruby on Rails 6.1, Trailblazer 2.x |
| Database | PostgreSQL 15 |
| Cache/Jobs | Redis 7, Sidekiq |
| Auth | Devise + JWT |
| Maps | Google Maps API |
| Infrastructure | Docker, AWS (EC2, RDS, S3, Route53) |
| CI/CD | Docker-based deployment |

---

## Getting Started / 起動方法

### Prerequisites
- Docker & Docker Compose
- Ruby 3.1.4 (rbenv)
- Node.js 18+

### 1. Environment setup

```bash
cp .env.example .env
# Fill in your keys:
# GOOGLE_MAPS_API_KEY=
# SECRET_KEY_BASE=
# DEVISE_JWT_SECRET_KEY=
```

### 2. Run with Docker (recommended)

```bash
docker-compose up --build
```

- Rails API → http://localhost:3000
- Next.js frontend → http://localhost:3001

### 3. Run locally (development)

```bash
# Terminal 1 — Backend
docker-compose up -d db redis
cd smartRoutesReact
DISABLE_SPRING=1 REDIS_URL=redis://localhost:6379/0 rails server -p 3000

# Terminal 2 — Frontend
cd smart-routes-frontend
npm run dev  # runs on port 3001
```

### 4. Database setup

```bash
cd smartRoutesReact
DISABLE_SPRING=1 rails db:migrate
REDIS_URL=redis://localhost:6379/0 DISABLE_SPRING=1 rails db:seed
```

---

## API Endpoints / APIエンドポイント

| Method | Path | Description |
|---|---|---|
| GET | /api/v1/venues | List venues |
| GET | /api/v1/venues/:id | Venue detail |
| GET | /api/v1/routes | List routes |
| GET | /api/v1/cities | List cities |
| POST | /api/v1/login | JWT login |
| DELETE | /api/v1/logout | JWT logout |

---

## Deployment / デプロイ

Deployed via custom shell script managing Docker containers on AWS EC2.
AWS EC2上のDockerコンテナをカスタムシェルスクリプトで管理してデプロイしています。

```bash
./deploy.sh
```

---

## Project Status / 進捗

- [x] Rails API namespace + venues endpoint
- [x] Next.js SSR frontend with venues page
- [ ] JWT authentication
- [ ] Routes pages
- [ ] Google Maps integration
- [ ] AI route generation
