# syntax=docker/dockerfile:1.7
# ============================================================
# Stage 1: build static React bundle
# ============================================================
FROM node:20.18.1-alpine AS build
WORKDIR /app

# Cache npm install layer
COPY package*.json ./
RUN npm ci --no-audit --no-fund

# Build static assets (REACT_APP_API_URL is read at build time)
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY . .
RUN npm run build

# ============================================================
# Stage 2: nginx serves built static files
# ============================================================
FROM nginx:1.27-alpine

# wget for HEALTHCHECK
RUN apk add --no-cache wget

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost/healthz || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]