FROM python:3.8-slim

ARG APP_NAME=test-api

# Create a non root user to run as
ARG APP_USER=api
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends mime-support && \
    rm -rf /var/lib/apt/lists/*
# Copy over requirements file
COPY src/requirements.txt /tmp/requirements.txt
# - Install packages needed to build python libs,
# - Install requirements
# - remove requirements file
# - purge packages not needed
# - Remove old apt files
RUN set -ex \
    && BUILD_DEPS=" \
    build-essential \
    libpcre3-dev \
    libpq-dev \
    python3-dev \
    libcurl4-gnutls-dev \
    libgnutls28-dev \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf /tmp/requirements.txt && \
    apt-get purge -y --auto-remove $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/*

# Copy source
COPY src/ /app

WORKDIR /app
# Port 8000 for uwsgi
EXPOSE 8000

# Base uWSGI configuration (you shouldn't need to change these):
ENV UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_HTTP_AUTO_CHUNKED=1 UWSGI_HTTP_KEEPALIVE=1 UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy

# Number of uWSGI workers and threads per worker (customize as needed):
ENV UWSGI_WORKERS=2 UWSGI_THREADS=4

USER ${APP_USER}:${APP_USER}
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["uwsgi", "--show-config", "-s", "/tmp/${APP_NAME}.sock", "--manage-script-name", "--mount", "/=app:app"]