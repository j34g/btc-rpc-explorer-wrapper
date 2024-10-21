# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory
WORKDIR /app

# Install any required dependencies and tools
RUN apt-get update && apt-get install -y \
        wget \
        curl \
        bash \
        tini \
        && wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_arm.tar.gz -O - | \
        tar xz && mv yq_linux_arm /usr/bin/yq

# Clone the BTC RPC Explorer repository
RUN git clone https://github.com/janoside/btc-rpc-explorer.git ./

# Set environment variables
ENV APP_HOST btc-rpc-explorer
ENV APP_PORT 3002
ENV TOR_PROXY_IP embassy
ENV TOR_PROXY_PORT 9050

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install --production

# Copy the rest of your application files
COPY . .

# Add the docker entry point script
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

# Expose the application port
EXPOSE ${APP_PORT}

# Command to run the application
ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
CMD ["npm", "start"]
