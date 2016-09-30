FROM debian:jessie
MAINTAINER Meik Minks <docbrown@datenschleuder.org>

ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN apt-get update && \
		apt-get install -y wget dialog

RUN wget -q http://www.benno-mailarchiv.de/download/debian/benno.asc && \
		apt-key add benno.asc && \
		echo "deb http://www.benno-mailarchiv.de/download/debian /" >> /etc/apt/sources.list  && \
		rm -Rf benno.asc

RUN apt-get update && \
		apt-get -y install apache2 php5 php-pear php-db smarty && \
		apt-get autoremove --purge && \
		apt-get clean && \
		apt-get autoclean

RUN apt-get install -y benno-lib benno-core benno-archive benno-rest-lib benno-rest benno-smtp

RUN apt-get install -y php5-sqlite php5-curl smarty php-db php-pear sqlite libdbi-perl libdbd-sqlite3-perl sqlite3 postfix

# avoid "invoke-rc.d: policy-rc.d denied execution of start."
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# fix reload apache error while configuring benno-web (because apache isn't running at that time)
RUN apt-get download benno-web
RUN dpkg --unpack benno-web_*.deb
RUN sed -i '/\/etc\/init.d\/apache2 force-reload/d' /var/lib/dpkg/info/benno-web.postinst
RUN dpkg --configure benno-web

RUN rm -Rf /etc/apache2/conf-available/benno.conf /etc/apache2/conf-enabled/benno.conf
RUN rm -Rf /etc/benno-web/apache-2.2.conf /etc/benno-web/apache-2.4.conf

COPY apache2-benno.conf /etc/apache2/sites-available/000-default.conf

RUN apt-get autoremove --purge && apt-get autoclean

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 80
EXPOSE 2500

VOLUME ["/srv/benno/archive", "/srv/benno/inbox", "/var/log/apache2", "/var/log/benno"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
CMD docker-entrypoint.sh
