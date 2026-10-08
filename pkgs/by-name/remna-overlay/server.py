#!/usr/bin/env python3
"""remna-overlay: serve extended sing-box JSON over HTTP.

GET /ext/<shortUuid> and GET /api/sub/<shortUuid> -> fetch panel subscription
twice (SINGBOX JSON + XRAY_BASE64), append type=xhttp outbounds built from
vless:// links, wire tags into urltest/selector.
GET /ext/health -> ok

Squad overlay: members of OVERLAY_SQUAD_UUIDS (external or internal squad
uuids) additionally get OVERLAY_FILE merged in (outbounds appended, route
rules prepended). Membership resolved via panel API user list (size/page);
any failure serves the base config (fail-closed). ADMIN_UUIDS short-circuits.
Cache key includes the overlay verdict, so member/non-member bodies never mix.

Loop safety: our upstream UA (remna-overlay/1.0) intentionally contains no
"extended" token, so nginx UA-routing can never send our own panel fetches
back to us; plus we tag them with X-Remna-Overlay: 1 which nginx excludes.

Conversion logic mirrors stand/sbx-convert.py v1 (schema pinned to
shtorm-7/sing-box-extended option/v2ray_transport.go). Stdlib only.
Env: PORT (8090), PANEL_BASE, CACHE_TTL (60), PANEL_API_BASE (=PANEL_BASE),
PANEL_API_KEY (unset disables overlay), OVERLAY_SQUAD_UUIDS (csv),
OVERLAY_FILE (/app/overlay-home.json), OVERLAY_CACHE_TTL (300), ADMIN_UUIDS (csv),
URLTEST_EXCLUDE_PANEL_TAGS (csv, panel host tags stripped from urltest
lists only, outbounds stay reachable via routing),
SELECTOR_EXCLUDE_PANEL_TAGS (csv, same for selector lists only),
HOSTS_CACHE_TTL (300).
"""
import base64
import json
import os
import re
import threading
import time
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_ADDR = os.environ.get("LISTEN_ADDR", "0.0.0.0")
PORT = int(os.environ.get("PORT", "8090"))
PANEL_BASE = os.environ.get("PANEL_BASE", "http://remnawave:3000")
CACHE_TTL = int(os.environ.get("CACHE_TTL", "60"))
PANEL_API_BASE = os.environ.get("PANEL_API_BASE", PANEL_BASE)
PANEL_API_KEY = os.environ.get("PANEL_API_KEY", "")
OVERLAY_SQUAD_UUIDS = {s for s in os.environ.get("OVERLAY_SQUAD_UUIDS", "").split(",") if s}
ADMIN_UUIDS = {s for s in os.environ.get("ADMIN_UUIDS", "").split(",") if s}
OVERLAY_FILE = os.environ.get("OVERLAY_FILE", "/app/overlay-home.json")
OVERLAY_CACHE_TTL = int(os.environ.get("OVERLAY_CACHE_TTL", "300"))
URLTEST_EXCLUDE_PANEL_TAGS = {s for s in os.environ.get("URLTEST_EXCLUDE_PANEL_TAGS", "").split(",") if s}
SELECTOR_EXCLUDE_PANEL_TAGS = {s for s in os.environ.get("SELECTOR_EXCLUDE_PANEL_TAGS", "").split(",") if s}
HOSTS_CACHE_TTL = int(os.environ.get("HOSTS_CACHE_TTL", "300"))
UA_JSON = "remna-overlay/1.0"
# Link fetcher must match NO SRR rule (default response = base64 links).
# Must contain neither "extended" nor "remna-overlay" (rule 1 matches those).
UA_B64 = "ro-b64/1.0"

UUID_RE = re.compile(r"^[A-Za-z0-9_-]{4,64}$")
PATH_RE = re.compile(r"(?:/ext|/api/sub)?/([A-Za-z0-9_-]{4,64})")
_cache = {}
_cache_lock = threading.Lock()
_verdicts = {}
_hosts_cache = {}


