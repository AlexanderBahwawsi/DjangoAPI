#!/bin/sh
# Container entrypoint for the DogAPI app service.
# 1. Wait until the PostgreSQL service accepts connections.
# 2. Apply Django migrations so the schema exists in the fresh database.
# 3. Exec the command passed by docker-compose (the dev server by default).
set -e

echo "Waiting for PostgreSQL at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432}..."
until pg_isready -h "${POSTGRES_HOST:-db}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-postgres}" -q; do
  sleep 1
done
echo "PostgreSQL is ready."

python manage.py migrate --noinput

exec "$@"
