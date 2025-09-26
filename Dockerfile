FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN apk add --no-cache python3 make g++ \
    && npm install --legacy-peer-deps --silent

COPY . .
RUN npm run build

FROM nginx:stable-alpine

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx /tmp/nginx \
    && chmod -R 777 /var/cache/nginx /var/run /var/log/nginx /tmp/nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
