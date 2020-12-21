FROM node:latest as builder
WORKDIR /opt
COPY . .
RUN npm install
RUN npm run build

FROM node:latest
WORKDIR /opt
COPY --from=builder /opt/dist .
RUN npm install -g http-server
ENTRYPOINT http-server --port 80
