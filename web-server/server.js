const express = require('express');
const bodyParser = require('body-parser');
const YAML = require('yamljs');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(bodyParser.json());

const config = YAML.load('response/routes.yaml');

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
    console.log(JSON.stringify(route));
    Object.keys(methods).forEach(method => {
        app[method.toLowerCase()](route, (req, res) => {
            handleRequest(req, res, methods[method]);
          });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Stub server running on port ${PORT}`);
});
