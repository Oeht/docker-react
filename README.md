[![Docker Run](https://github.com/Oeht/docker-react/actions/workflows/ci.yml/badge.svg)](https://github.com/Oeht/docker-react/actions/workflows/ci.yml)

# React Dev Container Template (Docker + CRA, Hot Reload, zero Node on Host)

This template runs a React app **entirely in Docker**.  
🚀 **Hot reload** works out of the box, **no Node.js** is required on your host, and **`node_modules` stays in a Docker volume**.

## Features

- ⚡ Live reload / hot reload via bind mounts for `src/` and `public/`
- 🧰 Automatically bootstraps **Create React App** (CRA) on the first run inside the container
- 🧳 Keeps `node_modules` in a **named volume** — your host stays clean
- 🐳 Works on Linux, macOS, and Windows/WSL2

## Quickstart

Requirements: **Docker** + **Docker Compose v2**

```bash
# 1) Use this repository (clone or "Use this template")
# 2) Start the stack
docker compose up --build

# 3) Open the app in your browser
# http://localhost:3000
```

On the **first start**, the container scaffolds a new CRA app automatically. You should then see the React starter page.

## Project structure

```
.
├─ Dockerfile
├─ docker-compose.yml
├─ entrypoint.sh
├─ src/           # host folder, bind-mounted into the container
└─ public/        # host folder, bind-mounted into the container
```

## How it works

- The container owns the app under **/react-docker** (persisted in a Docker volume).
- On first start, `entrypoint.sh` scaffolds CRA in a **temporary directory** and copies only the necessary files into the app directory (avoids the “directory contains files that could conflict” error from CRA).
- `src/` and `public/` are **bound directly** into the app path — CRA sees your changes instantly.
- `node_modules` is stored in a **named volume**, so nothing spills onto your host.

## Common commands

```bash
# Start (rebuild if something changed)
docker compose up --build

# Shell into the container (to run npm commands etc.)
docker compose exec frontend sh

# Run tests (CRA):
docker compose exec frontend sh -lc "npm test"

# Create a production build:
docker compose exec frontend sh -lc "npm run build"

# Fully reset (stop containers and remove volumes)
docker compose down -v
```

## Configuration

- **Node version**: In `Dockerfile`, pin e.g. `node:20-alpine`.
- **Watch / hot reload** flags (in `docker-compose.yml`):
  ```yaml
  environment:
    - CHOKIDAR_USEPOLLING=true
    - CHOKIDAR_INTERVAL=200
    - WATCHPACK_POLLING=true
  ```

## Troubleshooting

**“The directory /react-docker contains files that could conflict”**  
CRA refuses to scaffold into a non-empty directory. This template scaffolds in a temp directory and copies only what’s needed. If you already have stale volumes, reset once:

```bash
docker compose down -v
docker compose up --build
```

**`react-scripts: not found`**  
Dependencies are missing. Install them inside the container:
```bash
docker compose exec frontend sh -lc "npm ci || npm install"
```

**Hot reload isn’t working**  
- Ensure `src/` and `public/` are mounted **directly** to `/react-docker/src` and `/react-docker/public`.
- Ensure the dev server starts **from `/react-docker`** (the entrypoint handles this).
- Verify that your changes reach the container:
  ```bash
  docker compose exec frontend sh -lc 'stat -c "%y %n" /react-docker/src/App.js'
  ```

## Contributing

Contributions are welcome!

1. **Fork** this repository
2. Create a branch: `git checkout -b feat/your-feature`  
   (or `fix/bug-xyz`, `chore/…`)
3. Develop & test locally:
   ```bash
   docker compose up --build
   docker compose exec frontend sh -lc "npm test"
   ```
4. Commit with clear messages, e.g. *feat: add Node 20 base image*
5. Open a **Pull Request** with a short description (motivation, changes, any breaking changes)

*Optional:* add Prettier/ESLint scripts or CI to your fork (or open a PR to improve this template).

## License

This template is released under the **MIT License** (see `LICENSE`).  
You are free to **use, copy, modify, fork,** and send **pull requests**.

---

## Appendix: Example `docker-compose.yml` (core snippet)

```yaml
services:
  frontend:
    container_name: frontend
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - react-app:/react-docker
      - ./src:/react-docker/src
      - ./public:/react-docker/public
      - node_modules:/react-docker/node_modules
    ports:
      - "3000:3000"
    environment:
      - CHOKIDAR_USEPOLLING=true
      - CHOKIDAR_INTERVAL=200
      - WATCHPACK_POLLING=true
    restart: unless-stopped

volumes:
  react-app:
  node_modules:
```
