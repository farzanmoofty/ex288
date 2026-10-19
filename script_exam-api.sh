#!/bin/bash

mkdir -p question8/exam-api-source
cd question8/exam-api-source

cat > app.js <<'EOF'
const http = require('http');

// Read environment variables
const environment = process.env.ENVIRONMENT || 'unknown';
const apiKey = process.env.API_KEY || 'not-set';
const dbHost = process.env.DB_HOST || 'not-set';
const appVersion = process.env.APP_VERSION || '1.0.0';

const hostname = '0.0.0.0';
const port = 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/q/health') {
    // Health endpoint for probes
    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({
      status: 'UP',
      environment: environment
    }));
  } else {
    // Main endpoint - returns different response based on environment
    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    
    let message = '';
    if (environment === 'prod') {
      message = 'Production API - High Performance Mode';
    } else if (environment === 'dev') {
      message = 'Development API - Debug Mode Enabled';
    } else if (environment === 'qa') {
      message = 'QA API - Testing Environment';
    } else {
      message = 'API - Environment Not Specified';
    }
    
    res.end(JSON.stringify({
      message: message,
      environment: environment,
      version: appVersion,
      config: {
        apiKey: apiKey,
        dbHost: dbHost
      }
    }));
  }
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
  console.log(`Environment: ${environment}`);
});
EOF


cat > package.json <<'EOF'
{
  "name": "exam-api",
  "version": "1.0.0",
  "description": "Simple API for EX288 Helm exercise",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "keywords": ["api", "exam"],
  "author": "Student",
  "license": "MIT"
}
EOF

cat > Dockerfile <<'EOF'
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
EOF




cd question8
helm create exam-api
