# Use the official Nginx image as base
FROM nginx:alpine

# Copy the HTML file to the Nginx web directory
COPY index.html /usr/share/nginx/html/

# Copy custom nginx configuration if needed
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080 (Cloud Run requirement)
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]