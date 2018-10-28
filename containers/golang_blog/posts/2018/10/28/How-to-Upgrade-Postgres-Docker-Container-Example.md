Upgrading a PostgreSQL Docker container has a bunch of discussion online. I have had to upgrade a couple Atlassian products that my team supports. Here is an overview of the process I have done in production.

# Overview

Atlassian products can be installed in your own container, or you can use one of theirs.

[https://hub.docker.com/u/atlassian/](https://hub.docker.com/u/atlassian/)

Hopefully, you'll follow Atlassian's install guide along with your own concepts and you will end up separating services/containers. You will stand up a Nginx or HA Proxy in front of the application, and you may decide to use postgres for the database.

Once you have the environment up and running in production, you will have moved onto something else to build out. Eventually the Atlassian product will bump versions, and the postgres supported will support a later version. Now you must upgrade postgres.

## Environment

- Linux
- The application stack is running in a self-hosted/self-maintained/on promise environment.
- Atlassian product talking to postgres database.
- Database state/data can be stored on a volume mount to host or NAS.

## Process Overview

Since the application talking to the postgres database is up and running, we just need to read the postgres docs on how to upgrade. Finding the recommended way of using [pg_upgrade](https://www.postgresql.org/docs/9.6/static/pgupgrade.html), which requires old and new data paths, old and new bin locations accessible.

Starting with a production dev environment, ready to screw up, we can start the process.

### Concept

- Stop running environment
- Start new postgres with volume mount of old data and old bin
- Initialize new database
- Upgrade
- Bring up application

## Demo Process with Confluence (9.5 -> 9.6)

1. Start a postgres container
    ```
    docker run -dt --name=postgres --hostname=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=testdb --log-driver=json-file -v /tmp/pg-old-data/:/var/lib/postgresql/data/ postgres:9.5.7-alpine
    ```

1. Start the Atlassian App (in example, notice linking to postgres)
    ```
    docker run -d --link=postgres --name="confluence" -v /data/confluence-home:/var/atlassian/application-data/confluence --log-driver=json-file -p 8090:8090 -p 8091:8091 atlassian/confluence-server
    ```

1. Complete the setup process to get the application fully up, running, and talking to the postgres database. Atlassian allows to use a Developers license, which you can get on the [my.atlassian](https://my.atlassian.com/product) page, under the product you are upgrading. Also, set up the sample data. Once you have logged into the application, (setup example site data potentially) we are able to stop the running containers, the application then postgres.

1. Setup the environment needed to upgrade postgres.
    ```
    sudo mkdir /tmp/pg-old-bin/
    sudo docker cp postgres:/usr/local/bin /tmp/pg-old-bin/
    sudo docker cp postgres:/usr/local/lib /tmp/pg-old-bin/
    sudo docker cp postgres:/usr/local/share /tmp/pg-old-bin/
    sudo chown 70:70 -R /tmp/pg-old-bin/
    sudo chmod 0700 -R /tmp/pg-old-bin/
    ```

1. Remove containers

1. Start the new postgres container, notice we are interfering with the postgres service starting.
    ```
    docker run -dt --entrypoint=bash --user=postgres --name=postgres --hostname=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=testdb --log-driver=json-file -v /tmp/pg-old-bin/:/tmp/pg-old-bin/ -v /tmp/pg-old-data/:/tmp/pg-old-data/ -v /tmp/pg-new-data/:/var/lib/postgresql/data/ postgres:9.6.10-alpine
    ```

1. Set permissions on the postgres data
    ```
    sudo chown 70:70 -R /tmp/pg-new-data/
    ```

1. Docker exec into postgres container to setup the database and then upgrade
    ```
    docker exec -it postgres bash
    cd /tmp
    pg_ctl initdb --pgdata=/var/lib/postgresql/data/;
    pg_upgrade --old-bindir=/tmp/pg-old-bin/bin --new-bindir=/usr/local/bin/ --old-datadir=/tmp/pg-old-data/ --new-datadir=/var/lib/postgresql/data/ --check
    pg_upgrade --old-bindir=/tmp/postgres-bin/bin --new-bindir=/usr/local/bin/ --old-datadir=/tmp/pg-old-data/ --new-datadir=/var/lib/postgresql/data/
    echo -e "\nhost all all all md5" >> /var/lib/postgresql/data/pg_hba.conf
    ```

    Should get "Upgrade Complete"

1. After the successful upgrade, you can stop and remove the container
    ```
    docker stop postgres
    docker rm postges
    ```

1. Start postgres normally looking at the new data.
    ```
    docker run -dt --name=postgres --hostname=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=testdb --log-driver=json-file -v /tmp/pg-new-data/:/var/lib/postgresql/data/ postgres:9.6.10-alpine
    ```

1. Start confluence
    ```
    docker run -d --link=postgres -v /tmp/confluence-home:/var/atlassian/application-data/confluence --name="confluence" --log-driver=json-file -p 8090:8090 -p 8091:8091 atlassian/confluence-server
    ```

1. Log into the application once it finishes loading to confirm upgrade.

## Notes

### Docker PostgreSQL Process (9.2 -> 9.6)

I have been able to use the above example to complete a upgrade successfully. Only adjustment was the lib and share directories are not needed to copy out of the old container.

### Postgres Semantic Patch Upgrade

I have tested this only a couple times. For example, with this process I was able to upgrade to 5.6.8 and then after finished, just stop/remove/run 5.6.10 with no errors.

## Conclusion

It is possible and not really that difficult to upgrade your postgres dockerized environment. I am hoping, like most of the community, that one day it will be built into the postgres container. Postgres is used by so many, that they may not want to take on that potential responsibility. Either way, it is possible.

## References

- [https://hub.docker.com/u/atlassian/](https://hub.docker.com/u/atlassian/)
- [https://hub.docker.com/r/atlassian/confluence-server/](https://hub.docker.com/r/atlassian/confluence-server/)
- [https://hub.docker.com/_/postgres/](https://hub.docker.com/_/postgres/)
- [https://www.postgresql.org/docs/9.6/static/pgupgrade.html](https://www.postgresql.org/docs/9.6/static/pgupgrade.html)