def parse_singbox_version(ua):
    m = re.search(r"sing-box[/\s](\d+)\.(\d+)\.(\d+)", ua or "")
    if not m:
        return None
    return (int(m.group(1)), int(m.group(2)), int(m.group(3)))


def mlkem_allowed(ua):
    v = parse_singbox_version(ua)
    return v is not None and v >= (1, 14, 1)


def get_host_tags():
    now = time.time()
    with _cache_lock:
        if _hosts_cache.get("map") is not None and now - _hosts_cache.get("at", 0) < HOSTS_CACHE_TTL:
            return _hosts_cache["map"]
    mapping = {}
    try:
        d = api_get("/api/hosts/")
        hosts = d.get("response") or []
        if isinstance(hosts, dict):
            hosts = hosts.get("hosts") or []
        for h in hosts:
            if not isinstance(h, dict):
                continue
            remark = h.get("remark") or ""
            if remark:
                mapping.setdefault(remark, set()).update(h.get("tags") or [])
    except Exception as e:
        print(f"HOSTS-ERR {type(e).__name__} {e}", flush=True)
        with _cache_lock:
            if _hosts_cache.get("map") is not None:
                return _hosts_cache["map"]
        return {}
    with _cache_lock:
        _hosts_cache["at"] = now
        _hosts_cache["map"] = mapping
    return mapping


def group_excluded(tag, mapping, excluded):
    if not excluded or not tag:
        return False
    return bool(mapping.get(tag, set()) & excluded)


def fetch(url, ua, timeout=25):
    # Panel ProxyCheckMiddleware destroys sockets without proxy headers;
    # loopback fetch must impersonate the reverse proxy (nginx adds these).
    req = urllib.request.Request(url, headers={
        "User-Agent": ua, "X-Remna-Overlay": "1",
        "X-Forwarded-For": "127.0.0.1", "X-Forwarded-Proto": "https",
    })
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def api_get(path, timeout=25):
    req = urllib.request.Request(PANEL_API_BASE + path, headers={
        "Authorization": f"Bearer {PANEL_API_KEY}",
        "X-Forwarded-For": "127.0.0.1", "X-Forwarded-Proto": "https",
    })
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read())


def find_user(short_uuid):
    page, size = 1, 100
    while True:
        d = api_get(f"/api/users?size={size}&page={page}")
        users = (d.get("response") or {}).get("users") or []
        for u in users:
            if u.get("shortUuid") == short_uuid:
                return u
        if len(users) < size:
            return None
        page += 1


def overlay_allowed(short_uuid):
    if short_uuid in ADMIN_UUIDS:
        return True
    if not PANEL_API_KEY or not OVERLAY_SQUAD_UUIDS:
        return False
    now = time.time()
    with _cache_lock:
        v = _verdicts.get(short_uuid)
        if v and now - v[0] < OVERLAY_CACHE_TTL:
            return v[1]
    try:
        u = find_user(short_uuid)
        squads = set()
        if u:
            if u.get("externalSquadUuid"):
                squads.add(u["externalSquadUuid"])
            squads.update(s.get("uuid") for s in u.get("activeInternalSquads") or [])
        ok = bool(squads & OVERLAY_SQUAD_UUIDS)
    except Exception as e:
        print(f"OVERLAY-ERR {short_uuid}: {type(e).__name__} {e}", flush=True)
        ok = False
    with _cache_lock:
        _verdicts[short_uuid] = (now, ok)
    return ok


