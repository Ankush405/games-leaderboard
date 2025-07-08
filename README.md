# Game Leaderboard System

## Overview
A gaming leaderboard system for multiplayer/competitive games, built with Ruby on Rails. It tracks and displays player performance, allowing users to submit scores, view the top 10 leaderboard, and check their own rank. The system is optimized for performance and concurrency.

---

## Features
- **Submit Score:** Players submit scores after each game session.
- **Leaderboard:** View the top 10 players, sorted by total score.
- **Player Rank:** Check a specific player's current rank.
- **Frontend UI:** Simple Rails views for leaderboard, score submission, and rank checking.
- **API:** RESTful endpoints for all core features.
- **Caching:** Uses Rails memory store for fast leaderboard/rank queries.
- **Performance:** Database indexes and atomic updates for high concurrency.
- **RSpec Tests:** Model, controller, view, and API request specs included.

---

## Data Model

```
users (id, username, join_date)
game_sessions (id, user_id, score, game_mode, timestamp)
leaderboards (id, user_id, total_score, rank)
```

---

## Setup

1. **Clone the repo and install dependencies:**
   ```sh
   bundle install
   ```
2. **Set up the database:**
   ```sh
   rails db:setup
   # or, if you already have a db: rails db:migrate
   ```
3. **Start the Rails server:**
   ```sh
   rails server
   ```
4. **(Optional) Start Redis if you want to use Redis for caching:**
   ```sh
   brew install redis
   brew services start redis
   # Then update config/environments/development.rb to use :redis_cache_store
   ```

---

## API Endpoints

### Submit Score
- **POST** `/api/leaderboard/submit`
- Params: `user_id`, `score`, `game_mode` (optional)
- Example:
  ```sh
  curl -X POST http://localhost:3000/api/leaderboard/submit -d 'user_id=1&score=100'
  ```

### Get Leaderboard
- **GET** `/api/leaderboard/top`
- Returns top 10 players by total score.

### Get Player Rank
- **GET** `/api/leaderboard/rank/:user_id`
- Returns the rank and total score for the given user.

---

## Frontend (Rails Views)
- **Leaderboard:** `/leaderboard/index` (auto-refreshes every 10 seconds)
- **Submit Score:** `/leaderboard/submit_score`
- **Check Rank:** `/leaderboard/show_rank?user_id=YOUR_ID`

---

## Caching
- Uses Rails memory store by default for leaderboard and rank API responses.
- To use Redis, add `redis` and `redis-rails` gems, update `config/environments/development.rb`, and start Redis.
- Cache is invalidated automatically when scores are submitted.

---

## Performance & Concurrency
- **Indexes:**
  - `leaderboards.user_id` (unique)
  - `leaderboards.total_score`
  - `game_sessions.user_id`
- **Atomic Updates:**
  - Leaderboard score updates use row-level locking to prevent race conditions.
- **Efficient Queries:**
  - Top 10 and rank queries are indexed and cached.

---

## Testing
- **Run all tests:**
  ```sh
  bundle exec rspec
  ```
- **Test coverage:**
  - Models: associations, validations, dependent destroys
  - Controllers: API and view-based
  - Views: leaderboard and rank rendering
  - API: request specs for all endpoints

---

## Example Usage

1. **Create a user:**
   ```sh
   rails c
   User.create!(username: "player1")
   ```
2. **Submit a score:**
   ```sh
   curl -X POST http://localhost:3000/api/leaderboard/submit -d 'user_id=1&score=100'
   ```
3. **View leaderboard:**
   - Visit [http://localhost:3000/leaderboard/index](http://localhost:3000/leaderboard/index)
4. **Check rank:**
   - Visit [http://localhost:3000/leaderboard/show_rank?user_id=1](http://localhost:3000/leaderboard/show_rank?user_id=1)

---

## Notes
- The leaderboard auto-refreshes every 10 seconds.
- All data is stored in PostgreSQL by default.
- For production, consider using Redis for caching and background jobs for heavy rank recalculation.

---

## License
MIT
