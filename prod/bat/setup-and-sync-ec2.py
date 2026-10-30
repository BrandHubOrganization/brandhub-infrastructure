#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Automated EC2 Infrastructure Setup & Database Synchronization via AWS SSM + S3 Presigned URLs.
No manual SSH or .pem key handling required.
"""
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

os.environ["PYTHONUTF8"] = "1"

SERVICE_INSTANCE_ID = "i-07283e8467a059e5a"
BACKEND_INSTANCE_ID = "i-0761e3bd96ca5d4de"
S3_BUCKET = "brandhubmedia"
S3_PREFIX = "_deploy-init-temp"

ROOT_DIR = Path(r"D:\capstone\brandhub")
INFRA_DB_DIR = ROOT_DIR / "brandhub-infrastructure" / "docs" / "database"
DEPLOY_DIR = ROOT_DIR / "brandhub-deloy"

INIT_SQL_FILE = INFRA_DB_DIR / "init-postgres-v2.sql"
FULL_DUMP_FILE = INFRA_DB_DIR / "backups" / "brandhub_postgres_full_20261029.dump"
FULL_SQL_FILE = INFRA_DB_DIR / "backups" / "brandhub_postgres_full_20261029.sql"
DEPLOY_SCHEMA_COPY = DEPLOY_DIR / "key_pair" / "internal-services" / "schema-full-2026-10-29.sql"

def run_cmd(cmd):
    return subprocess.check_output(cmd, text=True, encoding="utf-8", errors="replace").strip()


def run_ssm(instance_id, commands, comment="BrandHub EC2 Setup"):
    params = json.dumps({"commands": commands})
    cmd_id = run_cmd([
        "aws", "ssm", "send-command",
        "--instance-ids", instance_id,
        "--document-name", "AWS-RunShellScript",
        "--comment", comment,
        "--parameters", params,
        "--query", "Command.CommandId",
        "--output", "text",
    ])
    print(f"  -> Sent SSM command {cmd_id} to {instance_id} ({comment})...")
    for _ in range(90):
        time.sleep(3)
        res_raw = run_cmd([
            "aws", "ssm", "get-command-invocation",
            "--command-id", cmd_id,
            "--instance-id", instance_id,
            "--output", "json",
        ])
        res = json.loads(res_raw)
        status = res.get("Status")
        if status in ("Success", "Failed", "Cancelled", "TimedOut"):
            print(f"  -> [{instance_id}] Status: {status}")
            if res.get("StandardOutputContent"):
                print(res["StandardOutputContent"])
            if res.get("StandardErrorContent"):
                print("STDERR:\n" + res["StandardErrorContent"], file=sys.stderr)
            if status != "Success":
                raise RuntimeError(f"SSM command failed on {instance_id} with status {status}")
            return
    raise TimeoutError(f"SSM command {cmd_id} timed out on {instance_id}")


def main():
    print("1. Updating local schema copy in brandhub-deloy...")
    if FULL_SQL_FILE.exists():
        shutil.copy2(FULL_SQL_FILE, DEPLOY_SCHEMA_COPY)
        print(f"   Copied {FULL_SQL_FILE.name} -> {DEPLOY_SCHEMA_COPY}")

    print("\n2. Uploading init-postgres-v2.sql and full dump to temporary S3 staging...")
    s3_init_uri = f"s3://{S3_BUCKET}/{S3_PREFIX}/init-postgres-v2.sql"
    s3_dump_uri = f"s3://{S3_BUCKET}/{S3_PREFIX}/brandhub_full.dump"
    try:
        run_cmd(["aws", "s3", "cp", str(INIT_SQL_FILE), s3_init_uri, "--quiet"])
        run_cmd(["aws", "s3", "cp", str(FULL_DUMP_FILE), s3_dump_uri, "--quiet"])
        init_url = run_cmd(["aws", "s3", "presign", s3_init_uri, "--expires-in", "900"])
        dump_url = run_cmd(["aws", "s3", "presign", s3_dump_uri, "--expires-in", "900"])

        print("\n3. Bootstrapping & syncing DB/Redis/Queue on brandhub-service EC2...")
        ssm_commands = [
            "set -euo pipefail",
            "cd /home/ec2-user/brandhub/ecr",
            "mkdir -p init",
            f"curl -fsSL '{init_url}' -o init/schema.sql",
            "chmod 644 init/schema.sql",
            "chown ec2-user:ec2-user init/schema.sql",
            # Remove local neo4j container/config (Neo4j uses external cloud/web instance)
            "python3 -c \"import json; p='service.compose.json'; d=json.load(open(p)); d['services'].pop('neo4j', None); d.get('volumes', {}).pop('neo4j-data', None); d.get('volumes', {}).pop('neo4j-logs', None); json.dump(d, open(p, 'w'), indent=2)\"",
            "chown ec2-user:ec2-user service.compose.json",
            "docker rm -f brandhub-neo4j || true",
            "rm -f env/neo4j.env || true",
            # Ensure all infrastructure containers are running and healthy
            "sudo -u ec2-user docker compose -f service.compose.json up -d --remove-orphans postgres redis rabbitmq chromadb",
            # Download full synchronized dump
            f"curl -fsSL '{dump_url}' -o /tmp/brandhub_sync.dump",
            "docker cp /tmp/brandhub_sync.dump brandhub-postgres:/tmp/brandhub_sync.dump",
            "rm -f /tmp/brandhub_sync.dump",
            # Stop business-service briefly while restoring PostgreSQL
            "sudo -u ec2-user docker compose -f service.compose.json stop business-service",
            # Backup pre-sync DB inside container just in case
            "docker exec brandhub-postgres pg_dump -Fc -U brandhub -d brandhub -f /tmp/pre_sync_backup.dump",
            # Terminate active connections & restore full synchronized dump
            "docker exec brandhub-postgres psql -U brandhub -d postgres -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'brandhub' AND pid <> pg_backend_pid();\"",
            "docker exec brandhub-postgres pg_restore --clean --if-exists --no-owner --no-privileges -U brandhub -d brandhub /tmp/brandhub_sync.dump",
            "docker exec brandhub-postgres rm -f /tmp/brandhub_sync.dump",
            # Start business-service, publisher-service, ai-service and wait for healthy state
            "sudo -u ec2-user docker compose -f service.compose.json up -d --wait --wait-timeout 180 business-service publisher-service ai-service",
            # Verify final row counts & container statuses
            "docker exec brandhub-postgres psql -U brandhub -d brandhub -c \"SELECT (SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE') AS tables, (SELECT count(*) FROM users) AS users, (SELECT count(*) FROM agencies) AS agencies, (SELECT count(*) FROM workspaces) AS workspaces, (SELECT count(*) FROM workspace_members) AS members, (SELECT count(*) FROM client_profiles) AS clients, (SELECT count(*) FROM media_packages) AS packages, (SELECT count(*) FROM media_campaigns) AS campaigns;\"",
            "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
        ]
        run_ssm(SERVICE_INSTANCE_ID, ssm_commands, comment="Sync BrandHub Infra & PostgreSQL")

        print("\n4. Verifying API Gateway & Nginx on brandhub-backend-service EC2...")
        run_ssm(BACKEND_INSTANCE_ID, [
            "set -euo pipefail",
            "cd /home/ec2-user/brandhub/ecr",
            "python3 -c \"p='env/api-gateway.env'; t=open(p).read(); t=t.replace('\\\"allowedOrigins\\\":[\\\"https://brandhub.id.vn\\\"]', '\\\"allowedOrigins\\\":[\\\"https://brandhub.id.vn\\\",\\\"http://localhost:3000\\\",\\\"http://localhost:5173\\\",\\\"http://localhost:8090\\\"]'); open(p,'w').write(t)\"",
            "sudo -u ec2-user docker compose -f backend.compose.json up -d --wait --wait-timeout 120 api-gateway nginx",
            "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
        ], comment="Verify BrandHub Backend Gateway")

    finally:
        print("\n5. Cleaning up temporary S3 staging objects...")
        subprocess.run(["aws", "s3", "rm", f"s3://{S3_BUCKET}/{S3_PREFIX}/", "--recursive", "--quiet"], check=False)

    print("\nDONE! Both EC2 instances and all DB/Redis/Queue/App services are initialized and synchronized.")


if __name__ == "__main__":
    main()