def apply_overlay(skel, user_uuid):
    with open(OVERLAY_FILE, encoding="utf-8") as f:
        raw = f.read().replace("{{UUID}}", user_uuid or "")
    ov = json.loads(raw)
    have = {o.get("tag") for o in skel.get("outbounds", [])}
    for ob in ov.get("outbounds") or []:
        if ob.get("tag") not in have:
            skel["outbounds"].append(ob)
            have.add(ob.get("tag"))
    if ov.get("route_rules"):
        rt = skel.setdefault("route", {})
        rt.setdefault("rules", [])[:] = (ov["route_rules"] + rt["rules"])
    dns = skel.setdefault("dns", {})
    have_srv = {s.get("tag") for s in dns.get("servers", [])}
    for s in ov.get("dns_servers") or []:
        if s.get("tag") not in have_srv:
            dns.setdefault("servers", []).append(s)
            have_srv.add(s.get("tag"))
    if ov.get("dns_rules"):
        dns.setdefault("rules", [])[:] = (ov["dns_rules"] + dns["rules"])


def parse_vless(link):
    u = urllib.parse.urlsplit(link.strip())
    q = dict(urllib.parse.parse_qsl(u.query))
    extra = {}
    if q.get("extra"):
        try:
            extra = json.loads(q["extra"])
        except json.JSONDecodeError:
            pass
    return {
        "uuid": u.username or "",
        "server": u.hostname or "",
        "port": u.port or 443,
        "tag": urllib.parse.unquote(u.fragment or ""),
        "net": q.get("type", "tcp"),
        "host": q.get("host", ""),
        "path": q.get("path", ""),
        "security": q.get("security", "none"),
        "mode": q.get("mode", ""),
        "sni": q.get("sni", ""),
        "fp": q.get("fp", "chrome"),
        "pbk": q.get("pbk", ""),
        "sid": q.get("sid", ""),
        "extra": extra,
    }


def build_tls(p):
    if p["security"] == "reality":
        tls = {"enabled": True, "server_name": p["sni"] or p["server"],
               "reality": {"enabled": True}, "utls": {"enabled": True, "fingerprint": p["fp"] or "chrome"}}
        if p["pbk"]:
            tls["reality"]["public_key"] = p["pbk"]
        if p["sid"]:
            tls["reality"]["short_id"] = p["sid"]
        return tls
    if p["security"] == "tls":
        tls = {"enabled": True, "server_name": p["sni"] or p["server"],
               "utls": {"enabled": True, "fingerprint": p["fp"] or "chrome"}}
        return tls
    return None


def build_xhttp_transport(p):
    ex = p["extra"] or {}
    t = {"type": "xhttp", "mode": ex.get("mode") or p.get("mode") or "auto"}
    if p["host"]:
        t["host"] = p["host"]
    if p["path"]:
        t["path"] = p["path"]
    pad = ex.get("xPaddingBytes") or (ex.get("extra") or {}).get("xPaddingBytes")
    t["x_padding_bytes"] = pad if pad else "100-1000"
    for lk, jk in (("scMaxEachPostBytes", "sc_max_each_post_bytes"),
                   ("scMinPostsIntervalMs", "sc_min_posts_interval_ms"),
                   ("scStreamUpServerSecs", "sc_stream_up_server_secs")):
        if ex.get(lk) is not None:
            t[jk] = ex[lk]
    return t


