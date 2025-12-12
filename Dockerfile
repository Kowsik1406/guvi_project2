# -------------------------------
# Stage 1: Build React app
# -------------------------------
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy all source files
COPY . .

# -------------------------------
# Stage 2: Serve with Nginx
# -------------------------------
FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from builder stage
COPY --from=builder /app/dist/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]