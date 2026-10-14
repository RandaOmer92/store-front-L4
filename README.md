# Store Front

The Vue application loads the product catalog and submits orders. It retains Lab 2's `VUE_APP_*` configuration and Lab 1's development WebSocket setting for access through an Azure VM's public IP.

## Requirements

- Node.js 24 LTS and npm (`.nvmrc` selects 24 when using nvm)
- Product and Order APIs reachable from your browser

Install Node.js 24 using the earlier lab instructions. If using nvm, run `nvm install` and `nvm use` from this repository. Vue CLI is already a local dependency; run its commands through npm scripts.

## Local Setup

Run commands from this repository root:

```bash
npm ci
cp .env.example .env
```

Configure `.env` before starting:

```dotenv
VUE_APP_ORDER_SERVICE_URL=http://localhost:3000
VUE_APP_PRODUCT_SERVICE_URL=http://localhost:3030
```

Use base URLs without trailing slashes; the application appends `/orders` and `/products`. For an Azure VM, replace localhost with each API's public IP. The API requests run in your laptop's browser, so Docker service names and a remote VM's localhost cannot identify those APIs.

These values are public and visible in the browser bundle. Keep RabbitMQ credentials in the Order Service configuration.

```bash
npm run serve
```

Open `http://localhost:8080` locally, or `http://<STORE-VM-PUBLIC-IP>:8080` for an Azure VM. On Azure, allow TCP 8080 for the website and TCP 3000/3030 on the API VMs from your laptop's public IP. The development WebSocket uses the browser's address automatically.

Changing `.env` requires restarting the development server. Local environment files are ignored by Git; commit `.env.example`, `package.json`, and `package-lock.json`.

## Verification and Production Build

```bash
npm run lint -- --no-fix
npm run build
```

The build writes static files to `dist/`. Select Dog Food and enter quantity 2 in the browser: the total should be $39.98. Place the order, then verify that the durable RabbitMQ queue's message count increases. A successful response means the order was queued; the lab has no consumer that fulfills it.

## Lab 5 Containers

Create the multi-stage Dockerfile from Lab 5. Install with `npm ci` on Node.js 24 and build the application, then serve `dist/` with Nginx.

Vue CLI embeds `VUE_APP_*` variables at build time. The lab Dockerfile accepts Docker build arguments for both API URLs, and Compose passes them through `build.args`. The supplied `.dockerignore` excludes local `.env` files, so those build arguments are the configuration source for Docker builds.

Use localhost URLs for local Docker, or your API VM's public IP for a VM deployment. Rebuild after changing the URLs:

```bash
docker compose up -d --build
```

Run that command from the parent directory containing the Compose file. Setting `VUE_APP_*` in an already-built Nginx container does not change its JavaScript bundle. Images pulled from Docker Hub retain the API URLs used when they were built.

## Dependency Baseline

Vue 3.5.44, core-js 3.50.0, and Vue CLI 5.0.9 are recorded in the refreshed lockfile. Vue CLI is in maintenance mode and its development/build dependencies still have npm audit findings. The refreshed production dependencies passed `npm audit --omit=dev`; the complete tooling dependency tree is not free of advisories. A future Vite migration can modernize the tooling separately from this Docker lab.

[Vue CLI status](https://cli.vuejs.org/) · [Vue environment variables](https://cli.vuejs.org/guide/mode-and-env.html#environment-variables)
