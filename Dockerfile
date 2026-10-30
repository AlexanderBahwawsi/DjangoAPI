# Dockerfile for the DogAPI Django application.
#
# This image encapsulates every runtime dependency the app needs:
# the Python interpreter, the system libraries psycopg needs to talk to
# PostgreSQL, and the Python packages from requirements.txt.
#
# The application source code is NOT copied into the image. docker-compose.yml
# bind-mounts the project directory to /app so code edits on the host are
# picked up by the running container immediately.

FROM python:3.13-slim

# Don't write .pyc files and flush stdout/stderr straight to the container log
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# System packages:
#   libpq5         - PostgreSQL client library required at runtime by psycopg
#   postgresql-client - gives us `pg_isready`, used by entrypoint.sh to wait for the db
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies. Only requirements.txt is copied so this layer is
# cached until the dependency list actually changes.
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt

# Entrypoint waits for Postgres, runs migrations, then starts the server.
# The sed strips Windows CRLF line endings in case Git checked the file out that way.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
