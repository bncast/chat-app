const express = require('express');
const bodyParser = require('body-parser');
const YAML = require('yamljs');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }))

const config = YAML.load('response/routes.yaml');

const messageQueue = []; // Store chat messages
const waitingClients = []; // Store waiting client responses

const handleRequest = (req, res, routeConfig) => {
    const responseConfig = routeConfig.find(cfg => cfg.statusCode);
    if (responseConfig.delay) {
      setTimeout(() => {
        const filePath = path.join(__dirname, "response", responseConfig.filename);
        const responseBody = fs.readFileSync(filePath, 'utf8');
        res.status(responseConfig.statusCode).send(JSON.parse(responseBody));
      }, responseConfig.delay);
    } else {
        const filePath = path.join(__dirname, "response", responseConfig.filename);
        const responseBody = fs.readFileSync(filePath, 'utf8');
        res.status(responseConfig.statusCode).send(JSON.parse(responseBody));
    }
};

let routes = config["routes"];
Object.keys(routes).forEach(route => {
    const methods = routes[route];
    Object.keys(methods).forEach(method => {
        app[method.toLowerCase()](route, (req, res) => {
            handleRequest(req, res, methods[method]);
          });
    });
});

// Long Polling for Chat Room
app.get('/api/listen', (req, res) => {
  if (messageQueue.length > 0) {
    res.status(200).json({ success: 1, messages: messageQueue });
    messageQueue.length = 0; // Clear the message queue
  } else {
    waitingClients.push(res);
  }
});

app.post('/api/send', (req, res) => {
  const message = req.body.message;

  messageQueue.push(message);
  res.status(200).json({ success: 1 });

  while (waitingClients.length > 0) {
    const client = waitingClients.pop();
    client.status(200).json({ success: 1, messages: messageQueue });
  }
  messageQueue.length = 0; // Clear the message queue after sending
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Stub server running on port ${PORT}`);
});
