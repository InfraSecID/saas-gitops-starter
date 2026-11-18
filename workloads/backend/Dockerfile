# workloads/backend/Dockerfile — Multi-stage Dockerfile dengan image di-pin dan non-root user
# Stage 1: Build TypeScript ke JavaScript
FROM node:20.12.2-alpine3.19 AS builder
WORKDIR /app

COPY package.json ./
RUN npm install --ignore-scripts

COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

# Stage 2: Runtime image minimal dan aman
FROM node:20.12.2-alpine3.19 AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Buat non-root group dan user eksplisit (UID/GID 10001)
RUN addgroup -g 10001 -S appgroup && adduser -u 10001 -S appuser -G appgroup

COPY --from=builder --chown=10001:10001 /app/package.json ./package.json
COPY --from=builder --chown=10001:10001 /app/node_modules ./node_modules
COPY --from=builder --chown=10001:10001 /app/dist ./dist

USER 10001:10001
EXPOSE 3000

CMD ["node", "dist/index.js"]
