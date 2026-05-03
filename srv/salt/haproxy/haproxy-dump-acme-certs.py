#!/usr/bin/env python3
import argparse
import glob
import os
import socket
import sys
import tempfile
from typing import List


def haproxy_command(socket_path: str, command: str) -> bytes:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(socket_path)
        sock.sendall(command.encode("utf-8") + b"\n")
        sock.shutdown(socket.SHUT_WR)
        chunks = []
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                break
            chunks.append(chunk)
    return b"".join(chunks)


def dump_certificate(socket_path: str, certificate_path: str, quiet: bool = False) -> bool:
    output = haproxy_command(socket_path, f"dump ssl cert {certificate_path}")
    if not output.startswith(b"-----BEGIN "):
        if not quiet:
            print(
                f"Skipping {certificate_path}: HAProxy did not return PEM data",
                file=sys.stderr,
            )
        return False

    cert_dir = os.path.dirname(certificate_path)
    with tempfile.NamedTemporaryFile(prefix=".dump-", dir=cert_dir, delete=False) as tmpfile:
        tmpfile.write(output)
        tmpfile_name = tmpfile.name

    os.chmod(tmpfile_name, 0o640)
    os.replace(tmpfile_name, certificate_path)
    if not quiet:
        print(f"Dumped {certificate_path}")
    return True


def certificate_paths(cert_dir: str, explicit_paths: List[str]) -> List[str]:
    if explicit_paths:
        return explicit_paths
    return sorted(glob.glob(os.path.join(cert_dir, "*.pem")))


def main() -> int:
    parser = argparse.ArgumentParser(description="Persist HAProxy ACME certificates from the admin socket.")
    parser.add_argument("--socket", default="/run/haproxy/admin-external.sock", help="HAProxy admin socket path.")
    parser.add_argument("--cert-dir", default="/etc/haproxy/acme/certs", help="Directory containing ACME cert PEMs.")
    parser.add_argument("--quiet", action="store_true", default=False, help="Only print errors.")
    parser.add_argument("--ignore-missing-socket", action="store_true", default=False,
                        help="Exit successfully when the HAProxy socket is absent.")
    parser.add_argument("certificates", nargs="*", help="Specific certificate paths to dump.")
    args = parser.parse_args()

    if not os.path.exists(args.socket):
        if not args.quiet:
            print(f"HAProxy admin socket does not exist: {args.socket}", file=sys.stderr)
        return 0 if args.ignore_missing_socket else 1

    paths = certificate_paths(args.cert_dir, args.certificates)
    if not paths:
        return 0

    ok = True
    for path in paths:
        try:
            ok = dump_certificate(args.socket, path, quiet=args.quiet) and ok
        except OSError as exc:
            ok = False
            if not args.quiet:
                print(f"Failed to dump {path}: {exc}", file=sys.stderr)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
