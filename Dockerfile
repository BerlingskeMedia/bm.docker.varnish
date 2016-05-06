FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install apt-transport-https curl -y
RUN curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/ubuntu/ precise varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update
RUN apt-get install varnish supervisor -y

ADD docs/sites.vcl.TEMPLATE /etc/varnish/docs/sites.vcl.TEMPLATE
ADD docs/vcl_recv.vcl.TEMPLATE etc/varnish/docs/vcl_recv.vcl.TEMPLATE
ADD docs/other_vcl_recv.vcl.TEMPLATE etc/varnish/docs/other_vcl_recv.vcl.TEMPLATE

ADD ./varnish /etc/default/varnish
ADD bin/init.sh /start-varnish.sh
ADD supervisor/varnish.conf /etc/supervisor/conf.d/varnish.conf

RUN chmod 775 /start-varnish.sh

CMD ["/start-varnish.sh"]
