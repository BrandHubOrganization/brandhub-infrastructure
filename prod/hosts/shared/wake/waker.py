"""Wake a sleeping EC2 when a request reaches it.

Nginx sends a request here when its upstream host is stopped (502/504):
    GET/POST /wake/<target>  ->  ec2:StartInstances on that target  ->  503 + Retry-After
Targets come from WAKE_TARGETS="edit-video=i-...,crawl=i-...". Only these instance IDs can be started,
and IAM additionally limits StartInstances to instances tagged Wakeable=true.

Standard library only (SigV4 + IMDSv2), so it runs on the stock python image with no build step.
"""
import datetime
import hashlib
import hmac
import json
import os
import re
import time
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

REGION = os.environ.get("AWS_REGION", "ap-southeast-1")
TARGETS = dict(item.split("=", 1) for item in os.environ.get("WAKE_TARGETS", "").split(",") if "=" in item)
RETRY_AFTER = int(os.environ.get("WAKE_RETRY_AFTER", "60"))
IMDS = "http://169.254.169.254"
_creds = {"expires": 0}
_last_start = {}


def imds(path):
    token = urllib.request.urlopen(urllib.request.Request(
        IMDS + "/latest/api/token", method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "300"}), timeout=2).read().decode()
    return urllib.request.urlopen(urllib.request.Request(
        IMDS + path, headers={"X-aws-ec2-metadata-token": token}), timeout=2).read().decode()


def credentials():
    if time.time() < _creds["expires"] - 300:
        return _creds
    role = imds("/latest/meta-data/iam/security-credentials/").strip()
    data = json.loads(imds("/latest/meta-data/iam/security-credentials/" + role))
    expires = datetime.datetime.strptime(data["Expiration"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc)
    _creds.update(key=data["AccessKeyId"], secret=data["SecretAccessKey"], token=data["Token"],
                  expires=expires.timestamp())
    return _creds


def ec2(action, **params):
    """Signed EC2 Query API call (SigV4)."""
    c = credentials()
    host = f"ec2.{REGION}.amazonaws.com"
    body = urllib.parse.urlencode({"Action": action, "Version": "2016-11-15", **params})
    now = datetime.datetime.now(datetime.timezone.utc)
    amz_date, day = now.strftime("%Y%m%dT%H%M%SZ"), now.strftime("%Y%m%d")
    headers = {"content-type": "application/x-www-form-urlencoded; charset=utf-8", "host": host,
               "x-amz-date": amz_date, "x-amz-security-token": c["token"]}
    signed = ";".join(sorted(headers))
    canonical = "\n".join(["POST", "/", "", "".join(f"{k}:{headers[k]}\n" for k in sorted(headers)), signed,
                           hashlib.sha256(body.encode()).hexdigest()])
    scope = f"{day}/{REGION}/ec2/aws4_request"
    to_sign = "\n".join(["AWS4-HMAC-SHA256", amz_date, scope, hashlib.sha256(canonical.encode()).hexdigest()])
    key = ("AWS4" + c["secret"]).encode()
    for part in (day, REGION, "ec2", "aws4_request"):
        key = hmac.new(key, part.encode(), hashlib.sha256).digest()
    signature = hmac.new(key, to_sign.encode(), hashlib.sha256).hexdigest()
    headers["authorization"] = (f"AWS4-HMAC-SHA256 Credential={c['key']}/{scope}, SignedHeaders={signed}, "
                                f"Signature={signature}")
    req = urllib.request.Request(f"https://{host}/", data=body.encode(), headers=headers, method="POST")
    return urllib.request.urlopen(req, timeout=10).read().decode()


def state(instance_id):
    xml = ec2("DescribeInstances", **{"InstanceId.1": instance_id})
    match = re.search(r"<instanceState>\s*<code>\d+</code>\s*<name>([a-z-]+)</name>", xml)
    return match.group(1) if match else "unknown"


class Handler(BaseHTTPRequestHandler):
    def handle_wake(self):
        match = re.match(r"^/wake/([a-z0-9-]+)", self.path)
        if not match or match.group(1) not in TARGETS:
            return self.reply(404, {"status": "UNKNOWN_TARGET"})
        target, instance_id = match.group(1), TARGETS[match.group(1)]
        try:
            current = state(instance_id)
            if current == "stopped" and time.time() - _last_start.get(target, 0) > 20:
                ec2("StartInstances", **{"InstanceId.1": instance_id})
                _last_start[target] = time.time()
                current = "pending"
                print(f"started {target} {instance_id}", flush=True)
        except Exception as exc:  # never leak AWS errors to clients
            print(f"wake {target} failed: {type(exc).__name__}: {exc}", flush=True)
            return self.reply(503, {"status": "WAKE_FAILED", "target": target}, retry=RETRY_AFTER)
        # running: the host is up but its service is still starting.
        return self.reply(503, {"status": "STARTING", "target": target, "instanceState": current}, retry=RETRY_AFTER)

    def reply(self, code, payload, retry=None):
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        if retry:
            self.send_header("Retry-After", str(retry))
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    do_GET = do_POST = do_PUT = do_DELETE = do_PATCH = handle_wake

    def log_message(self, fmt, *args):
        print("%s %s" % (self.address_string(), fmt % args), flush=True)


if __name__ == "__main__":
    print(f"waker on :8099 targets={sorted(TARGETS)}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", 8099), Handler).serve_forever()
