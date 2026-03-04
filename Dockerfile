# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY nx.json ./
COPY tsconfig.base.json ./

# Copy source code
COPY apps ./apps
COPY libs ./libs
COPY tools ./tools

# Install dependencies
RUN npm ci

# Build the arrows-ts app (the main app as defined in package.json build script)
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install serve to run the built app
RUN npm install -g serve

# Copy only necessary files from builder
COPY --from=builder /app/dist/apps/arrows-ts ./dist

# Expose port (matches vite preview port)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Start the app
CMD ["serve", "-s", "dist", "-l", "3000"]
