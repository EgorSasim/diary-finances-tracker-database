#!/bin/bash
set -e

SERVER="diary_finances_tracker_database_server";
PW="password";
DB="diary_finances_tracker_database";



if ! docker info &> /dev/null; then 
  echo "Docker is not running, start docker..."
  sudo systemctl start docker
  if [ $? -eq 0 ]; then
    echo "Docker started successfully."
  else
    echo "Error starting Docker. Please check logs for details."
    echo $(sudo systemctl status docker)
    exit 1
  fi
fi




echo "echo stop & remove old docker [$SERVER] and starting new fresh instance of [$SERVER]"
(docker kill $SERVER || :) && \
  (docker rm $SERVER || :) && \
  docker run --name $SERVER -e POSTGRES_PASSWORD=$PW \
  -e PGPASSWORD=$PW \
  -p 5432:5432 \
  -d postgres

echo "sleep wait for pg-server [$SERVER] to start";
sleep 3;

echo "CREATE DATABASE $DB ENCODING 'UTF-8';" | docker exec -i $SERVER psql -U postgres
echo "\l" | docker exec -i $SERVER psql -U postgres

# -p <outside host> <inside docker host>
