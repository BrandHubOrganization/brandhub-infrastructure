FROM python:3.12-slim-bookworm

# pg_dump 17 (matches postgres:17), redis-cli, mongodump.
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl gnupg ca-certificates redis-tools \
 && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update && apt-get install -y --no-install-recommends postgresql-client-17 \
 && curl -fsSL -o /tmp/mdt.deb https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-x86_64-100.10.0.deb \
 && apt-get install -y --no-install-recommends /tmp/mdt.deb \
 && rm -f /tmp/mdt.deb && apt-get purge -y curl gnupg && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backup ./backup

RUN useradd -r -u 10001 dbbackup && mkdir -p /var/lib/db-backup && chown dbbackup /var/lib/db-backup
USER dbbackup
VOLUME /var/lib/db-backup
EXPOSE 8090
HEALTHCHECK --interval=60s --timeout=5s CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8090/health')"
CMD ["uvicorn", "backup.app:create_app", "--factory", "--host", "0.0.0.0", "--port", "8090"]
