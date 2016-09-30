# About this Repo

This image runs [Benno MailArchiv](http://www.benno-mailarchiv.de/), an audit-proof and conformable to law e-mail retention system, including benno-lib, benno-core, benno-archive, benno-rest-lib, benno-rest, benno-smtp und benno-web.

# How to use this image

## Preparations

In order to preserve a valid licence file called *benno.lic*, you need a hostname (fqdn) and a fixed ip address. This approach requires a recent docker version (1.10 at least).

```
docker network create --subnet=172.18.0.0/16 <name of your network>
```

You can choose any valid docker subnet you want.

Next we want to prepare some directories to store data and logiles.

```
mkdir -p /opt/benno/archive /opt/benno/inbox /opt/benno/logs/benno /opt/benno/logs/apache
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
  -p 80443:443 \
  -p 2500:2500 \
  -v /opt/benno/archive:/srv/benno/archive \
  -v /opt/benno/inbox:/srv/benno/inbox \
  -v /opt/benno/logs/benno:/var/log/benno \
  -v /opt/benno/logs/apache:/var/log/apache \
  --name benno \
  mminks/benno-mailarchiv
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
  -p 80443:443 \
  -p 2500:2500 \
  -v /opt/benno/archive:/srv/benno/archive \
  -v /opt/benno/inbox:/srv/benno/inbox \
  -v /opt/benno/logs/benno:/var/log/benno \
  -v /opt/benno/logs/apache:/var/log/apache \
  -v <path to your benno.lic file>:/etc/benno/benno.lic \
  --name benno \
  mminks/benno-mailarchiv
```

Check that everything is working properly with

```
docker logs -f benno
```

# What's next?

Visit [Benno MailArchiv Wiki](https://wiki.benno-mailarchiv.de/index.php/Hauptseite) (german only) if you want to import e-mails or something else.
