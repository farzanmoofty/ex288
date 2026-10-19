FROM registry.access.redhat.com/ubi8/nodejs-16:latest

USER root

# Copy application files
COPY app.js package.json ./

# Install dependencies (none needed for this simple app)
RUN npm install --production

# Set permissions
RUN chown -R 1001:0 /opt/app-root/src && \
    chmod -R g+rwX /opt/app-root/src

USER 1001

EXPOSE 8080

CMD ["npm", "start"]
