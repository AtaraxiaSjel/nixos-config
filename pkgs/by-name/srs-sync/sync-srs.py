#!/usr/bin/env python3
"""Mirror sing-box .srs rule-sets from upstream to own hosting.

Flow per file: download (first working upstream wins) -> sha256 vs manifest ->
upload only on change. Destinations are optional and independent.
Usage: sync-srs.py [sync|--check|--force] [--dry-run] [--verbose]
Requires boto3 only when S3_BUCKET is set (lazy import, fail-closed).
"""
import argparse
import hashlib
import logging
import os
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

LOG = logging.getLogger("srs-sync")
HERE = os.path.dirname(os.path.realpath(__file__))

GEOIP_UP = os.environ.get(
    "GEOIP_UP",
    "https://cdn.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set"
    " https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set",
).split()
GEOSITE_UP = os.environ.get(
    "GEOSITE_UP",
    "https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set"
    " https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set",
).split()
FILES = os.environ.get("FILES", os.path.join(HERE, "files.txt"))
MANIFEST = os.environ.get("MANIFEST", os.path.join(HERE, "sha256.manifest"))


def load_env_file(path):
    # Minimal shell-env parser (KEY=val, quotes stripped); real env wins.
    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                k, v = k.strip(), v.strip().strip("\"'")
                if k and k not in os.environ:
                    os.environ[k] = v
    except FileNotFoundError:
        pass


def fetch(url, dest, timeout=60, retries=3):
    # GET with linear backoff; raises on last failure.
    err = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(url, timeout=timeout) as r, open(dest, "wb") as f:
                while True:
                    chunk = r.read(65536)
                    if not chunk:
                        return
                    f.write(chunk)
        except Exception as e:  # noqa: BLE001 - retried, reported by caller
            err = e
            LOG.debug("fetch %s attempt %d failed: %s", url, attempt + 1, e)
            time.sleep(attempt + 1)
    raise err


def probe(url, timeout=30):
    try:
        with urllib.request.urlopen(url, timeout=timeout):
            return True
    except Exception as e:  # noqa: BLE001 - MISS is a normal outcome
        LOG.debug("probe %s failed: %s", url, e)
        return False


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def read_files():
    out = []
    with open(FILES, encoding="utf-8") as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2 and not parts[0].startswith("#"):
                out.append((parts[0], parts[1]))
    return out


def read_manifest():
    sums = {}
    try:
        with open(MANIFEST, encoding="utf-8") as f:
            for line in f:
                p = line.split()
                if len(p) >= 2:
                    sums[p[1]] = p[0]
    except FileNotFoundError:
        pass
    return sums


def write_manifest(sums):
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(MANIFEST) or ".")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        for name, s in sums.items():
            f.write(f"{s}  {name}\n")
    os.replace(tmp, MANIFEST)


def do_check(entries):
    failed = 0
    for src, name in entries:
        bases = GEOIP_UP if src == "geoip" else GEOSITE_UP
        for base in bases:
            if probe(f"{base}/{name}"):
                LOG.info("OK %s <- %s", name, base)
                break
        else:
            LOG.warning("MISS %s (no working upstream)", name)
            failed += 1
    return failed


def s3_upload(staged, workdir, dry):
    bucket = os.environ.get("S3_BUCKET", "")
    if not bucket:
        return 0
    endpoint = os.environ.get("S3_ENDPOINT", "")
    if not endpoint:
        LOG.error("S3_ENDPOINT required")
        return 1
    try:
        import boto3
        import botocore.config
        import botocore.exceptions
    except ImportError:
        LOG.error("boto3 missing (pip install boto3 / nix python3.withPackages)")
        return 1
    prefix = os.environ.get("S3_PREFIX", "srs")
    cfg = botocore.config.Config(retries={"max_attempts": 5, "mode": "adaptive"})
    try:
        s3 = boto3.client("s3", endpoint_url=endpoint, config=cfg)
    except Exception as e:  # noqa: BLE001 - creds/endpoint misconfig
        LOG.error("s3 client init failed: %s", e)
        return 1
    failed = 0
    for _, name in staged:
        key = f"{prefix}/{name}"
        if dry:
            LOG.info("DRY s3://%s/%s", bucket, key)
            continue
        try:
            s3.upload_file(os.path.join(workdir, name), bucket, key,
                           ExtraArgs={"ContentType": "application/octet-stream"})
        except botocore.exceptions.BotoCoreError as e:
            LOG.error("s3 upload %s failed: %s", name, e)
            failed += 1
    if not failed and not dry:
        LOG.info("s3 upload done")
    return failed


