#!/usr/bin/env python3
"""Dev-only static server for previewing a resource's NUI in a browser.

FiveM NUI pages are plain HTML/CSS/JS rendered by the in-game CEF browser. To
iterate on them without launching the whole game, this serves a resource's
``html/`` directory over HTTP with caching disabled so edits show up on reload.

This is a development helper only; it is not shipped as part of any FiveM
resource.

Most NUI panels stay hidden until the game posts an ``open`` message. Pass
``--open`` (optionally with ``--open-payload '<json>'``) to have the server
inject a tiny bootstrap script that posts that message on load, so the panel
renders in its opened state during preview. Resource files are never modified.

Usage:
    tools/serve_nui.py [HTML_DIR] [--port PORT] [--open] [--open-payload JSON]

If HTML_DIR is omitted, the repository is scanned for resource ``html``
directories (any ``<resource>/html`` next to an ``fxmanifest.lua``). If exactly
one exists it is served; otherwise the available choices are printed.
"""
import argparse
import http.server
import json
import os
import socketserver
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def discover_html_dirs(root):
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in (".git", "node_modules")]
        if "fxmanifest.lua" in filenames:
            html_dir = os.path.join(dirpath, "html")
            if os.path.isdir(html_dir):
                found.append(html_dir)
    return sorted(found)


def resolve_root(explicit):
    if explicit:
        root = os.path.abspath(explicit)
        if not os.path.isdir(root):
            sys.exit(f"error: {root} is not a directory")
        return root

    candidates = discover_html_dirs(REPO_ROOT)
    if not candidates:
        sys.exit(
            "error: no resource html/ directory found. Pass one explicitly, "
            "e.g. tools/serve_nui.py path/to/resource/html"
        )
    if len(candidates) == 1:
        return candidates[0]

    print("Multiple NUI directories found; pass one explicitly:")
    for c in candidates:
        print(f"  {os.path.relpath(c, REPO_ROOT)}")
    sys.exit(1)


def build_handler(root, open_payload):
    bootstrap = b""
    if open_payload is not None:
        payload_js = json.dumps(open_payload)
        bootstrap = (
            "\n<script>/* dev preview: posts the NUI open message */\n"
            "window.addEventListener('load', function () {\n"
            "  setTimeout(function () { window.postMessage(" + payload_js + ", '*'); }, 50);\n"
            "});\n</script>\n"
        ).encode("utf-8")

    class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=root, **kwargs)

        def _no_cache_headers(self):
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")

        def end_headers(self):
            self._no_cache_headers()
            super().end_headers()

        def do_GET(self):
            if bootstrap:
                fs_path = self.translate_path(self.path)
                if os.path.isdir(fs_path):
                    fs_path = os.path.join(fs_path, "index.html")
                if fs_path.endswith(".html") and os.path.isfile(fs_path):
                    with open(fs_path, "rb") as fh:
                        body = fh.read()
                    if b"</body>" in body:
                        body = body.replace(b"</body>", bootstrap + b"</body>", 1)
                    else:
                        body += bootstrap
                    self.send_response(200)
                    self.send_header("Content-Type", "text/html; charset=utf-8")
                    self.send_header("Content-Length", str(len(body)))
                    self._no_cache_headers()
                    self.end_headers()
                    self.wfile.write(body)
                    return
            super().do_GET()

    return NoCacheHandler


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("html_dir", nargs="?", help="Path to a resource html/ directory")
    parser.add_argument("--port", type=int, default=8080, help="Port to serve on (default: 8080)")
    parser.add_argument("--open", action="store_true", help="Inject a script that posts an 'open' NUI message on load")
    parser.add_argument("--open-payload", help="JSON payload for the injected open message (implies --open)")
    args = parser.parse_args()

    root = resolve_root(args.html_dir)

    open_payload = None
    if args.open_payload is not None:
        open_payload = json.loads(args.open_payload)
    elif args.open:
        open_payload = {"action": "open"}

    handler = build_handler(root, open_payload)

    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", args.port), handler) as httpd:
        mode = " (auto-open preview)" if open_payload is not None else ""
        print(f"Serving {root} on http://0.0.0.0:{args.port} (no-store){mode}")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
