FROM nginx:alpine

# Copy the Nginx configuration file
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Note: We don't need to copy export files here
# They will be mounted as a volume in docker-compose.yml

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
