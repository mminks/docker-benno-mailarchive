FROM debian:buster

LABEL maintainer="Meik Minks <mminks@inoxio.de>"

ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV TZ=Europe/Berlin

RUN echo $TZ | tee /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get update \
		&& apt-get install -y \
		  wget \
		  dialog \
		  php-mbstring \
		  gnupg \
		&& wget -q http://www.benno-mailarchiv.de/download/debian/benno.asc \
		&& apt-key add benno.asc \
		&& echo "deb http://www.benno-mailarchiv.de/download/debian /" >> /etc/apt/sources.list.d/benno-mailarchive.list \
		&& rm -Rf benno.asc \
    && apt-get update \
		&& apt-get -y install \
		  apache2 \
		  php \
		  php-pear \
		  smarty3 \
      benno-lib \
      benno-core \
      benno-archive \
      benno-rest-lib \
      benno-rest \
      benno-smtp \
      benno-imap \
      php-sqlite3 \
      php-curl \
      smarty3 \
      php-pear \
      sqlite3 \
      libdbi-perl \
      libdbd-sqlite3-perl \
      sqlite3 \
      postfix \
      libnet-ldap-perl \
      libdbd-mysql-perl \
      libcrypt-eksblowfish-perl \
      libdata-entropy-perl \
    # avoid "invoke-rc.d: policy-rc.d denied execution of start."
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    # fix reload apache error while configuring benno-web (because apache isn't running at that time)
    && cd /tmp && apt-get download benno-web \
    && dpkg --unpack benno-web_*.deb \
    && sed -i '/invoke-rc.d apache2 force-reload/d' /var/lib/dpkg/info/benno-web.postinst \
    && dpkg --configure benno-web \
    # && dpkg update && dpkg install benno-web \
    && rm -Rf /etc/apache2/conf-available/benno.conf /etc/apache2/conf-enabled/benno.conf \
    && rm -Rf /etc/benno-web/apache-2.2.conf /etc/benno-web/apache-2.4.conf \
    && apt-get autoremove --purge \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

COPY apache2-benno.conf /etc/apache2/sites-available/000-default.conf
COPY docker-entrypoint.sh /

EXPOSE 80
EXPOSE 2500

VOLUME ["/srv/benno/archive", "/srv/benno/inbox", "/var/log/apache2", "/var/log/benno"]

CMD /docker-entrypoint.sh
