[![](https://images.microbadger.com/badges/image/mminks/docker-benno-mailarchive.svg)](https://microbadger.com/images/mminks/docker-benno-mailarchive "Get your own image badge on microbadger.com")

# About this Repo

This image runs [Benno MailArchiv](http://www.benno-mailarchiv.de/), an audit-proof and conformable to law e-mail retention system, including benno-lib, benno-core, benno-archive, benno-rest-lib, benno-rest, benno-smtp und benno-web.

# Versions

| Package | Version | Description |
|---------|---------|-------------|
| benno-archive | 2.6.1 | Benno MailArchiv Archiving Application |
| benno-core | 2.6.1 | Benno MailArchiv Core |
| benno-lib | 2.6.0 | Benno MailArchiv Core libraries from external sources |
| benno-rest | 2.6.1 | Benno MailArchiv REST interface |
| benno-rest-lib | 2.6.0 | Benno MailArchiv REST interface core libraries |
| benno-smtp | 2.4.2 | Benno MailArchiv SMTP Interface |
| benno-web | 2.6.1-1 | Benno MailArchiv web interface |
| benno-imap | 2.6.0 | Benno MailArchiv imap connector |

# How to use this image

## Preparations

In order to preserve a valid licence file called *benno.lic*, you need a hostname (fqdn) and a fixed ip address. This approach requires a recent docker version (1.10 at least).

```
docker network create --subnet=172.18.0.0/16 <name of your network>
```

You can choose any valid docker subnet you want.

Next we want to prepare some directories to store data and logfiles.

```
mkdir -p /opt/benno/archive /opt/benno/inbox /opt/benno/logs/benno /opt/benno/logs/apache2
```

Choose target directories of your choice.

## First start

```
docker run \
  -d \
  -h <fqdn> \
  --net <name of your network> \
  --ip 172.18.100.1 \
  -p 8080:80 \
  -p 2500:2500 \
  -e "MAIL_FROM=mailarchive@inoxio.de" \
  -v /opt/benno/archive:/srv/benno/archive \
  -v /opt/benno/inbox:/srv/benno/inbox \
  -v /opt/benno/logs/benno:/var/log/benno \
  -v /opt/benno/logs/apache2:/var/log/apache2 \
  --name benno \
  mminks/docker-benno-mailarchive
```

### Determine data required for licensing

Enter your docker container with

```
docker exec -ti benno /bin/bash
```

and run

```
/etc/init.d/benno-rest info
```

This produces something like

```
Host-Info: 172.18.100.1/benno.inoxio.de
Build-Info: 2016-02-02 16:50:31
```

Send this to LWsystems GmbH & Co. KG support (support@benno-mailarchiv.de) and wait for your license file. Once you received your file, go on to the next step.

## Final startup

Stop your possibly running benno container and remove him, too.

```
docker stop benno && docker rm benno
```

Finally, fire it up with

```
docker run \
  -d \
  -h <fqdn> \
  --net <name of your network> \
  --ip 172.18.100.1 \
  -p 8080:80 \
  -p 2500:2500 \
  -e "MAIL_FROM=mailarchive@inoxio.de" \
  -v /opt/benno/archive:/srv/benno/archive \
  -v /opt/benno/inbox:/srv/benno/inbox \
  -v /opt/benno/logs/benno:/var/log/benno \
  -v /opt/benno/logs/apache:/var/log/apache \
  -v /path/to/your/benno.lic:/etc/benno/benno.lic \
  --name benno \
  mminks/docker-benno-mailarchive
```

Check that everything is working properly with

```
docker logs -f benno
```

## Environment variables

| Name | Description |
|------|-------------|
| MAIL_FROM | sets MAIL_FROM in /etc/benno-web/benno.conf |

## Docker Compose

```
version: '2.1'

networks:
  benno:
    driver: bridge
    enable_ipv6: false
    ipam:
      driver: default
      config:
      - subnet: 172.18.100.0/24
        gateway: 172.18.100.254

services:
  benno:
    image: mminks/docker-benno-mailarchive
    container_name: benno
    hostname: benno
    restart: always
    domainname: inoxio.de
    ports:
     - "8082:80"
     - "2500:2500"
    environment:
     - MAIL_FROM=mailarchive@inoxio.de
    volumes:
      - /opt/benno/archive:/srv/benno/archive
      - /opt/benno/inbox:/srv/benno/inbox
      - /opt/benno/logs/benno:/var/log/benno
      - /opt/benno/logs/apache:/var/log/apache
      - /opt/benno/benno.lic:/etc/benno/benno.lic
    networks:
      benno:
        ipv4_address: 172.18.100.1
```

## Access benno-web

Access benno-web on port 8080 (or whereever you set it up to - see above) of your docker host. The default username is **admin**. The default password will be generated during setup. Show it with

```
docker logs benno | grep "Benno's admin password"
```

It is possible to specify a password for benno-web's initial admin account with:

```
  -e "BENNO_ADMIN_PASSWORD=admin123"
```

(see "Final startup")

Be sure to use a random password or set a strong one when going live.

# What's next?

Visit [Benno MailArchiv Wiki](https://wiki.benno-mailarchiv.de/index.php/Hauptseite) (german only) if you want to import e-mails or something else.

# Contribution

I welcome any kind of contribution. Fork it or contact me. I appreciate any kind of help.
