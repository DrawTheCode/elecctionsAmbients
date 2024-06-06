#!/bin/bash
set -e;

# Check if POSTGRES_NON_ROOT_USER exists
user_exists=$(psql -tA --username "$POSTGRES_USER" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRES_NON_ROOT_USER'")
if [ -z "$user_exists" ]; then
    echo "User '$POSTGRES_NON_ROOT_USER' does not exist. Creating it now..."
    if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
            CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
EOSQL
        echo "User '$POSTGRES_NON_ROOT_USER' created successfully."
    else
        echo "SETUP INFO: No Environment variables given for POSTGRES_NON_ROOT_USER creation!"
    fi
else
    echo "User '$POSTGRES_NON_ROOT_USER' already exists. No action taken."
fi
