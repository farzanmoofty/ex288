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
