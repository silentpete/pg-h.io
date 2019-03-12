#!/bin/sh

# References
# https://certbot.eff.org/docs/
# https://hub.docker.com/r/certbot/certbot/
# https://www.digitalocean.com/community/questions/tutorial-for-let-s-encrypt-wildcard

# Get the directory of the script being executed, and then move there.
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CWD

certs_already_generated=$(ls -1 ../nginx/certs/ | wc -l)

if [[ ${certs_already_generated} -eq 0 ]]; then
  if [[ -z "${GMAIL_ACCOUNT}" ]]; then
    echo "What is your email address that should be used for letsencrypt?"
    read GMAIL_ACCOUNT
  else
    # TODO: make this state the name and confirm to use it or set alternate
    info "found and using email address: ${GMAIL_ACCOUNT}"
  fi
  sudo docker run -it --rm --name certbot -v $PWD/etc/letsencrypt:/etc/letsencrypt:rw -v $PWD/var/lib/letsencrypt:/var/lib/letsencrypt:rw certbot/certbot:v0.27.1 certonly --server https://acme-v02.api.letsencrypt.org/directory --expand --manual --preferred-challenges dns -d pg-h.io -d *.pg-h.io --agree-tos -m ${GMAIL_ACCOUNT}
  rc=$?
  if [[ ${rc} -ne 0 ]]; then
    error "certbot failed"
  fi
  cp etc/letsencrypt/live/pg-h.io/* ../nginx/certs/
else
  info "certs already generated"
fi
