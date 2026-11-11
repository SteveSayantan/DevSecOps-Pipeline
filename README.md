# Wanderlust

Wanderlust is a full-stack blogging application with a React/Vite frontend and
an Express/TypeScript backend. MongoDB stores application data and Redis
provides caching for post queries. Google OAuth is available for authentication.

## Architecture

| Component | Technology | Local address | Docker address |
| --- | --- | --- | --- |
| Frontend | React, Vite, Nginx | http://localhost:5173 | http://localhost |
| Backend API | Node.js, Express, TypeScript | http://localhost:8080 | http://localhost:8000 |
| Database | MongoDB | `localhost:27017` | Compose service `db:27017` |
| Cache | Redis | `localhost:6379` | Compose service `redis:6379` |

## Prerequisites

For local development, install:

- Node.js 20 or newer and npm
- MongoDB 7 or newer
- Redis 7 or newer
- Git

For Docker, install Docker Desktop (Windows/macOS) or Docker Engine and the
Docker Compose plugin (Linux).

## Environment variables

The application does not commit environment files. Create the files below
before starting the application. Do not commit credentials or OAuth secrets.

### Backend: `backend/.env`

The same file is read by the backend during local development and by the
backend and MongoDB containers when using Compose.

```dotenv
# Server
PORT=8080
NODE_ENV=Development

# MongoDB
# Use localhost for local development and db when running with Docker Compose.
MONGO_HOST=localhost
MONGO_INITDB_DATABASE=wanderlust
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=change-this-root-password
APP_MONGO_USER=wanderlust-app
APP_MONGO_PASS=change-this-app-password

# Redis
# Use localhost for local development and redis when running with Docker Compose.
REDIS_HOST=localhost

# URLs used for CORS and Google OAuth callbacks
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:8080

# Authentication and cookies
JWT_SECRET=replace-with-a-long-random-secret
ACCESS_COOKIE_MAXAGE=3600000
REFRESH_COOKIE_MAXAGE=604800000
ACCESS_TOKEN_EXPIRES_IN=1h
REFRESH_TOKEN_EXPIRES_IN=7d

# Google OAuth
# Required only when Google sign-in is enabled.
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

`MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` initialize the
MongoDB root account. `APP_MONGO_USER` and `APP_MONGO_PASS` create the
restricted application account. 

>The application database user is created in `MONGO_INITDB_DATABASE`, so the generated MongoDB connection string includes `?authSource=<MONGO_INITDB_DATABASE>`. Omitting it causes MongoDB authentication to fail.

For a local installation, use `MONGO_HOST=localhost`, `REDIS_HOST=localhost`,
`FRONTEND_URL=http://localhost:5173`, and `BACKEND_URL=http://localhost:8080`.
For Docker Compose, use `MONGO_HOST=db`, `REDIS_HOST=redis`,
`FRONTEND_URL=http://localhost`, and `BACKEND_URL=http://localhost:8000`.

### Frontend: `frontend/.env`

`VITE_API_PATH` is read by Vite while the frontend is built. It must contain
the public base URL of the backend API and should not include a trailing slash.

```dotenv
VITE_API_PATH=http://localhost:8080
```

Use `http://localhost:8000` when the frontend is built for the Docker Compose
deployment.

## Local installation

1. Clone the repository and enter the project directory:

   ```bash
   git clone https://github.com/SteveSayantan/DevOps-Bootcamp.git
   cd DevOps-Bootcamp/DevSecOps-Pipeline
   ```

2. Create `backend/.env` and `frontend/.env` using the examples above. For
   local development, use the local host values.

3. Make sure MongoDB and Redis are running on their default ports
   (`27017` and `6379`).

4. Install all dependencies:

   ```bash
   npm run installer
   ```

   This installs the root, backend, and frontend dependencies.

5. Seed the sample posts from a second terminal after the backend dependencies
   are installed:

   ```bash
   cd backend
   node --import tsx seed-db.js
   ```

   If your Node.js version does not support `--import tsx`, run the seed script
   through the project tooling:

   ```bash
   npx tsx seed-db.js
   ```

6. Start the frontend and backend together from the project root:

   ```bash
   npm start
   ```

7. Open the frontend at http://localhost:5173. The backend health response is
   available at http://localhost:8080/.

To run either service separately:

```bash
npm run start-backend
npm run start-frontend
```

The backend development command uses `nodemon` and serves on the `PORT`
specified in `backend/.env`. The frontend development server uses Vite.

## Docker installation

