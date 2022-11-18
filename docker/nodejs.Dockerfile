FROM node:16

WORKDIR /benchmark
COPY ./nodejs/v8-v7/v8-v7.js .

CMD ["node", "v8-v7.js"]
