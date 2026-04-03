"""
server.py
=========
MoMo SMS transaction REST API.
Built with Python's standard http.server; no third-party dependencies.

Endpoints:
    GET    /transactions            List records (optional ?address= ?limit= ?offset=)
    GET    /transactions/<id>       Fetch one record
    POST   /transactions            Create a record
    PUT    /transactions/<id>       Patch a record
    DELETE /transactions/<id>       Remove a record

Auth:   HTTP Basic  (teamred / r3dM0m0#2024)
Port:   9000
"""

import base64
import json
import os
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "dsa"))
from xml_parser import load_sms_records

# ── Config ────────────────────────────────────────────────────────────────────
HOST      = "localhost"
PORT      = 9000
API_USER  = "teamred"
API_PASS  = "r3dM0m0#2024"

# ── Data store ────────────────────────────────────────────────────────────────
_xml = os.path.join(os.path.dirname(__file__), "..", "modified_sms_v2.xml")
if not os.path.exists(_xml):
    _xml = "modified_sms_v2.xml"

record_list = load_sms_records(_xml)
record_map  = {r["id"]: r for r in record_list}
_next_id    = max(record_map) + 1 if record_map else 1


# ── Auth helper ───────────────────────────────────────────────────────────────

def _check_credentials(header_value):
    """
    Decode a Basic Auth header value and verify against API_USER / API_PASS.

    Args:
        header_value (str): Raw value of the Authorization header.

    Returns:
        bool: True if credentials match, False otherwise.
    """
    if not header_value or not header_value.startswith("Basic "):
        return False
    try:
        token    = header_value.split(" ", 1)[1]
        user, pw = base64.b64decode(token).decode().split(":", 1)
        return user == API_USER and pw == API_PASS
    except Exception:
        return False


# ── Request handler ───────────────────────────────────────────────────────────

class TransactionHandler(BaseHTTPRequestHandler):
    """Handles all HTTP requests for the /transactions resource."""

    # ── Logging ──────────────────────────────────────────────────────────────
    def log_message(self, fmt, *args):
        ts = time.strftime("%H:%M:%S")
        print(f"[{ts}]  {args[0].split()[0]:<7} {args[0].split()[1] if len(args[0].split()) > 1 else ''}  →  {args[1]}")

    # ── Low-level response writers ────────────────────────────────────────────
    def _write_json(self, status, payload):
        """Serialise payload to JSON and send with correct headers."""
        data = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type",   "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def _write_error(self, status, message):
        """Send a JSON error payload."""
        payload = {"error": message, "code": status}
        data    = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type",   "application/json")
        self.send_header("Content-Length", str(len(data)))
        if status == 401:
            self.send_header("WWW-Authenticate", 'Basic realm="MoMo SMS API"')
        self.end_headers()
        self.wfile.write(data)

    # ── Helpers ───────────────────────────────────────────────────────────────
    def _require_auth(self):
        """Return True if authenticated, else send 401 and return False."""
        if _check_credentials(self.headers.get("Authorization", "")):
            return True
        self._write_error(401, "Authentication required")
        return False

    def _get_body(self):
        """Read and JSON-decode the request body. Returns None on failure."""
        length = int(self.headers.get("Content-Length", 0))
        if not length:
            return None
        try:
            return json.loads(self.rfile.read(length).decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            return None

    def _parse_url(self):
        """
        Split self.path into (segments, query_dict).
        e.g. /transactions/42?limit=5  →  (["transactions","42"], {"limit":["5"]})
        """
        parsed   = urlparse(self.path)
        segments = [s for s in parsed.path.split("/") if s]
        query    = parse_qs(parsed.query)
        return segments, query

    def _resolve_id(self, raw):
        """
        Convert a path segment to an int record ID.
        Returns (id, None) on success or (None, error_message) on failure.
        """
        try:
            return int(raw), None
        except (ValueError, TypeError):
            return None, f"Invalid ID '{raw}' — must be an integer"

    # ── CORS preflight ────────────────────────────────────────────────────────
    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin",  "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
        self.end_headers()
