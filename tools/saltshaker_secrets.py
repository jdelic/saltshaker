#!/usr/bin/env python3
"""SaltShaker secrets pillar initializer."""

from __future__ import annotations

import argparse
import os
import shlex
import subprocess
import sys
import textwrap
from dataclasses import dataclass
from pathlib import Path
from shutil import which
from typing import Iterable, List, Optional
import re


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SECRETS_DIR = ROOT / "srv" / "pillar" / "shared" / "secrets"
DEFAULT_CRYPTO_DIR = ROOT / "srv" / "salt" / "basics" / "crypto"
DEFAULT_WORK_DIR = ROOT / ".saltshaker-secrets"
DEFAULT_EC_CURVE = "prime256v1"

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
BLUE = "\033[34m"


def style(text: str, color: str, *, enabled: bool) -> str:
    if not enabled:
        return text
    return f"{color}{text}{RESET}"


def banner(title: str, *, enabled: bool) -> None:
    bar = "=" * len(title)
    print(style(title, BOLD + BLUE, enabled=enabled))
    print(style(bar, DIM + BLUE, enabled=enabled))


def info(message: str, *, enabled: bool) -> None:
    print(style(f"[info] {message}", BLUE, enabled=enabled))


def warn(message: str, *, enabled: bool) -> None:
    print(style(f"[warn] {message}", YELLOW, enabled=enabled))


def ok(message: str, *, enabled: bool) -> None:
    print(style(f"[ok] {message}", GREEN, enabled=enabled))


def err(message: str, *, enabled: bool) -> None:
    print(style(f"[error] {message}", RED, enabled=enabled))


@dataclass
class CertSpec:
    name: str
    common_name: str
    san: List[str]
    sls_key: str


def run(cmd: List[str], *, cwd: Optional[Path] = None) -> None:
    display = " ".join(shlex.quote(part) for part in cmd)
    print(f"[cmd] {display}")
    subprocess.run(cmd, cwd=str(cwd) if cwd else None, check=True)


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def prompt(text: str, default: Optional[str] = None) -> str:
    suffix = f" [{default}]" if default else ""
    while True:
        value = input(f"{text}{suffix}: ").strip()
        if value:
            return value
        if default is not None:
            return default


def prompt_yes_no(text: str, default: bool = False) -> bool:
    hint = "Y/n" if default else "y/N"
    while True:
        value = input(f"{text} ({hint}): ").strip().lower()
        if not value:
            return default
        if value in {"y", "yes"}:
            return True
        if value in {"n", "no"}:
            return False


def sanitize_domains(domains: str) -> List[str]:
    return [d.strip() for d in domains.split(",") if d.strip()]


def root_ca_filename(domain: str) -> str:
    compact = re.sub(r"[^A-Za-z0-9]+", "", domain).lower()
    if not compact:
        compact = "local"
    return f"{compact}-rootca.crt"


def write_file(path: Path, content: str, *, force: bool) -> None:
    if path.exists() and not force:
        raise FileExistsError(f"Refusing to overwrite {path}. Use --force to replace.")
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def sls_block(var_name: str, pem: str) -> str:
    pem = pem.strip() + "\n"
    return textwrap.dedent(
        f"""\
        {{% set {var_name} = "\n{pem}"|indent(12) %}}
        """
    )