1. Create `backend/.env` and `frontend/.env` before building. For Compose,
   configure the backend values as follows:

   ```dotenv
   PORT=8080
   NODE_ENV=Development
   MONGO_HOST=db
   MONGO_INITDB_DATABASE=wanderlust
   MONGO_INITDB_ROOT_USERNAME=admin
   MONGO_INITDB_ROOT_PASSWORD=change-this-root-password
   APP_MONGO_USER=wanderlust-app
   APP_MONGO_PASS=change-this-app-password
   REDIS_HOST=redis
   FRONTEND_URL=http://localhost
   BACKEND_URL=http://localhost:8000
   JWT_SECRET=replace-with-a-long-random-secret
   ACCESS_COOKIE_MAXAGE=3600000
   REFRESH_COOKIE_MAXAGE=604800000
   ACCESS_TOKEN_EXPIRES_IN=1h
   REFRESH_TOKEN_EXPIRES_IN=7d
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

   Set the frontend value to:

   ```dotenv
   VITE_API_PATH=http://localhost:8000
   ```

   `VITE_API_PATH` is copied into the static frontend bundle during the Docker
   image build. Changing only the Compose `env_file` after the image has been
   built does not change the bundle; rebuild the frontend image after changing
   this value.

2. Build and start all services:

   ```bash
   docker compose up --build -d
   ```

   Compose starts the frontend, backend, MongoDB, and Redis services. MongoDB
   and Redis data are stored in the named volumes `mongo-data`,
   `mongo-config`, and `redis-data`.

3. Seed the sample posts:

   ```bash
   docker compose exec backend node seed-db.js
   ```

4. Open the application at http://localhost. The backend is exposed at
   http://localhost:8000.

Useful Docker commands:

```bash
# Follow application logs
docker compose logs -f frontend backend

# Check service status
docker compose ps

# Stop containers without deleting data
docker compose down

# Stop containers and delete the named database/cache volumes
docker compose down -v

# Seed the Database
docker compose exec backend node seed-db.js
# Clear cached post lists
docker compose exec redis redis-cli UNLINK post-cache:all-posts post-cache:featured-posts post-cache:latest-posts
```

If MongoDB credentials or the database name change after the first Compose
startup, remove the existing MongoDB volumes before starting again so the
initialization script can create the new user:

```bash
docker compose down
docker volume ls
docker compose down -v
docker compose up --build -d
```

The `down -v` command deletes persisted MongoDB and Redis data.

## Testing and quality checks

### Backend Tests

Inside the `backend` directory,

| Script      | Tests Executed | Main Purpose |
| ----------- | -------------- | ------------ |
| `npm test`  | Unit and Integration tests | General local test command for verbose output and combined coverage report |
| `npm run test:ci`   | Unit and Integration tests | Non-interactive CI execution with non-verbose output and combined coverage report |
| `npm run test:unit`   | Unit tests | Only unit tests in CI mode with its coverage report, does not require MongoDB, Redis |
| `npm run test:ci`   | Integration tests | Only integration tests in CI mode with its coverage report, requires live MongoDB, Redis |

**Important Flags**
- `--experimental-vm-modules`: enables Jest’s ESM support for the `"type": "module"` project.
- `--runInBand`: runs tests sequentially in one process instead of in parallel.
- `--detectOpenHandles`: helps identify resources preventing Jest from exiting.
- `--verbose`: displays individual test names.
- `--coverage`: generates coverage reports

> Running unit and integration tests separately may cause each run to regenerate the coverage directory. If the goal is one combined coverage report, use `npm run test:ci`. Alternatively, unit and integration coverage reports would need to be merged explicitly.

## Frontend Tests

```bash
cd frontend
npm test    # or, `npm run coverage` for both test & coverage report
npm run lint
```

## Troubleshooting

- **MongoDB `AuthenticationFailed`:** verify `MONGO_HOST`, the application
  username/password, and that the connection uses
  `authSource=wanderlust` (the backend adds this from
  `MONGO_INITDB_DATABASE`). With Docker, use `db`, not `localhost`.
- **Redis connection errors:** verify that Redis is running and that
  `REDIS_HOST` is `localhost` locally or `redis` in Compose.
- **Frontend cannot reach the API:** verify `VITE_API_PATH`, rebuild the
  frontend after changing it, and ensure the backend is listening on the
  expected port.
- **Google sign-in fails:** verify the Google client credentials and register
  `${BACKEND_URL}/api/auth/google/callback` as an authorized redirect URI in
  Google Cloud Console.
- **Cookies are not sent in local development:** use `NODE_ENV=Development`
  for local HTTP testing. Production HTTPS deployments should use a production
  value so secure cookies are enabled.

## Project layout

```text
backend/             Express API, MongoDB models, Redis services, seed script
frontend/            React/Vite client
docker-compose.yaml  Local container orchestration
terraform/           Infrastructure definitions
```
