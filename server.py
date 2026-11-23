#!/usr/bin/env python3
"""MISO static host v0.1"""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
import os
PORT = 8765
def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)) or ".")
    print("MISO http://127.0.0.1:%d/" % PORT)
    ThreadingHTTPServer(("127.0.0.1", PORT), SimpleHTTPRequestHandler).serve_forever()
if __name__ == "__main__":
    main()
