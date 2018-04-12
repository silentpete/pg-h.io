#!/bin/sh

CONTAINER_NAME=${CONTAINER_NAME:-influxdb}
CONTAINER_PORT=${CONTAINER_PORT:-8086}
INFLUXDB_URL="http://${CONTAINER_NAME}:${CONTAINER_PORT}"
DATABASE_NAME=${DATABASE_NAME:-prometheus} # default value if blank
RETENTION_POLICY=${RETENTION_POLICY:-autogen} # default value if blank

echo -e "\e[32mINFO: Checking for ${CONTAINER_NAME} container\e[0m"
influxdbDown=true
while "${influxdbDown}"
do
    # InfluxDB HTTP Status Code: 204	Success! Your InfluxDB instance is up and running.
    RESULT=`curl --silent --head ${INFLUXDB_URL}/ping | grep -c 204`
    if [[ "${RESULT}" == 1 ]]; then
      echo -e "\e[32mINFO: ${CONTAINER_NAME} container found\e[0m"
      influxdbDown=false
    else
      echo -e "\e[33mWARNING: ${CONTAINER_NAME} container not found, checking again in 5 seconds\e[0m"
      sleep 5
    fi
done

if [[ $(curl --silent --get "${INFLUXDB_URL}/query?pretty=false" --data-urlencode "q=show databases" | grep -c "\"${DATABASE_NAME}\"") == 1 ]]; then
  echo -e "\e[32mINFO: ${DATABASE_NAME} database exists\e[0m"
else
  echo -e "\e[32mINFO: ${DATABASE_NAME} database not found\e[0m"
  curl --silent --include -XPOST ${INFLUXDB_URL}/query --data-urlencode "q=CREATE DATABASE ${DATABASE_NAME}" > /dev/null
  if [[ $? == 0 ]]; then
    echo -e "\e[32mINFO: ${DATABASE_NAME} database created\e[0m"
  else
    echo -e "\e[33mWARNING: failed to create ${DATABASE_NAME} database\e[0m"
    echo -e "\e[33mWARNING: exiting\e[0m"
    exit 1
  fi
fi

# Can run for options: docker exec remote_storage_adapter /opt/remote_storage_adapter -h
echo -e "\e[32mINFO: setup completed, starting service\e[0m"
/opt/remote_storage_adapter -influxdb-url=${INFLUXDB_URL}/ -influxdb.database=${DATABASE_NAME} -influxdb.retention-policy=${RETENTION_POLICY} &

shutdown() {
  echo -e "\e[32mINFO: received SIGTERM, exiting\e[0m"
  exit 0
}

trap 'shutdown' SIGTERM
while true; do read; done
