#!/bin/bash
set -e;

# Check if the N8N database exists
if ! psql -lqt --username "$POSTGRES_USER" --dbname "postgres" | cut -d \| -f 1 | grep -qw $POSTGRES_DB_N8N; then
    # N8N Database does not exist, create it
    echo "Database '$POSTGRES_DB_N8N' does not exist. Creating it now..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE DATABASE $POSTGRES_DB_N8N;"
    echo "Database '$POSTGRES_DB_N8N' created successfully."
else
    echo "Database '$POSTGRES_DB_N8N' already exists. No action taken."
fi

# Grant privileges to POSTGRES_NON_ROOT_USER on the N8N database
# Ensure the POSTGRES_NON_ROOT_USER environment variable is set
if [ -n "${POSTGRES_NON_ROOT_USER:-}" ]; then
    echo "Granting privileges to user '$POSTGRES_NON_ROOT_USER' on database '$POSTGRES_DB_N8N'..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB_N8N" <<-EOSQL
        GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB_N8N} TO ${POSTGRES_NON_ROOT_USER};
EOSQL
    echo "Privileges granted successfully."
else
    echo "SETUP INFO: No POSTGRES_NON_ROOT_USER environment variable set. Skipping user privilege setup."
fi