FROM nginx:alpine
COPY scriptserve.sh /usr/local/bin/scriptserve.sh
RUN chmod +x /usr/local/bin/scriptserve.sh
