FROM node:16-alpine

WORKDIR /app

# Copy package.json and package-lock.json to install dependencies first
COPY package.json package-lock.json ./

RUN npm install --production

# Copy the rest of the application code
COPY . .

# Expose the port for the web interface
EXPOSE 3002

# Start the application
CMD ["npm", "start"]