def build_extended(short_uuid, allowed, client_ua=""):
    mlkem = mlkem_allowed(client_ua)
    tagmap = get_host_tags() if (URLTEST_EXCLUDE_PANEL_TAGS or SELECTOR_EXCLUDE_PANEL_TAGS) else {}
    sub = f"{PANEL_BASE}/api/sub/{short_uuid}"
    skel = json.loads(fetch(sub, UA_JSON))
    for ib in skel.get("inbounds", []):
        if ib.get("type") == "tun":
            ib["endpoint_independent_nat"] = True  # panel schema drops it, clients need full-cone
    links = base64.b64decode(fetch(sub, UA_B64)).decode().strip().splitlines()
    user_uuid = ""
    for link in links:
        if link.startswith("vless://"):
            user_uuid = parse_vless(link)["uuid"]
            break
    if allowed:
        try:
            apply_overlay(skel, user_uuid)
        except Exception as e:
            print(f"OVERLAY-SKIP {short_uuid}: {type(e).__name__} {e}", flush=True)
    have_tags = {o.get("tag") for o in skel.get("outbounds", [])}
    added = []
    for link in links:
        if not link.startswith("vless://"):
            continue
        p = parse_vless(link)
        if p["net"] != "xhttp" or not p["tag"] or p["tag"] in have_tags:
            continue
        if "clean" in p["tag"].lower():
            continue  # clean dupes stay panel-side, extended gets full only
        ob = {"type": "vless", "tag": p["tag"], "server": p["server"],
              "server_port": p["port"], "uuid": p["uuid"]}
        tls = build_tls(p)
        if tls:
            ob["tls"] = tls
        ob["transport"] = build_xhttp_transport(p)
        skel["outbounds"].append(ob)
        have_tags.add(p["tag"])
        added.append(p["tag"])
    for o in skel.get("outbounds", []):
        otype = o.get("type")
        if otype not in ("urltest", "selector") or not isinstance(o.get("outbounds"), list):
            continue
        excluded = URLTEST_EXCLUDE_PANEL_TAGS if otype == "urltest" else SELECTOR_EXCLUDE_PANEL_TAGS
        for t in added:
            if t not in o["outbounds"] and not group_excluded(t, tagmap, excluded):
                o["outbounds"].append(t)
        o["outbounds"][:] = [t for t in o["outbounds"] if not group_excluded(t, tagmap, excluded)]
    if mlkem:
        for o in skel.get("outbounds", []):
            tls = o.get("tls") if isinstance(o.get("tls"), dict) else None
            real = tls.get("reality") if isinstance(tls, dict) else None
            if o.get("type") == "vless" and isinstance(real, dict) and real.get("enabled"):
                real["support_x25519mlkem768"] = True
    tags = [o.get("tag") for o in skel["outbounds"]]
    tags = [o.get("tag") for o in skel["outbounds"]]
    assert len(tags) == len(set(tags)), "duplicate tags"
    assert (skel.get("route") or {}).get("final") in tags, "route.final missing"
    return json.dumps(skel, ensure_ascii=False, separators=(",", ":")).encode()


class Handler(BaseHTTPRequestHandler):
    server_version = "remna-overlay/1.0"

    def log_message(self, *a):
        pass

    def _send(self, code, body, ctype="application/json"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urllib.parse.urlsplit(self.path).path
        if path == "/ext/health":
            self._send(200, b"ok", "text/plain")
            return
        m = PATH_RE.fullmatch(path or "")
        if not m or not UUID_RE.fullmatch(m.group(1)):
            self._send(404, b"not found", "text/plain")
            return
        uuid = m.group(1)
        client_ua = self.headers.get("User-Agent", "")
        key = (uuid, overlay_allowed(uuid), mlkem_allowed(client_ua))
        now = time.time()
        with _cache_lock:
            hit = _cache.get(key)
            if hit and now - hit[0] < CACHE_TTL:
                print(f"HIT {uuid} ov={key[1]} mlkem={key[2]}", flush=True)
                self._send(200, hit[1])
                return
        try:
            body = build_extended(uuid, key[1], client_ua)
        except Exception as e:
            print(f"ERR {uuid}: {type(e).__name__} {e}", flush=True)
            self._send(502, b"upstream error", "text/plain")
            return
        with _cache_lock:
            _cache[key] = (now, body)
        print(f"MISS {uuid} ov={key[1]} mlkem={key[2]} {len(body)}B", flush=True)
        self._send(200, body)


if __name__ == "__main__":
    print(f"remna-overlay on {LISTEN_ADDR}:{PORT} -> {PANEL_BASE} (cache {CACHE_TTL}s)", flush=True)
    ThreadingHTTPServer((LISTEN_ADDR, PORT), Handler).serve_forever()
