FROM amazonlinux
MAINTAINER Brian G. Shacklett

RUN yum -y update && yum -y install nginx

ADD html /var/www/html/

EXPOSE 80

CMD exec nginx -g "daemon off"


