FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN ls -l  # Debugging: List files in /app to check if package.json is present

RUN npm install --verbose

COPY . .

RUN npm run build

EXPOSE 8080

CMD [ "npm", "run", "preview" ]
