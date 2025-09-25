FROM node:20-bullseye-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps --no-audit --no-fund
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:stable-alpine

WORKDIR /usr/share/nginx/html
COPY --from=builder /app/build .

# copy entrypoint dan pastikan executable
COPY entrypoint.sh /entrypoint.sh
USER root
RUN chmod +x /entrypoint.sh
USER 101

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
