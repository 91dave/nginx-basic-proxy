FROM nginx:alpine

COPY app.sh /app/
COPY setup-site.sh /app/
COPY setup-redirect.sh /app/
WORKDIR /app/

ENTRYPOINT [ "./app.sh" ]
