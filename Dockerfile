# Build stage for dependencies
FROM oven/bun:1-alpine AS base
WORKDIR /app
COPY package.json bun.lockb* ./

FROM base AS prod-deps
RUN bun install --production --frozen-lockfile \
    && rm -rf /tmp/* /root/.bun

FROM base AS build-deps
RUN bun install --frozen-lockfile

FROM build-deps AS build
COPY . .
RUN bun run build \
    && rm -rf src .astro \
    && find . -name "*.ts" -delete \
    && find . -name "*.tsx" -delete

# Production stage
FROM oven/bun:1-alpine AS runtime
WORKDIR /app

# Add non-root user
RUN addgroup -g 1001 nodejs \
    && adduser -S appuser -u 1001

# Copy necessary files
COPY --from=prod-deps --chown=appuser:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=appuser:nodejs /app/dist ./dist
COPY --from=build --chown=appuser:nodejs /app/package.json ./package.json
COPY --from=build --chown=appuser:nodejs /app/bun.lockb* ./bun.lockb

# Set permissions
RUN chown -R appuser:nodejs /app && chmod -R 755 /app

USER appuser

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl --fail http://localhost:4321/health || exit 1

CMD node ./dist/server/entry.mjs