def load_pem(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip() + "\n"


def build_ca_openssl_conf(subject: str) -> str:
    return textwrap.dedent(
        f"""\
        [ req ]
        distinguished_name = dn
        x509_extensions = v3_ca
        prompt = no

        [ dn ]
        {subject}

        [ v3_ca ]
        subjectKeyIdentifier=hash
        authorityKeyIdentifier=keyid:always,issuer
        basicConstraints = critical, CA:true
        keyUsage = critical, keyCertSign, cRLSign
        """
    )


def build_intermediate_ext() -> str:
    return textwrap.dedent(
        """\
        [ v3_intermediate_ca ]
        subjectKeyIdentifier=hash
        authorityKeyIdentifier=keyid:always,issuer
        basicConstraints = critical, CA:true, pathlen:0
        keyUsage = critical, keyCertSign, cRLSign
        """
    )


def build_leaf_ext(san: Iterable[str]) -> str:
    san_line = ", ".join(f"DNS:{name}" for name in san)
    return textwrap.dedent(
        f"""\
        [ v3_req ]
        basicConstraints = CA:FALSE
        keyUsage = critical, digitalSignature, keyEncipherment
        extendedKeyUsage = serverAuth, clientAuth
        subjectAltName = {san_line}
        """
    )


def write_openssl_conf(path: Path, content: str) -> None:
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def generate_root_ca(
    work_dir: Path,
    subject: str,
    days: int,
    ec_curve: str,
) -> tuple[Path, Path]:
    key_path = work_dir / "root-ca.key"
    cert_path = work_dir / "root-ca.crt"
    conf_path = work_dir / "root-ca.cnf"
    write_openssl_conf(conf_path, build_ca_openssl_conf(subject))
    run(
        [
            "openssl",
            "genpkey",
            "-algorithm",
            "EC",
            "-pkeyopt",
            f"ec_paramgen_curve:{ec_curve}",
            "-out",
            str(key_path),
        ]
    )
    run(
        [
            "openssl",
            "req",
            "-x509",
            "-new",
            "-nodes",
            "-key",
            str(key_path),
            "-sha256",
            "-days",
            str(days),
            "-out",
            str(cert_path),
            "-config",
            str(conf_path),
            "-extensions",
            "v3_ca",
        ]
    )
    return key_path, cert_path


def generate_intermediate_ca(
    work_dir: Path,
    subject: str,
    days: int,
    ec_curve: str,
    root_key: Path,
    root_cert: Path,
) -> tuple[Path, Path]:
    key_path = work_dir / "intermediate-ca.key"
    csr_path = work_dir / "intermediate-ca.csr"
    cert_path = work_dir / "intermediate-ca.crt"
    ext_path = work_dir / "intermediate-ca.ext"
    run(
        [
            "openssl",
            "genpkey",
            "-algorithm",
            "EC",
            "-pkeyopt",
            f"ec_paramgen_curve:{ec_curve}",
            "-out",
            str(key_path),
        ]
    )
    run(
        [
            "openssl",
            "req",
            "-new",
            "-key",
            str(key_path),
            "-out",
            str(csr_path),
            "-subj",
            subject,
        ]
    )
    write_openssl_conf(ext_path, build_intermediate_ext())
    run(
        [
            "openssl",
            "x509",
            "-req",
            "-in",
            str(csr_path),
            "-CA",
            str(root_cert),
            "-CAkey",
            str(root_key),
            "-CAcreateserial",
            "-out",
            str(cert_path),
            "-days",
            str(days),
            "-sha256",
            "-extfile",
            str(ext_path),
            "-extensions",
            "v3_intermediate_ca",
        ]
    )
    return key_path, cert_path


def generate_leaf_cert(
    work_dir: Path,
    name: str,
    subject: str,
    days: int,
    ec_curve: str,
    ca_key: Path,
    ca_cert: Path,
    san: Iterable[str],
) -> tuple[Path, Path]:
    key_path = work_dir / f"{name}.key"
    csr_path = work_dir / f"{name}.csr"
    cert_path = work_dir / f"{name}.crt"
    ext_path = work_dir / f"{name}.ext"
    run(
        [
            "openssl",
            "genpkey",
            "-algorithm",
            "EC",
            "-pkeyopt",
            f"ec_paramgen_curve:{ec_curve}",
            "-out",
            str(key_path),
        ]
    )
    run(
        [
            "openssl",
            "req",
            "-new",
            "-key",
            str(key_path),
            "-out",
            str(csr_path),
            "-subj",
            subject,
        ]
    )
    write_openssl_conf(ext_path, build_leaf_ext(san))
    run(
        [
            "openssl",
            "x509",
            "-req",
            "-in",
            str(csr_path),
            "-CA",
            str(ca_cert),
            "-CAkey",
            str(ca_key),
            "-CAcreateserial",
            "-out",
            str(cert_path),
            "-days",
            str(days),
            "-sha256",
            "-extfile",
            str(ext_path),
            "-extensions",
            "v3_req",
        ]
    )
    return key_path, cert_path


def build_common_sls(intermediate_cert: str) -> str:
    return (
        "# import this into other states\n"
        + sls_block("maurusnet_minionca", intermediate_cert)
        + "\n# vim: syntax=yaml\n"
    )


def build_ssl_sls(
    cert_name: str,
    cert: str,
    key: str,
    certchain: str,
    key_label: str,
) -> str:
    return (
        f"# autogenerated by saltshaker_secrets\n\n"
        + sls_block(f"{cert_name}_certificate", cert)
        + sls_block(f"{cert_name}_key", key)
        + sls_block(f"{cert_name}_certchain", certchain)
        + textwrap.dedent(
            f"""\
            \nssl:
                {key_label}:
                    cert: | {{{{{cert_name}_certificate}}}}
                    key: | {{{{{cert_name}_key}}}}
                    certchain: | {{{{{cert_name}_certchain}}}}
                    combined: |
                        {{{{{cert_name}_certificate}}}}
                        {{{{{cert_name}_certchain}}}}
                    combined-key: |
                        {{{{{cert_name}_certificate}}}}
                        {{{{{cert_name}_certchain}}}}
                        {{{{{cert_name}_key}}}}


            # vim: syntax=yaml
            """
        )
    )


def build_gpg_sls(key_block: str) -> str:
    return (
        sls_block("MN_gpg_signing_key", key_block)
        + "\n"
        + textwrap.dedent(
            """\
            gpg:
                keys:
                    package-signing: | {{ MN_gpg_signing_key }}


            # vim: syntax=yaml
            """
        )
    )


def run_certbot(
    work_dir: Path,
    domains: List[str],
    email: str,
) -> tuple[Path, Path, Path]:
    ensure_dir(work_dir)
    certbot_dir = work_dir / "certbot"
    config_dir = certbot_dir / "config"
    work_dir_cb = certbot_dir / "work"
    logs_dir = certbot_dir / "logs"
    ensure_dir(config_dir)
    ensure_dir(work_dir_cb)
    ensure_dir(logs_dir)

    domain_args: List[str] = []
    for domain in domains:
        domain_args.extend(["-d", domain, "-d", f"*.{domain}"])

    cmd = [
        "certbot",
        "certonly",
        "--config-dir",
        str(config_dir),
        "--work-dir",
        str(work_dir_cb),
        "--logs-dir",
        str(logs_dir),
    ] + domain_args

    cmd.extend(
        [
            "--manual",
            "--preferred-challenges",
            "dns",
            "--manual-public-ip-logging-ok",
            "--agree-tos",
            "--email",
            email,
        ]
    )

    run(cmd)

    primary = domains[0]
    live_dir = config_dir / "live" / primary
    cert_path = live_dir / "cert.pem"
    chain_path = live_dir / "chain.pem"
    privkey_path = live_dir / "privkey.pem"
    if not cert_path.exists():
        raise FileNotFoundError(f"certbot did not produce {cert_path}")
    return cert_path, chain_path, privkey_path


def generate_gpg_key(work_dir: Path, uid: str, key_type: str, key_length: int, expire: str, passphrase: str) -> str:
    gnupg_home = work_dir / "gnupg"
    ensure_dir(gnupg_home)
    os.chmod(gnupg_home, 0o700)

    base_cmd = ["gpg", "--homedir", str(gnupg_home), "--batch", "--pinentry-mode", "loopback"]

    passphrase_arg = passphrase

    run(
        base_cmd
        + [
            "--passphrase",
            passphrase_arg,
            "--quick-gen-key",
            uid,
            f"{key_type}{key_length}",
            "sign",
            expire,
        ]
    )

    public = subprocess.check_output(
        base_cmd + ["--armor", "--export", uid],
        text=True,
    )
    secret = subprocess.check_output(
        base_cmd + ["--passphrase", passphrase_arg, "--armor", "--export-secret-keys", uid],
        text=True,
    )
    return public.strip() + "\n" + secret.strip() + "\n"


def build_cert_specs(dev_domain: str, prod_domains: List[str]) -> List[CertSpec]:
    vault_san = ["vault.local", "vault.internal", "vault.service.consul", f"vault.{dev_domain}"]
    for domain in prod_domains:
        vault_san.append(f"vault.{domain}")

    return [
        CertSpec(
            name="smtp",
            common_name="smtp.local",
            san=["smtp.local", "smtp.internal", "smtp.service.consul"],
            sls_key="smtp-local",
        ),
        CertSpec(
            name="vault",
            common_name="vault.local",
            san=vault_san,
            sls_key="vault",
        ),
        CertSpec(
            name="postgresql",
            common_name="postgresql.local",
            san=["postgresql.local", "postgresql.internal", "postgresql.service.consul"],
            sls_key="postgresql",
        ),
        CertSpec(
            name="dev-wildcard",
            common_name=f"*.{dev_domain}",
            san=[f"*.{dev_domain}", dev_domain],
            sls_key="testmaincert",
        ),
    ]


def init(args: argparse.Namespace) -> None:
    color_enabled = bool(args.color) if args.color is not None else sys.stdout.isatty()
    secrets_dir = Path(args.secrets_dir or DEFAULT_SECRETS_DIR)
    crypto_dir = Path(args.crypto_dir or DEFAULT_CRYPTO_DIR)
    work_dir = Path(args.work_dir or DEFAULT_WORK_DIR)
    ensure_dir(work_dir)

    for tool in ("openssl", "gpg"):
        if which(tool) is None:
            raise FileNotFoundError(f"Required tool not found in PATH: {tool}")

    banner("SaltShaker Secrets Init", enabled=color_enabled)
    print(
        "Provide a development domain (used for local VMs and /etc/hosts) and\n"
        "a production domain (used for internet-facing services). You'll also\n"
        "enter CA certificate metadata used when issuing certs.\n"
    )

    dev_domain = args.dev_domain or prompt("Development domain (for wildcard)")
    prod_domains = sanitize_domains(args.prod_domains or prompt("Production domains (comma-separated)", ""))

    if not prod_domains:
        warn("No production domains supplied; live-ssl.sls will be stubbed.", enabled=color_enabled)

    org = args.org or prompt("Organization name", "SaltShaker")
    country = args.country or prompt("Country code", "US")
    state = args.state or prompt("State/Province", "CA")
    locality = args.locality or prompt("City/Locality", "San Francisco")
    email = args.email or prompt("CA email", f"ca@{prod_domains[0] if prod_domains else dev_domain}")

    int_subject = f"/C={country}/ST={state}/L={locality}/O={org}/CN={org} Intermediate CA/emailAddress={email}"

    info("Generating root and intermediate CA...", enabled=color_enabled)
    root_key, root_cert = generate_root_ca(
        work_dir,
        subject=f"C = {country}\nST = {state}\nL = {locality}\nO = {org}\nCN = {org} Root CA\nemailAddress = {email}",
        days=args.root_days,
        ec_curve=args.ec_curve,
    )
    int_key, int_cert = generate_intermediate_ca(
        work_dir,
        subject=int_subject,
        days=args.intermediate_days,
        ec_curve=args.ec_curve,
        root_key=root_key,
        root_cert=root_cert,
    )

    specs = build_cert_specs(dev_domain, prod_domains)
    leaf_material = {}
    for spec in specs:
        info(f"Generating leaf cert {spec.name}...", enabled=color_enabled)
        key_path, cert_path = generate_leaf_cert(
            work_dir,
            spec.name,
            subject=f"/C={country}/ST={state}/L={locality}/O={org}/CN={spec.common_name}",
            days=args.leaf_days,
            ec_curve=args.ec_curve,
            ca_key=int_key,
            ca_cert=int_cert,
            san=spec.san,
        )
        leaf_material[spec.name] = (key_path, cert_path, spec)

    info("Writing CA certs...", enabled=color_enabled)
    base_domain = prod_domains[0] if prod_domains else dev_domain
    root_ca_name = root_ca_filename(base_domain)
    write_file(crypto_dir / root_ca_name, load_pem(root_cert), force=args.force)
    write_file(crypto_dir / "dev" / "dev-ca.crt", load_pem(int_cert), force=args.force)

    info("Rendering pillar files...", enabled=color_enabled)
    common_sls = build_common_sls(load_pem(int_cert))
    write_file(secrets_dir / "common.sls", common_sls, force=args.force)

    for spec_name, (key_path, cert_path, spec) in leaf_material.items():
        cert = load_pem(cert_path)
        key = load_pem(key_path)
        certchain = load_pem(int_cert)
        if spec.name == "dev-wildcard":
            sls_name = "dev-ssl.sls"
        elif spec.name == "vault":
            sls_name = "vault-ssl.sls"
        else:
            sls_name = f"{spec.name}.sls"

        sls = build_ssl_sls(spec.name.replace("-", "_"), cert, key, certchain, spec.sls_key)
        write_file(secrets_dir / sls_name, sls, force=args.force)

    if prod_domains and prompt_yes_no("Fetch production wildcard via ACME now?", default=False):
        if which("certbot") is None:
            raise FileNotFoundError("certbot not found in PATH; install it or skip ACME for now")
        acme_email = args.acme_email or prompt("ACME email", email)
        cert_path, chain_path, key_path = run_certbot(work_dir, prod_domains, acme_email)
        live_sls = build_ssl_sls(
            "wildcard",
            load_pem(cert_path),
            load_pem(key_path),
            load_pem(chain_path),
            "maincert",
        )
        write_file(secrets_dir / "live-ssl.sls", live_sls, force=args.force)
    else:
        placeholder_cert = "# TODO: replace with ACME certificate\n"
        placeholder_key = "# TODO: replace with ACME private key\n"
        placeholder_chain = "# TODO: replace with ACME chain\n"
        live_sls = build_ssl_sls(
            "wildcard",
            placeholder_cert,
            placeholder_key,
            placeholder_chain,
            "maincert",
        )
        write_file(secrets_dir / "live-ssl.sls", live_sls, force=args.force)

    if prompt_yes_no("Generate GPG signing key now?", default=True):
        gpg_uid = args.gpg_uid or prompt(
            "GPG UID",
            f"{org} package signing key <packaging@{prod_domains[0] if prod_domains else dev_domain}>",
        )
        gpg_key_type = args.gpg_key_type or prompt("GPG key type (rsa)", "rsa")
        gpg_key_length = int(args.gpg_key_length or prompt("GPG key length", "4096"))
        gpg_expire = args.gpg_expire or prompt("GPG expiration", "3y")
        passphrase = ""
        while not passphrase:
            passphrase = prompt("GPG passphrase (required)", "").strip()
        gpg_block = generate_gpg_key(work_dir, gpg_uid, gpg_key_type, gpg_key_length, gpg_expire, passphrase)
        gpg_sls = build_gpg_sls(gpg_block)
        write_file(secrets_dir / "gpg-package-signing.sls", gpg_sls, force=args.force)

    ok("Secrets initialization complete.", enabled=color_enabled)
    print("\nNext config checks:")
    print(
        f"- Add `salt://basics/crypto/{root_ca_name}` to install-ca-certs in `srv/pillar/shared/ssl.sls`"
    )
    print(f"- Verify TLDs in `srv/pillar/shared/network.sls` match {dev_domain} and your internal TLDs")
    print(f"- Verify external_tld in `srv/pillar/local/wellknown.sls` is {dev_domain}")
    if prod_domains:
        print(f"- Verify external_tld in `srv/pillar/hetzner/wellknown.sls` (env/hcloud) matches {prod_domains[0]}")
    print("- Review SSH public keys in `srv/pillar/shared/ssh.sls` and update as needed")

    rerun = [
        "python3",
        "tools/saltshaker_secrets.py",
        "init",
        f"--dev-domain={dev_domain}",
        f"--prod-domains={','.join(prod_domains)}" if prod_domains else "--prod-domains=",
        f"--org={org}",
        f"--country={country}",
        f"--state={state}",
        f"--locality={locality}",
        f"--email={email}",
        f"--ec-curve={args.ec_curve}",
    ]
    print("\nRepeat without prompts:")
    print("  " + " ".join(shlex.quote(part) for part in rerun))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="SaltShaker secrets pillar initializer")
    sub = parser.add_subparsers(dest="command", required=True)

    init_parser = sub.add_parser("init", help="Initialize secrets pillars")
    init_parser.add_argument("--dev-domain")
    init_parser.add_argument("--prod-domains")
    init_parser.add_argument("--secrets-dir")
    init_parser.add_argument("--crypto-dir")
    init_parser.add_argument("--work-dir")
    init_parser.add_argument("--force", action="store_true")
    init_parser.add_argument("--color", action=argparse.BooleanOptionalAction, default=None)
    init_parser.add_argument("--org")
    init_parser.add_argument("--country")
    init_parser.add_argument("--state")
    init_parser.add_argument("--locality")
    init_parser.add_argument("--email")
    init_parser.add_argument("--root-days", type=int, default=3650)
    init_parser.add_argument("--intermediate-days", type=int, default=3650)
    init_parser.add_argument("--leaf-days", type=int, default=825)
    init_parser.add_argument("--ec-curve", default=DEFAULT_EC_CURVE)
    init_parser.add_argument("--acme-email")
    init_parser.add_argument("--gpg-uid")
    init_parser.add_argument("--gpg-key-type")
    init_parser.add_argument("--gpg-key-length")
    init_parser.add_argument("--gpg-expire")

    init_parser.set_defaults(func=init)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except FileExistsError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except FileNotFoundError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except subprocess.CalledProcessError as exc:
        err(f"Command failed: {exc}", enabled=sys.stdout.isatty())
        return exc.returncode or 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
