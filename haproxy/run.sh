#!/bin/bash
# Check for certificates and start haproxy

KeyFile=/etc/ssl/private/ssl-cert-snakeoil.key
PemFile=/etc/ssl/certs/ssl-cert-snakeoil.pem
CertFile=/opt/haproxy/data/ssl/snakeoil.pem

if [ ! -f ${CertFile} ]
then
  echo "*** Generating SSL certificate"
  mkdir -p $(dirname ${CertFile})
  make-ssl-cert generate-default-snakeoil --force-overwrite 
  cat ${KeyFile} ${PemFile} >${CertFile}
fi

echo "*** Starting haproxy"
exec /usr/sbin/haproxy -f haproxy.cfg
