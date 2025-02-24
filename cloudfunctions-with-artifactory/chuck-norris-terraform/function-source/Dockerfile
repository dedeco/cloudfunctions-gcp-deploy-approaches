FROM node:20-slim

WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy function code
COPY . .

# Configure the container
ENV NODE_ENV production
ENV PORT 8080

# Run the web service on container startup
CMD [ "node", "-e", "const http = require('http'); const { getRandomJoke } = require('./index'); const server = http.createServer((req, res) => { getRandomJoke(req, res); }); server.listen(process.env.PORT);" ]
