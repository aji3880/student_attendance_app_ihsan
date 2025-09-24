FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --silent; else npm install --silent; fi

COPY . .
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN npm run build

FROM nginxinc/nginx-unprivileged:stable-alpine

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD wget -qO- --tries=1 --timeout=2 http://127.0.0.1:8080/ || exit 1

EXPOSE 8080