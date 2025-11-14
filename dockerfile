FROM nginx:alpine

WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY /home/ec2-user/projects/myapp /usr/share/nginx/html/

EXPOSE 3000
