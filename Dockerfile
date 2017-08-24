FROM nginx:alpine

COPY app.sh /app/
COPY setup.sh /app/
COPY site.conf /app/
WORKDIR /app/

ENTRYPOINT [ "./app.sh" ]
