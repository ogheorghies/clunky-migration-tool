#!/usr/bin/env bash

# Copyright (c) 2016 Ovidiu Gheorghies <ogheorghies@gmail.com>
# ISC license

function pg_docker_operational {
    docker ps -a >/dev/null 2>/dev/null || {
        echo "Can we start a dockerized Postgres if docker does not work? No, we can't."
        return 1
    }
}

function pg_docker_tool_down {
    local DOCKER_NAME=$1
    [ -z "${DOCKER_NAME}" ] && return 1

    >&2 docker stop ${DOCKER_NAME} || >&2 echo "Container not already started, that's OK."
    >&2 docker rm   ${DOCKER_NAME} || >&2 echo "Container does not need to be removed, that's OK."
}

function pg_docker_tool_up {
    local DOCKER_NAME=$1
    [ -z "${DOCKER_NAME}" ] && return 1

    pg_docker_tool_down

    >&2 docker run -P --name ${DOCKER_NAME} -d kiasaki/alpine-postgres

    local PORT=$(docker port ${DOCKER_NAME} 5432/tcp | cut -f 2 -d :)       # Yes, that's a smiley.
    local DOCKER_IP=$(echo ${DOCKER_HOST} | cut -f 3 -d / | cut -f 1 -d :)
    local DOCKER_IP=${DOCKER_IP:-127.0.0.1}

    local PSQL_URI="postgres://postgres@${DOCKER_IP}:${PORT}/postgres"

    local TRY=0
    until >&2 psql ${PSQL_URI} -c "select version()"
    do
        >&2 echo "Attempting to connect to ${PSQL_URI} again in 1 second..."
        sleep 1
        local TRY=$(($TRY+1))
         if [ "${TRY}" -gt 10 ]
         then
            >&2 echo "Could not connect to the docker Postgres database in a timely manner. Oh, well."
            return 2
         fi
    done

    echo ${PSQL_URI}
}

function pg_docker_tool_fresh {
    local PSQL_URI=$1
    [ -z "${PSQL_URI}" ] && return 1

    psql ${PSQL_URI} 2>/dev/null <<-SQL
        DROP SCHEMA public CASCADE;
        CREATE SCHEMA public;
        GRANT ALL ON SCHEMA public TO postgres;
        GRANT ALL ON SCHEMA public TO public;
        COMMENT ON SCHEMA public IS 'standard public schema';
SQL
}