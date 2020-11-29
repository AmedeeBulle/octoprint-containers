#!/usr/bin/env bash
# Wrapper to docker-compose for multiple environemnts

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <env> <docker-compose args>" >&2
    exit 1
fi

environ="$1"
shift
env_file=".env-${environ}"

if [[ ! -f "${env_file}" ]]; then
    echo "$0: environment file ${env_file} does not exist" >&2
    exit 1
fi

docker-compose --project-name "${environ}" --env-file "${env_file}" "$@"