def vps_upload(staged, workdir, dry):
    dest = os.environ.get("VPS_DEST", "")
    if not dest:
        return 0
    key = os.environ.get("SSH_KEY", "")
    port = os.environ.get("SSH_PORT", "")
    failed = 0
    for _, name in staged:
        # BatchMode: never hang on a prompt under systemd; fail loud instead.
        # accept-new (TOFU): first connect trusts and records, later ones
        # verify. Deploy target moves more often than state is wiped.
        khost = os.path.expanduser("~/.ssh/known_hosts")
        cmd = ["scp", "-q", "-o", "BatchMode=yes", "-o", "ConnectTimeout=20",
               "-o", "StrictHostKeyChecking=accept-new",
               "-o", f"UserKnownHostsFile={khost}"]
        if key:
            cmd += ["-i", key]
        if port:
            cmd += ["-P", port]  # scp quirk: -P, not -p
        cmd += [os.path.join(workdir, name), f"{dest}/{name}"]
        if dry:
            LOG.info("DRY %s", " ".join(cmd))
            continue
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            LOG.error("scp %s failed: %s", name, r.stderr.strip())
            failed += 1
    if not failed and not dry:
        LOG.info("vps upload done")
    return failed


def git_commit():
    if os.environ.get("GIT_COMMIT", "0") != "1" or not os.path.isdir(os.path.join(HERE, ".git")):
        return
    env = dict(os.environ,
               GIT_AUTHOR_NAME=os.environ.get("GIT_USER", "srs-sync"),
               GIT_AUTHOR_EMAIL=os.environ.get("GIT_EMAIL", "srs-sync@localhost"),
               GIT_COMMITTER_NAME=os.environ.get("GIT_USER", "srs-sync"),
               GIT_COMMITTER_EMAIL=os.environ.get("GIT_EMAIL", "srs-sync@localhost"))
    base = ["git", "-C", HERE]
    subprocess.run(base + ["add", os.path.basename(MANIFEST)], capture_output=True, env=env)
    subprocess.run(base + ["commit", "-qm", f"srs sync {time.strftime('%F', time.gmtime())}"],
                   capture_output=True, env=env)


def do_sync(entries, force, dry):
    sums = read_manifest()
    staged, failed = [], 0
    with tempfile.TemporaryDirectory() as work:
        for src, name in entries:
            bases = GEOIP_UP if src == "geoip" else GEOSITE_UP
            path = os.path.join(work, name)
            for base in bases:
                try:
                    fetch(f"{base}/{name}", path)
                    break
                except Exception as e:  # noqa: BLE001 - next mirror tried
                    LOG.debug("fetch %s from %s failed: %s", name, base, e)
            else:
                LOG.error("download failed for %s", name)
                failed += 1
                continue
            s = sha256(path)
            if force or s != sums.get(name):
                staged.append((s, name))
                LOG.info("STAGED %s (%s)", name, "forced" if s == sums.get(name) else "changed")
        if failed:
            return failed
        if not staged:
            LOG.info("nothing changed")
            return 0
        failed += s3_upload(staged, work, dry)
        failed += vps_upload(staged, work, dry)
        if failed:
            return failed
        if not dry:
            for s, name in staged:
                sums[name] = s
            write_manifest(sums)
            git_commit()
        LOG.info("done")
    return 0


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    mode = "sync"
    if argv and argv[0] in ("sync", "--check", "--force"):
        mode = argv.pop(0)  # may look like a flag; argparse would choke
    ap = argparse.ArgumentParser(description="mirror .srs rule-sets to own hosting")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO,
                        format="%(asctime)s %(message)s", datefmt="%Y-%m-%dT%H:%M:%SZ")
    logging.Formatter.converter = time.gmtime
    load_env_file(os.path.join(HERE, "srs-sync.env"))
    entries = read_files()
    if mode == "--check":
        return 1 if do_check(entries) else 0
    return do_sync(entries, force=mode == "--force", dry=a.dry_run)


if __name__ == "__main__":
    sys.exit(main())
