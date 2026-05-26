#!/bin/bash
mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < /docker-entrypoint-initdb.d/triggers_content.sql