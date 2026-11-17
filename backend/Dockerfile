FROM node:24.22-alpine AS builder

WORKDIR /app/

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM node:lts-alpine

WORKDIR /app/

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

COPY --from=builder /app/dist /app/seed-db.js ./

COPY data/ ./data/

ENV PORT="3000"

EXPOSE $PORT

USER node

ENTRYPOINT [ "node" ]

CMD [ "server.js"]