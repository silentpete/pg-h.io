#!/bin/sh

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
file="${CWD}/gmail_creds"
alertmanagerYml="${CWD}/alertmanager.yml"

# check for file
if [[ -f "${file}" ]]; then
  # source file
  . ${file}
else
  # create file with gmail info used for connecting alertmanager to gmail for alerts
  touch ${file}
  # Set gmail email and app password for alertmanager
  echo "What is your gmail email address alertmanager should send emails to?"
  read GMAIL_ACCOUNT
  echo -e "export GMAIL_ACCOUNT=${GMAIL_ACCOUNT}" >> ${file}
  echo "What is the gmail app password to use?"
  read GMAIL_APP_PASSWORD
  echo -e "export GMAIL_APP_PASSWORD=${GMAIL_APP_PASSWORD}" >> ${file}
  echo "What is the gmail smtp server to use [smtp.gmail.com:587]"
  read GMAIL_SMTP_SERVER
  echo -e "export GMAIL_SMTP_SERVER=${GMAIL_SMTP_SERVER}" >> ${file}

  # source file
  . ${file}
fi

success="true"
if [[ ! -z "${GMAIL_ACCOUNT}" ]]; then
  sed -i "s|REPLACE_W_GMAIL_ACCOUNT|${GMAIL_ACCOUNT}|" ${alertmanagerYml}
fi
err="$?"
if [[ ! $err == 0 ]]; then
  echo -e "error code: $err, replacing gmail account"
  success="false"
fi
if [[ ! -z "${GMAIL_APP_PASSWORD}" ]]; then
  sed -i "s|REPLACE_W_GMAIL_APP_PASSWORD|${GMAIL_APP_PASSWORD}|" ${alertmanagerYml}
fi
err="$?"
if [[ ! $err == 0 ]]; then
  echo -e "error code: $err, replacing gmail app password"
  success="false"
fi
if [[ ! -z "${GMAIL_SMTP_SERVER}" ]]; then
  sed -i "s|REPLACE_W_GMAIL_SMTP_SERVER|${GMAIL_SMTP_SERVER}|" ${alertmanagerYml}
fi
err="$?"
if [[ ! $err == 0 ]]; then
  echo -e "error code: $err, replacing gmail smtp server"
  success="false"
fi

if [[ $success != "true" ]]; then
  exit 1
fi
