FROM node:alpine

RUN apk add --no-cache ca-certificates;

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY src .
RUN npm install

EXPOSE 8080

RUN chown -R node /usr/src/app
USER node

CMD ["npm", "start"]
