FROM oven/bun:1-alpine

WORKDIR /app

# Copy package files
COPY package*.json bun.lockb* bun.lock ./

# Install all dependencies (including dev for build)
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Build TypeScript
RUN bun run build

# Remove dev dependencies after build
RUN bun install --frozen-lockfile --production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Start the application
CMD ["bun", "run", "start"]