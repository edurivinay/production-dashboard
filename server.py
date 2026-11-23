
#!/usr/bin/env python3
"""MISO Dashboard local host — shared live data for all users."""
import os, sys, json, webbrowser, threading, time, socket
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

PORT = 8765
HOST = "0.0.0.0"  # all network interfaces so other PCs can connect

def app_dir():
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

def local_ips():
    ips = []
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ips.append(s.getsockname()[0])
        s.close()
    except Exception:
        pass
    try:
        for info in socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET):
            ip = info[4][0]
            if ip not in ips and not ip.startswith("127."):
                ips.append(ip)
    except Exception:
        pass
    return ips or ["127.0.0.1"]

def find_free_port(start=8765, limit=20):
    for p in range(start, start + limit):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind((HOST, p))
                return p
            except OSError:
                continue
    return start

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path in ("/data.json", "/api/data"):
            fpath = os.path.join(os.getcwd(), "data.json")
            if os.path.isfile(fpath):
                try:
                    with open(fpath, "rb") as f:
                        body = f.read()
                    self.send_response(200)
                    self.send_header("Content-Type", "application/json; charset=utf-8")
                    self.send_header("Content-Length", str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)
                except Exception as e:
                    self.send_error(500, str(e))
            else:
                # empty placeholder so fetch does not 404 hard
                body = b'{"executive":null,"message":"No report uploaded yet. Admin: Upload Report."}'
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            return
        return SimpleHTTPRequestHandler.do_GET(self)

    def do_POST(self):
        path = self.path.split("?", 1)[0]
        if path not in ("/data.json", "/api/data", "/api/upload"):
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length", 0) or 0)
        raw = self.rfile.read(length) if length else b""
        try:
            # validate JSON
            data = json.loads(raw.decode("utf-8"))
            fpath = os.path.join(os.getcwd(), "data.json")
            with open(fpath, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            # also keep a timestamped backup
            try:
                bak = os.path.join(os.getcwd(), "data_last.json")
                with open(bak, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
            except Exception:
                pass
            msg = json.dumps({"ok": True, "saved": "data.json"}).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)
            period = ""
            try:
                period = (data.get("executive") or {}).get("period") or ""
            except Exception:
                pass
            print("[SAVE] data.json updated", period)
        except Exception as e:
            err = json.dumps({"ok": False, "error": str(e)}).encode("utf-8")
            self.send_response(400)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(err)))
            self.end_headers()
            self.wfile.write(err)

    def log_message(self, fmt, *args):
        sys.stdout.write("[%s] %s\n" % (self.log_date_time_string(), fmt % args))
        sys.stdout.flush()

def main():
    base = app_dir()
    os.chdir(base)
    port = find_free_port(PORT)
    httpd = ThreadingHTTPServer((HOST, port), Handler)
    ips = local_ips()
    print("=" * 56)
    print("  MISO Ribbon Dashboard — LIVE SHARED HOST")
    print("  This PC:     http://127.0.0.1:%d/" % port)
    for ip in ips:
        print("  Other users: http://%s:%d/" % (ip, port))
    print("  Auto Sync:   http://127.0.0.1:%d/data.json" % port)
    print("  Data file:   %s" % os.path.join(base, "data.json"))
    print("  Press Ctrl+C to stop")
    print("=" * 56)

    def open_browser():
        time.sleep(0.7)
        try:
            webbrowser.open("http://127.0.0.1:%d/" % port)
        except Exception:
            pass
    threading.Thread(target=open_browser, daemon=True).start()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        httpd.server_close()

if __name__ == "__main__":
    main()
