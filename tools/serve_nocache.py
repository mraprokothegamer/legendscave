#!/usr/bin/env python3
"""Dev-only static server for previewing the NUI with caching disabled.

Serves ls_waterdispenser/html on :8080 with no-store headers so edits are
always picked up on reload. Not part of the FiveM resource.
"""
import http.server
import os
import socketserver

PORT = 8080
ROOT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ls_waterdispenser", "html",
)


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


if __name__ == "__main__":
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), NoCacheHandler) as httpd:
        print(f"Serving {ROOT} on :{PORT} (no-store)")
        httpd.serve_forever()
