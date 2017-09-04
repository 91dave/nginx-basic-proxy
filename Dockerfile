FROM nginx:alpine

# Global bits that never change
WORKDIR /app/
ENTRYPOINT [ "./app.sh" ]

# Dependencies that should rarely change
RUN apk update && apk add curl

# Application bits that change most often
COPY app.sh /app/
COPY json.conf /app/
COPY setup-site.sh /app/
COPY setup-redirect.sh /app/

