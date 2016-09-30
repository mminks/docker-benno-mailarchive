#!/bin/bash

set -e

# generating secrets
BENNO_SHARED_SECRET=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 32 | head -n 1)
BENNO_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 12 | head -n 1)

echo "Benno's SHARED_SECRET: $BENNO_SHARED_SECRET"
echo "Benno's admin password: $BENNO_ADMIN_PASSWORD"

# set secret
sed -ri -e "s/^SHARED_SECRET =.*/SHARED_SECRET = ${BENNO_SHARED_SECRET}/g" /etc/benno-web/benno.conf
sed -ri -e "s/^    <sharedSecret>.*<\/sharedSecret>.*/    <sharedSecret>${BENNO_SHARED_SECRET}<\/sharedSecret>/g" /etc/benno/benno.xml

# set default admin pasword
benno-useradmin -c admin -p $BENNO_ADMIN_PASSWORD

# starting benno services
/etc/init.d/benno-rest restart &>/dev/null
/etc/init.d/benno-archive start &>/dev/null
/etc/init.d/benno-smtp start &>/dev/null
/etc/init.d/apache2 start &>/dev/null

# show logs on default console
exec /usr/bin/tail -f /var/log/benno/*.log /var/log/apache2/*.log
