FROM node:22-alpine AS builder

WORKDIR /app/

COPY package.json .

# The --ignore-scripts flag skips the "prepare" script block
RUN npm i --legacy-peer-deps --ignore-scripts

COPY . .

RUN npm run build

# Stage 2
# "nginx-unprivileged" image uses port 8080 as default and the resultant container runs as non-root user

FROM nginx/nginx-unprivileged:alpine 

COPY --from=builder /app/dist /usr/share/nginx/html/

EXPOSE 8080
