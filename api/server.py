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
