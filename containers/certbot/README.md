# certbot

`build.sh`

This script will stand up a container and walk through the process to create certs. This process has to be done every 90 days at the moment.

## First Run

1. Execute the build.sh script.
1. Fill in the associated email address of your letsencrypt account.
1. Create the TXT record on your site host. (like godaddy)
1. Create the 2nd TXT record.
1. Should have completed successfully.
    * may need to restart/reload your nginx to update the certs

## Certs Already Exist

1. Make a directory to move the current, hopefully not expired certs, to for safe keeping.
1. Move everything in the nginx/certs to that directory.
1. Run the bulid.sh script in the certbot directory.

After the certs have been recreated, it may take some time (5-10 minutes) for the browser to recheck them.
