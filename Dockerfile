FROM nginx:alpine
COPY scriptserve.sh /usr/local/bin/scriptserve.sh
COPY nginx.conf /etc/nginx/nginx.conf
RUN chmod +x /usr/local/bin/scriptserve.sh
