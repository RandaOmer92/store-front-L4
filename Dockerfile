   FROM node:24-alpine AS build-stage
   WORKDIR /app
   COPY package.json package-lock.json ./
   RUN npm ci
   COPY . .
   ARG VUE_APP_ORDER_SERVICE_URL=http://localhost:3000
   ARG VUE_APP_PRODUCT_SERVICE_URL=http://localhost:3030
   RUN npm run build

   FROM nginx:alpine
   COPY --from=build-stage /app/dist /usr/share/nginx/html
   EXPOSE 80
