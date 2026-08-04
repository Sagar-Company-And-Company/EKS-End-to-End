FROM node:14

WORKDIR /usr/src/app

# Copy package file and install dependencies
COPY package*.json ./
RUN npm install

# Copy only required application files
COPY index.js ./
COPY db.js ./
COPY models ./models
COPY routes ./routes

CMD ["node", "index.js"]
