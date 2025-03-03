FROM node:20
RUN apt-get update && apt-get install -y sqlite3 jq
RUN npm install -g ts-node typeorm 
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
RUN npm run build
CMD ["npm", "run", "start:dev"] 
