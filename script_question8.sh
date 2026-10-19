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

oc new-project exam-resource

cd /home/openshift/openshift_labs/ex288/question8/exam-api-source
podman build -t ex288-api:latest .

# Get the internal registry route
REGISTRY=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')

# Tag the image
podman tag ex288-api:latest ${REGISTRY}/exam-resource/ex288-api:latest

# Get token
TOKEN=$(oc whoami -t)

# Login
podman login -u developer -p ${TOKEN} ${REGISTRY} --tls-verify=false

podman push ${REGISTRY}/exam-resource/ex288-api:latest --tls-verify=false


# Create imagestream if it doesn't exist
oc create imagestream ex288-api -n exam-resource

# Import the image
oc import-image ex288-api:latest \
  --from=${REGISTRY}/exam-resource/ex288-api:latest \
  --confirm \
  -n exam-resource

# Verify
oc get is ex288-api -n exam-resource

mkdir exam-api
cd exam-api
cat > values.yaml <<'EOF'
# Default values for exam-api
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

# Environment-specific settings
environment: prod

# Environment variables to inject into pods (will iterate with range)
env:
  - name: ENVIRONMENT
    value: "prod"
  - name: API_KEY
    value: "prod-secret-key-12345"
  - name: DB_HOST
    value: "postgres-prod.example.com"
  - name: APP_VERSION
    value: "1.0.0"

# Resource limits based on environment
resources:
  prod:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  dev:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
  qa:
    limits:
      cpu: 300m
      memory: 384Mi
    requests:
      cpu: 150m
      memory: 192Mi

nodeSelector: {}

tolerations: []

affinity: {}
EOF
