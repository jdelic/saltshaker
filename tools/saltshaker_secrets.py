#!/usr/bin/env python3
"""SaltShaker secrets pillar initializer."""

from __future__ import annotations

import argparse
import getpass
import os
import shlex
import shutil
import subprocess
import sys
import textwrap
import tempfile
import time
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from shutil import which
from typing import Iterable, List, Optional
import re


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SECRETS_DIR = ROOT / "srv" / "pillar" / "shared" / "secrets"
DEFAULT_CRYPTO_DIR = ROOT / "srv" / "salt" / "basics" / "crypto"
DEFAULT_CONFIG_PILLAR = ROOT / "srv" / "pillar" / "config.sls"
DEFAULT_WORK_DIR = ROOT / ".saltshaker-secrets"
DEFAULT_VAGRANTFILE = ROOT / "vagrant" / "Vagrantfile"
DEFAULT_PRESEED_KEYS_DIR = ROOT / "vagrant" / "preseed-keys"
DEFAULT_EC_CURVE = "ed25519"
DEFAULT_GPG_KEY_TYPE = "ed25519"

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
GREEN = ""
YELLOW = ""
RED = ""
BLUE = ""
CYAN = ""

COLOR_ENABLED = False
VERBOSE = False
NO_INPUT = False

SIGNING_KEY_PASSPHRASE_ENV = "SALTSHAKER_SIGNING_KEY_PASSPHRASE"
BACKUP_KEY_PASSPHRASE_ENV = "SALTSHAKER_BACKUP_KEY_PASSPHRASE"
INTERMEDIATE_CA_KEY_PASSPHRASE_ENV = "SALTSHAKER_INTERMEDIATE_CA_KEY_PASSPHRASE"
DEFAULT_CA_DAYS = 3650
GPG_KEY_TYPES = ["ed25519", "rsa"]
KEY_SOURCES = ["keyring", "keyserver", "url", "file"]


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


def set_color_enabled(enabled: bool) -> None:
    global COLOR_ENABLED
    COLOR_ENABLED = enabled
    theme = detect_terminal_theme()
    set_palette(theme)


def set_verbose(enabled: bool) -> None:
    global VERBOSE
    VERBOSE = enabled


def detect_terminal_theme() -> str:
    explicit = os.environ.get("SALTSHAKER_TERM_THEME") or os.environ.get("CODEX_TERM_THEME")
    if explicit in {"dark", "light"}:
        return explicit
    colorfgbg = os.environ.get("COLORFGBG")
    if colorfgbg:
        try:
            background = int(colorfgbg.split(";")[-1])
            return "dark" if background <= 6 or background == 8 else "light"
        except ValueError:
            pass
    return "dark"


def set_palette(theme: str) -> None:
    global GREEN, YELLOW, RED, BLUE, CYAN
    if theme == "light":
        GREEN = "\033[32m"
        YELLOW = "\033[33m"
        RED = "\033[31m"
        BLUE = "\033[34m"
        CYAN = "\033[36m"
    else:
        GREEN = "\033[92m"
        YELLOW = "\033[93m"
        RED = "\033[91m"
        BLUE = "\033[94m"
        CYAN = "\033[96m"


def prompt_label(text: str) -> str:
    return style(text, BOLD + YELLOW, enabled=COLOR_ENABLED)


def command_label(text: str) -> str:
    return style(text, BOLD + CYAN, enabled=COLOR_ENABLED)


def print_captured_output(stdout: str, stderr: str) -> None:
    if stdout:
        sys.stdout.write(stdout)
        if not stdout.endswith("\n"):
            sys.stdout.write("\n")
    if stderr:
        sys.stderr.write(stderr)
        if not stderr.endswith("\n"):
            sys.stderr.write("\n")


def run(cmd: List[str], *, cwd: Optional[Path] = None, input_text: Optional[str] = None) -> None:
    """input_text is passed on stdin. Use it for secrets: the command line is printed and visible in ps."""
    display = " ".join(shlex.quote(part) for part in cmd)
    print()
    print(command_label(f"[cmd] {display}"))
    result = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        check=False,
        text=True,
        capture_output=not VERBOSE,
        input=input_text,
    )
    if VERBOSE:
        if result.returncode != 0:
            raise subprocess.CalledProcessError(result.returncode, cmd)
        print()
        return
    if result.returncode != 0:
        print_captured_output(result.stdout, result.stderr)
        raise subprocess.CalledProcessError(
            result.returncode,
            cmd,
            output=result.stdout,
            stderr=result.stderr,
        )
    print()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def prepare_gpg_homedir(path: Path) -> None:
    # Only set up GnuPG homes this tool creates. An existing directory may be the operator's own GnuPG home,
    # and overwriting its gpg.conf would change how gpg behaves for them everywhere. Commands that need loopback
    # pinentry pass it on the command line (see gpg_base_cmd).
    if path.exists():
        return
    ensure_dir(path)
    os.chmod(path, 0o700)
    (path / "gpg.conf").write_text("pinentry-mode loopback\n", encoding="utf-8")
    (path / "gpg-agent.conf").write_text("allow-loopback-pinentry\n", encoding="utf-8")


class MissingInputError(RuntimeError):
    pass


def set_no_input(enabled: bool) -> None:
    global NO_INPUT
    NO_INPUT = enabled


def missing_input(text: str, option: Optional[str]) -> MissingInputError:
    hint = f" Pass {option}." if option else ""
    return MissingInputError(f"--no-input is set and there's no value for: {text}.{hint}")


def prompt(text: str, default: Optional[str] = None, *, option: Optional[str] = None) -> str:
    """Ask for a value. With --no-input, return the default or fail naming the option that provides the value."""
    if NO_INPUT:
        if default is not None:
            return default
        raise missing_input(text, option)
    suffix = f" [{default}]" if default else ""
    while True:
        value = input(f"{prompt_label('[input]')} {text}{suffix}: ").strip()
        if value:
            return value
        if default is not None:
            return default


def prompt_secret(text: str, *, option: Optional[str] = None) -> str:
    if NO_INPUT:
        raise missing_input(text, option)
    while True:
        value = getpass.getpass(f"{prompt_label('[input]')} {text}: ")
        if value:
            return value


def read_passphrase(passphrase_file: Optional[str], env_var: str, text: str, option: str) -> str:
    """A passphrase comes from a file, an environment variable or a hidden prompt, never from the command line."""
    if passphrase_file:
        value = Path(passphrase_file).read_text(encoding="utf-8").rstrip("\n")
        if not value:
            raise ValueError(f"{passphrase_file} is empty")
        return value
    if os.environ.get(env_var):
        return os.environ[env_var]
    return prompt_secret(text, option=f"{option} or set {env_var}")


def prompt_yes_no(text: str, default: bool = False) -> bool:
    if NO_INPUT:
        return default
    hint = "Y/n" if default else "y/N"
    while True:
        value = input(f"{prompt_label('[input]')} {text} ({hint}): ").strip().lower()
        if not value:
            return default
        if value in {"y", "yes"}:
            return True
        if value in {"n", "no"}:
            return False


def prompt_choice(text: str, choices: List[tuple[str, str]], default: Optional[str] = None, *,
                  option: Optional[str] = None) -> str:
    if NO_INPUT:
        if default is not None:
            return default
        raise missing_input(text, option)
    print()
    print(prompt_label(text))
    for index, (value, label) in enumerate(choices, start=1):
        default_suffix = " (default)" if value == default else ""
        print(f"  {index}. {label}{default_suffix}")
    while True:
        prompt_suffix = f" [{default}]" if default is not None else ""
        value = input(f"{prompt_label('[input]')} Enter choice number{prompt_suffix}: ").strip().lower()
        if not value and default is not None:
            return default
        if value.isdigit():
            choice_index = int(value) - 1
            if 0 <= choice_index < len(choices):
                return choices[choice_index][0]
        for choice_value, _choice_label in choices:
            if value == choice_value:
                return choice_value
        warn("Please enter one of the listed numbers or choice names.", enabled=COLOR_ENABLED)


def sanitize_domains(domains: str) -> List[str]:
    return [d.strip() for d in domains.split(",") if d.strip()]


def new_run_id() -> str:
    """A short ID for one init run: the Unix time in hex. It's noted at the top of every text file init writes."""
    return format(int(time.time()), "x")


def run_header(run_id: str) -> str:
    return f"# written by saltshaker_secrets init, run {run_id}\n"


def root_ca_filename(domain: str) -> str:
    compact = re.sub(r"[^A-Za-z0-9]+", "", domain).lower()
    if not compact:
        compact = "local"
    # The suffix keeps the generated CA apart from CA files tracked in the repository (e.g. maurusnet-rootca.crt,
    # which every node installs for APT repositories). The name is stable, so it also shows that init already ran.
    return f"{compact}-rootca-generated.crt"


def default_internal_domain(dev_domain: str, prod_domains: List[str]) -> str:
    base_domain = prod_domains[0] if prod_domains else dev_domain
    compact = re.sub(r"[^A-Za-z0-9]+", "", base_domain).lower()
    if not compact:
        compact = "local"
    return f"{compact}.internal"


def append_option(cmd: List[str], flag: str, value: Optional[object]) -> None:
    if value is None:
        return
    cmd.append(f"{flag}={value}")


def append_bool_option(cmd: List[str], flag: str, value: Optional[bool]) -> None:
    if value is None:
        return
    cmd.append(flag if value else f"--no-{flag.removeprefix('--')}")


def write_file(path: Path, content: str, *, force: bool) -> None:
    if path.exists() and not force:
        raise FileExistsError(f"Refusing to overwrite {path}. Use --force to replace.")
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def sls_block(var_name: str, pem: str) -> str:
    pem = pem.strip() + "\n"
    return textwrap.dedent(f"""
            {{% set {var_name} = "\n{pem}"|indent(12) %}}
        """
    )


def load_pem(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip() + "\n"


def build_ca_openssl_conf(subject: str) -> str:
    return textwrap.dedent(f"""
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
    return textwrap.dedent("""
        [ v3_intermediate_ca ]
        subjectKeyIdentifier=hash
        authorityKeyIdentifier=keyid:always,issuer
        basicConstraints = critical, CA:true, pathlen:0
        keyUsage = critical, keyCertSign, cRLSign
        """
    )


def build_leaf_ext(san: Iterable[str]) -> str:
    san_line = ", ".join(f"DNS:{name}" for name in san)
    return textwrap.dedent(f"""
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


def generate_openssl_private_key(key_path: Path, curve_or_algorithm: str) -> None:
    curve_or_algorithm = curve_or_algorithm.lower()
    if curve_or_algorithm == "ed25519":
        run(
            [
                "openssl",
                "genpkey",
                "-algorithm",
                "Ed25519",
                "-out",
                str(key_path),
            ]
        )
        return
    run(
        [
            "openssl",
            "genpkey",
            "-algorithm",
            "EC",
            "-pkeyopt",
            f"ec_paramgen_curve:{curve_or_algorithm}",
            "-out",
            str(key_path),
        ]
    )


def generate_vagrant_preseed_keypair(preseed_dir: Path, hostname: str, *, force: bool) -> tuple[Path, Path]:
    ensure_dir(preseed_dir)
    private_key = preseed_dir / f"{hostname}.pem"
    public_key = preseed_dir / f"{hostname}.pub"
    if not force and (private_key.exists() or public_key.exists()):
        raise FileExistsError(
            f"Refusing to overwrite {private_key if private_key.exists() else public_key}. Use --force to replace."
        )
    run(["openssl", "genrsa", "-out", str(private_key), "2048"])
    run(["openssl", "rsa", "-in", str(private_key), "-pubout", "-out", str(public_key)])
    return private_key, public_key


def vagrant_machine_hostnames(dev_domain: str) -> List[str]:
    return [
        f"saltmaster.{dev_domain}",
        f"test.{dev_domain}",
        f"apps.{dev_domain}",
    ]


def update_vagrantfile_testing_domain(vagrantfile: Path, dev_domain: str) -> None:
    if not vagrantfile.exists():
        raise FileNotFoundError(f"Vagrantfile not found: {vagrantfile}")
    content = vagrantfile.read_text(encoding="utf-8")
    updated, count = re.subn(
        r"^\$testing_domain = '[^']*'$",
        f"$testing_domain = '{dev_domain}'",
        content,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise RuntimeError(f"Unable to update {vagrantfile}: missing $testing_domain assignment")
    vagrantfile.write_text(updated, encoding="utf-8")


def generate_root_ca(work_dir: Path, subject: str, days: int, ec_curve: str) -> tuple[Path, Path]:
    key_path = work_dir / "root-ca.key"
    cert_path = work_dir / "root-ca.crt"
    conf_path = work_dir / "root-ca.cnf"
    write_openssl_conf(conf_path, build_ca_openssl_conf(subject))
    generate_openssl_private_key(key_path, ec_curve)
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


def generate_intermediate_ca(work_dir: Path, subject: str, days: int, ec_curve: str, root_key: Path,
                             root_cert: Path) -> tuple[Path, Path]:
    key_path = work_dir / "intermediate-ca.key"
    csr_path = work_dir / "intermediate-ca.csr"
    cert_path = work_dir / "intermediate-ca.crt"
    ext_path = work_dir / "intermediate-ca.ext"
    generate_openssl_private_key(key_path, ec_curve)
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


def generate_leaf_cert(work_dir: Path, name: str, subject: str, days: int, ec_curve: str, ca_key: Path, ca_cert: Path,
                       san: Iterable[str]) -> tuple[Path, Path]:
    key_path = work_dir / f"{name}.key"
    csr_path = work_dir / f"{name}.csr"
    cert_path = work_dir / f"{name}.crt"
    ext_path = work_dir / f"{name}.ext"
    generate_openssl_private_key(key_path, ec_curve)
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
            "-CAserial",
            str(work_dir / "intermediate-ca.srl"),
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


def prepare_existing_ca(work_dir: Path, *, root_cert: Path, intermediate_cert: Path, intermediate_key: Path,
                        passphrase_file: Optional[str], leaf_days: int) -> Path:
    """
    Check an existing root and intermediate CA and return the path of an unencrypted copy of the intermediate key
    in the work dir (where init keeps its generated CA keys, too).
    """
    for path in (root_cert, intermediate_cert, intermediate_key):
        if not path.is_file():
            raise FileNotFoundError(f"{path} doesn't exist")
    key_copy = work_dir / "intermediate-ca.key"
    ensure_dir(work_dir)
    key_copy.touch(mode=0o600)
    os.chmod(key_copy, 0o600)
    passphrase = ""
    if "ENCRYPTED" in intermediate_key.read_text(encoding="utf-8"):
        passphrase = read_passphrase(passphrase_file, INTERMEDIATE_CA_KEY_PASSPHRASE_ENV, "Intermediate CA key passphrase",
                                     "--intermediate-ca-key-passphrase-file")
    run(["openssl", "pkey", "-in", str(intermediate_key), "-passin", "fd:0", "-out", str(key_copy)],
        input_text=passphrase + "\n")

    cert_pubkey = run_capture(["openssl", "x509", "-in", str(intermediate_cert), "-noout", "-pubkey"])
    key_pubkey = run_capture(["openssl", "pkey", "-in", str(key_copy), "-pubout"])
    if cert_pubkey.strip() != key_pubkey.strip():
        raise ValueError(f"{intermediate_key} isn't the key of {intermediate_cert}")
    verify = subprocess.run(["openssl", "verify", "-CAfile", str(root_cert), str(intermediate_cert)], check=False,
                            text=True, capture_output=True)
    if verify.returncode != 0:
        raise ValueError(f"{intermediate_cert} isn't signed by {root_cert}: {verify.stderr.strip() or verify.stdout.strip()}")
    constraints = run_capture(["openssl", "x509", "-in", str(intermediate_cert), "-noout", "-ext", "basicConstraints"])
    if "CA:TRUE" not in constraints:
        raise ValueError(f"{intermediate_cert} isn't a CA certificate")
    checkend = subprocess.run(["openssl", "x509", "-in", str(intermediate_cert), "-noout", "-checkend",
                               str(leaf_days * 86400)], check=False, capture_output=True)
    if checkend.returncode != 0:
        warn(f"{intermediate_cert} expires within --leaf-days ({leaf_days} days); the certificates will stop "
             "validating when it does", enabled=COLOR_ENABLED)
    return key_copy


def ca_installed_by_shared_pillar(config_pillar: Path, root_ca_name: str) -> bool:
    """Whether shared/ssl.sls already installs this CA on every node (like maurusnet-rootca.crt)."""
    shared_ssl = config_pillar.parent / "shared" / "ssl.sls"
    return shared_ssl.exists() and f"salt://basics/crypto/{root_ca_name}" in shared_ssl.read_text(encoding="utf-8")


def build_common_sls(intermediate_cert: str) -> str:
    return (
        "# import this into other states\n"
        + sls_block("maurusnet_minionca", intermediate_cert)
        + "\n# vim: syntax=yaml\n"
    )


def build_empty_init_sls() -> str:
    return "# vim: syntax=yaml\n"


def show_backup_gpg_disclaimer(*, generated: bool, enabled: bool) -> None:
    print()
    banner("SAVE THE BACKUP GPG KEY LOCALLY", enabled=enabled)
    if generated:
        print(
            "This key is used to encrypt duplicity backups from your server (if you enable them).\n"
            "Keep it in a safe place. It will be generated in your local keyring or a separate\n"
            "GnuPG home and can then be exported to a PEM file for offline storage.\n"
        )
    else:
        print(
            "This key is used to encrypt duplicity backups from your server (if you enable them).\n"
            "Make sure you control the matching secret key and keep that secret key in a safe place,\n"
            "because you will need it to decrypt backups later.\n"
        )


def build_ssl_sls(cert_name: str, cert: str, key: str, certchain: str, key_label: str) -> str:
    return (
        f"# autogenerated by saltshaker_secrets\n\n"
        + sls_block(f"{cert_name}_certificate", cert)
        + sls_block(f"{cert_name}_key", key)
        + sls_block(f"{cert_name}_certchain", certchain)
        + textwrap.dedent(f"""
            ssl:
                {key_label}:
                    cert: | 
                        {{{{{cert_name}_certificate}}}}
                    key: | 
                        {{{{{cert_name}_key}}}}
                    certchain: | 
                        {{{{{cert_name}_certchain}}}}
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


def build_config_sls(dev_domain: str, internal_domain: str, root_ca_name: str, install_root_ca: bool = True) -> str:
    install_ca = (
        f'{{% set install_generated_ca_certs = [\n    "salt://basics/crypto/{root_ca_name}",\n] %}}'
        if install_root_ca else "{% set install_generated_ca_certs = [] %}"
    )
    return textwrap.dedent(f"""
        #
        # Centralized configuration for domain/TLD values and user definitions.
        # Update these values per environment/branch as needed.
        #

        {{% set internal_domain = "{internal_domain}" %}}
        {{% set local_domain = "local" %}}
        {{% set external_tld = "{dev_domain}" %}}
        {{% set service_rootca_cert = "/usr/share/ca-certificates/local/{root_ca_name}" %}}
        {{install_ca_placeholder}}

        config:
            domains:
                internal: {{{{ internal_domain }}}}
                local: {{{{ local_domain }}}}
                external: {{{{ external_tld }}}}

        # Users to be created on servers are defined in dev-users.sls/live-users.sls
        users: {{}}

        # vim: syntax=yaml
        """
    ).lstrip().replace("{install_ca_placeholder}", install_ca)


def build_gpg_sls(key_block: str) -> str:
    return (
        sls_block("MN_gpg_signing_key", key_block)
        + "\n"
        + textwrap.dedent("""
            gpg:
                keys:
                    package-signing: | 
                        {{ MN_gpg_signing_key }}


            # vim: syntax=yaml
            """
        )
    )


def build_installed_keys_sls(keys: List[tuple[str, str, str]]) -> str:
    parts = ["# autogenerated by saltshaker_secrets\n\n"]
    for name, public_key, _fingerprint in keys:
        var_name = re.sub(r"[^A-Za-z0-9_]+", "_", name)
        # A raw block set needs no escaping (a supplied key's Comment header may contain quotes or braces) and,
        # unlike sls_block(), doesn't add a leading newline, so the pillar holds exactly the armored key.
        parts.append(
            f"{{% set {var_name}_public_key -%}}\n{{% raw -%}}\n{public_key.strip()}\n{{%- endraw %}}\n{{%- endset %}}\n\n"
        )
    parts.append("gpg:\n")
    if keys:
        parts.append("    installed-keys:\n")
        for name, _public_key, fingerprint in keys:
            parts.append(f"        {name}:\n")
            parts.append(f"            fingerprint: {fingerprint}\n")
        parts.append("    keys:\n")
        for name, _public_key, _fingerprint in keys:
            var_name = re.sub(r"[^A-Za-z0-9_]+", "_", name)
            parts.append(f"        {name}: | \n")
            parts.append(f"            {{{{ {var_name}_public_key|indent(12) }}}}\n")
    else:
        parts.append("    installed-keys: {}\n")
        parts.append("    keys: {}\n")
    parts.append("\n\n# vim: syntax=yaml\n")
    return "".join(parts)


# no '_', so names map to distinct Jinja variable names ('-' becomes '_')
INSTALLED_KEY_NAME_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9-]*$")


def parse_installed_keys_sls(content: str) -> List[tuple[str, str, str]]:
    """
    Read back a file written by build_installed_keys_sls() as (name, public key, fingerprint) tuples, so that
    add-gpg-key can add or replace one key and keep the others.
    """
    public_keys = dict(
        re.findall(r"\{% set ([A-Za-z0-9_]+)_public_key -%\}\n\{% raw -%\}\n(.*?)\n\{%- endraw %\}\n\{%- endset %\}",
                   content, flags=re.DOTALL)
    )
    # files written by earlier versions of this tool used sls_block()
    public_keys.update(
        re.findall(r'\{% set ([A-Za-z0-9_]+)_public_key = "\n(-----BEGIN .*?)"\|indent\(12\) %\}', content,
                   flags=re.DOTALL)
    )
    fingerprints = re.findall(r"^        ([A-Za-z0-9_-]+):\n            fingerprint: ([0-9A-Fa-f]+)$", content,
                              flags=re.MULTILINE)
    keys = []
    for name, fingerprint in fingerprints:
        var_name = re.sub(r"[^A-Za-z0-9_]+", "_", name)
        if var_name not in public_keys:
            break
        keys.append((name, public_keys[var_name], fingerprint))
    # an empty file from build_installed_keys_sls() has "installed-keys: {}"; anything else without keys isn't ours
    unreadable = not keys and "    installed-keys: {}\n" not in content
    if unreadable or len(keys) != len(fingerprints) or len(keys) != len(public_keys):
        raise RuntimeError(
            "Unable to read the existing installed keys pillar. It doesn't look like it was written by this tool."
        )
    return keys


def obtain_public_key(source: str, *, work_dir: Path, key_id: Optional[str] = None, url: Optional[str] = None,
                      key_file: Optional[str] = None, gpg_home: Optional[str] = None) -> tuple[str, str]:
    """
    Fetch an existing public key from a keyserver, URL, file or local GnuPG keyring. Returns (fingerprint, armored
    public key). The key is imported into a throwaway GnuPG home first, so the operator's keyring is only read.
    """
    ensure_dir(work_dir)
    with tempfile.TemporaryDirectory(prefix="saltshaker-gpg-import-", dir=work_dir) as temp_dir:
        import_home = Path(temp_dir)
        if source == "keyserver" and key_id:
            return fetch_key_from_keyserver(homedir=import_home, key_id=key_id)
        if source == "url" and url:
            return import_public_key(homedir=import_home, key_data=download_text(url))
        if source == "file" and key_file:
            return import_public_key(homedir=import_home, key_data=Path(key_file).read_text(encoding="utf-8"))
        if source == "keyring" and key_id:
            # Don't use gpg_base_cmd() here, it would set up gpg_home as a tool-managed GnuPG home
            cmd = ["gpg", "--batch"]
            if gpg_home:
                cmd.extend(["--homedir", gpg_home])
            exported = run_capture(cmd + ["--armor", "--export", key_id])
            if "BEGIN PGP PUBLIC KEY BLOCK" not in exported:
                raise RuntimeError(f"No public key matching {key_id} found in the GnuPG keyring")
            return import_public_key(homedir=import_home, key_data=exported)
    raise ValueError(f"Missing key ID, URL or file for GPG key source {source}")


def gpg_key_exists(*, uid: str, gpg_home: Optional[str]) -> bool:
    """Whether a GnuPG home (gpg's default if None) has a key matching uid exactly. Only reads the keyring."""
    cmd = ["gpg", "--batch", "--with-colons"]
    if gpg_home:
        if not Path(gpg_home).exists():
            return False
        cmd.extend(["--homedir", gpg_home])
    result = subprocess.run(cmd + ["--list-keys", f"={uid}"], check=False, text=True, capture_output=True)
    return result.returncode == 0 and any(line.startswith("pub:") for line in result.stdout.splitlines())


def resolve_key_source(source: Optional[str], *, key_id: Optional[str], url: Optional[str], key_file: Optional[str],
                       options: dict[str, str]) -> Optional[str]:
    """
    Work out where an existing public key comes from. An explicit source wins. Otherwise --url or --file imply
    their source and a key ID means the local keyring. Returns None if nothing was given. `options` maps "source",
    "key_id", "url" and "file" to the command's option names for error messages.
    """
    given = [kind for kind, value in (("url", url), ("file", key_file)) if value]
    if len(given) > 1:
        raise ValueError(f"Use only one of {options['url']} and {options['file']}")
    if source is None:
        source = given[0] if given else ("keyring" if key_id else None)
    for kind in given:
        if kind != source:
            raise ValueError(f"{options[kind]} can't be combined with {options['source']} {source}")
    if key_id and source not in ("keyring", "keyserver"):
        raise ValueError(f"{options['key_id']} only applies to {options['source']} keyring or keyserver")
    return source


def add_gpg_key(args: argparse.Namespace) -> None:
    color_enabled = COLOR_ENABLED
    secrets_dir = Path(args.secrets_dir or DEFAULT_SECRETS_DIR)
    work_dir = Path(args.work_dir or DEFAULT_WORK_DIR)
    pillar_file = secrets_dir / "gpg-installed-keys.sls"

    if which("gpg") is None:
        raise FileNotFoundError("Required tool not found in PATH: gpg")
    if not INSTALLED_KEY_NAME_RE.match(args.name):
        raise ValueError(f"'{args.name}' is not a valid key name. Use letters, digits and '-'.")
    source = resolve_key_source(
        args.source,
        key_id=args.key_id,
        url=args.url,
        key_file=args.file,
        options={"source": "--source", "key_id": "--key-id", "url": "--url", "file": "--file"},
    )
    if source is None:
        raise ValueError("Pass --key-id, --url or --file")
    if source in ("keyring", "keyserver") and not args.key_id:
        raise ValueError(f"--source {source} needs --key-id")
    if args.gpg_home and source != "keyring":
        raise ValueError("--gpg-home only applies to --source keyring")

    banner("SaltShaker Add GPG Key", enabled=color_enabled)
    print(f"This adds a public key to the shared managed keyring pillar in {pillar_file}.\n")

    keys: List[tuple[str, str, str]] = []
    if pillar_file.exists():
        try:
            keys = parse_installed_keys_sls(pillar_file.read_text(encoding="utf-8"))
        except RuntimeError as exc:
            raise RuntimeError(f"{exc} Fix or remove {pillar_file} first.") from exc
    replacing = any(name == args.name for name, _key, _fingerprint in keys)

    fingerprint, public_key = obtain_public_key(
        source,
        work_dir=work_dir,
        key_id=args.key_id,
        url=args.url,
        key_file=args.file,
        gpg_home=args.gpg_home,
    )

    keys = [key for key in keys if key[0] != args.name] + [(args.name, public_key, fingerprint)]
    write_file(pillar_file, build_installed_keys_sls(keys), force=True)
    ok(f"{'Replaced' if replacing else 'Added'} {args.name} ({fingerprint}) in {pillar_file}", enabled=color_enabled)
    print("\nNext config checks:")
    print(
        f"- Use {fingerprint} (or its long ID {fingerprint[-16:]}) for `duplicity-backup:gpg-keys`, "
        "`vault:encrypt-vault-keys-with-gpg` and `vaultwarden:encrypt-admin-token-with-gpg-key` as needed"
    )
    print("- Apply `basics.crypto.gpg` (or a highstate) to import the key into the managed keyring on your servers")


def run_certbot(work_dir: Path, domains: List[str], email: str) -> tuple[Path, Path, Path]:
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


def build_smtp_relay_sls() -> str:
    return textwrap.dedent("""
        # Settings for an external transactional relay that the mail servers can send through. To enable it, set
        # the values below. opensmtpd/smtpd.jinja.conf renders them as `relay host <url> auth { <auth> }`, so url is
        # an OpenSMTPD relay URL and auth the contents of an inline credentials table (see smtpd.conf(5)).
        #
        # smtp:
        #     enable-transactional-relay: True
        #     transactional-relay-via:
        #         url: smtp+tls://label@relay.example.com:587
        #         auth: label = "username:password"
        smtp:
            enable-transactional-relay: False


        # vim: syntax=yaml
        """
    ).lstrip()


def write_live_ssl_placeholder(secrets_dir: Path, *, force: bool, header: str = "") -> None:
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
    write_file(secrets_dir / "live-ssl.sls", header + live_sls, force=force)


def update_acme(args: argparse.Namespace) -> None:
    color_enabled = COLOR_ENABLED
    secrets_dir = Path(args.secrets_dir or DEFAULT_SECRETS_DIR)
    work_dir = Path(args.work_dir or DEFAULT_WORK_DIR)

    if which("certbot") is None:
        raise FileNotFoundError("certbot not found in PATH; install it before running update-acme")

    banner("SaltShaker Secrets ACME Update", enabled=color_enabled)
    print("Fetch or renew the production wildcard certificate and update live-ssl.sls.\n")

    prod_domains = sanitize_domains(
        args.prod_domains if args.prod_domains is not None
        else prompt("Production domains (comma-separated)", option="--prod-domains")
    )
    if not prod_domains:
        raise ValueError("At least one production domain is required for update-acme")

    acme_email = args.acme_email or prompt("ACME email", f"admin@{prod_domains[0]}", option="--acme-email")
    info("Requesting ACME wildcard certificate...", enabled=color_enabled)
    cert_path, chain_path, key_path = run_certbot(work_dir, prod_domains, acme_email)
    live_sls = build_ssl_sls(
        "wildcard",
        load_pem(cert_path),
        load_pem(key_path),
        load_pem(chain_path),
        "maincert",
    )
    # updating is the point of this command, so it always replaces live-ssl.sls (init's placeholder or an older cert)
    write_file(secrets_dir / "live-ssl.sls", live_sls, force=True)
    ok(f"Updated {secrets_dir / 'live-ssl.sls'}", enabled=color_enabled)


def gpg_base_cmd(*, homedir: Optional[Path] = None, batch: bool = True, loopback: bool = False) -> List[str]:
    cmd = ["gpg"]
    if homedir is not None:
        prepare_gpg_homedir(homedir)
        cmd.extend(["--homedir", str(homedir)])
    if batch:
        cmd.append("--batch")
    if loopback:
        cmd.extend(["--pinentry-mode", "loopback"])
    return cmd


def run_capture(cmd: List[str], *, input_text: Optional[str] = None) -> str:
    """input_text is passed on stdin. Use it for secrets: the command line is printed and visible in ps."""
    display = " ".join(shlex.quote(part) for part in cmd)
    print()
    print(command_label(f"[cmd] {display}"))
    result = subprocess.run(cmd, check=False, text=True, capture_output=True, input=input_text)
    if VERBOSE:
        print_captured_output(result.stdout, result.stderr)
    if result.returncode != 0:
        print_captured_output(result.stdout, result.stderr)
        raise subprocess.CalledProcessError(
            result.returncode,
            cmd,
            output=result.stdout,
            stderr=result.stderr,
        )
    output = result.stdout
    print()
    return output


def first_key_fingerprint(*, homedir: Optional[Path], search: Optional[str] = None) -> str:
    cmd = gpg_base_cmd(homedir=homedir) + ["--with-colons", "--fingerprint"]
    if search:
        cmd.extend(["--list-keys", search])
    else:
        cmd.append("--list-keys")
    output = run_capture(cmd)
    for line in output.splitlines():
        if line.startswith("fpr:"):
            return line.split(":")[9]
    raise RuntimeError("Unable to determine GPG fingerprint")


def export_public_key(*, homedir: Optional[Path], identifier: str) -> str:
    return run_capture(gpg_base_cmd(homedir=homedir) + ["--armor", "--export", identifier]).strip() + "\n"


def export_secret_key(*, homedir: Optional[Path], identifier: str, passphrase: str) -> str:
    return (
        run_capture(
            gpg_base_cmd(homedir=homedir, loopback=True)
            + ["--passphrase-fd", "0", "--armor", "--export-secret-keys", identifier],
            input_text=passphrase + "\n",
        ).strip()
        + "\n"
    )


def import_public_key(*, homedir: Path, key_data: str) -> tuple[str, str]:
    prepare_gpg_homedir(homedir)
    key_file = homedir / "import.asc"
    key_file.write_text(key_data, encoding="utf-8")
    run(gpg_base_cmd(homedir=homedir) + ["--import", str(key_file)])
    fingerprint = first_key_fingerprint(homedir=homedir)
    listing = run_capture(gpg_base_cmd(homedir=homedir) + ["--with-colons", "--list-keys"])
    if sum(line.startswith("pub:") for line in listing.splitlines()) == 1 and "PRIVATE KEY" not in key_data:
        # Keep the key exactly as supplied. gpg --export drops some packets, so re-exporting would change the
        # key file Salt manages on servers that already have this key.
        return fingerprint, key_data.strip() + "\n"
    return fingerprint, export_public_key(homedir=homedir, identifier=fingerprint)


def fetch_key_from_keyserver(*, homedir: Path, key_id: str) -> tuple[str, str]:
    prepare_gpg_homedir(homedir)
    if "@" in key_id:
        print()
        info(
            f"Searching keys.openpgp.org for {key_id}. Select the desired key when prompted by GnuPG.",
            enabled=COLOR_ENABLED,
        )
        run(
            ["gpg", "--homedir", str(homedir), "--keyserver", "hkps://keys.openpgp.org", "--search-keys", key_id]
        )
        fingerprint = first_key_fingerprint(homedir=homedir)
    else:
        run(
            gpg_base_cmd(homedir=homedir)
            + ["--keyserver", "hkps://keys.openpgp.org", "--recv-keys", key_id]
        )
        fingerprint = first_key_fingerprint(homedir=homedir, search=key_id)
    return fingerprint, export_public_key(homedir=homedir, identifier=fingerprint)


def download_text(url: str) -> str:
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def gpg_algorithm_spec(key_type: str, key_length: Optional[int]) -> str:
    key_type = key_type.lower()
    if key_type == "rsa":
        return f"rsa{key_length or 4096}"
    if key_type == "ed25519":
        return "ed25519"
    raise ValueError(f"Unsupported GPG key type: {key_type}")


def generate_gpg_key(*, homedir: Optional[Path], uid: str, key_type: str, key_length: int, expire: str, passphrase: str,
                     usage: str) -> tuple[str, str, str]:
    algo = gpg_algorithm_spec(key_type, key_length)
    if key_type.lower() == "ed25519":
        primary_usage = "cert,sign"
    else:
        primary_usage = usage

    run(
        gpg_base_cmd(homedir=homedir, loopback=True)
        + ["--passphrase-fd", "0", "--quick-gen-key", uid, algo, primary_usage, expire],
        input_text=passphrase + "\n",
    )
    fingerprint = first_key_fingerprint(homedir=homedir, search=uid)
    if key_type.lower() == "ed25519" and usage == "encrypt":
        run(
            gpg_base_cmd(homedir=homedir, loopback=True)
            + ["--passphrase-fd", "0", "--quick-add-key", fingerprint, "cv25519", "encr", expire],
            input_text=passphrase + "\n",
        )
    public = export_public_key(homedir=homedir, identifier=fingerprint)
    secret = export_secret_key(homedir=homedir, identifier=fingerprint, passphrase=passphrase)
    return fingerprint, public, secret


def build_cert_specs(dev_domain: str, prod_domains: List[str], internal_domain: str) -> List[CertSpec]:
    vault_san = [
        "vault.local",
        f"vault.{internal_domain}",
        "vault.service.consul",
        f"vault.{dev_domain}",
    ]
    for domain in prod_domains:
        vault_san.append(f"vault.{domain}")

    return [
        CertSpec(
            name="smtp",
            common_name="smtp.local",
            san=["smtp.local", f"smtp.{internal_domain}", "smtp.service.consul"],
            sls_key="smtp-local",
        ),
        CertSpec(
            name="imap",
            common_name="imap.local",
            san=["imap.local", f"mail.{internal_domain}", "imap.service.consul"],
            sls_key="imap-local",
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
            san=["postgresql.local", f"postgresql.{internal_domain}", "postgresql.service.consul"],
            sls_key="postgresql",
        ),
        CertSpec(
            name="dev-wildcard",
            common_name=f"*.{dev_domain}",
            san=[f"*.{dev_domain}", dev_domain],
            sls_key="testmaincert",
        ),
    ]


def clean(args: argparse.Namespace) -> None:
    color_enabled = COLOR_ENABLED
    work_dir = Path(args.work_dir or DEFAULT_WORK_DIR)

    banner("SaltShaker Secrets Clean", enabled=color_enabled)
    print("This removes the tool working directory used for generated temporary artifacts.\n")

    if not work_dir.exists():
        warn(f"Nothing to clean. Working directory does not exist: {work_dir}", enabled=color_enabled)
        return

    info(f"Removing working directory {work_dir}...", enabled=color_enabled)
    shutil.rmtree(work_dir)
    ok(f"Removed {work_dir}", enabled=color_enabled)


def init(args: argparse.Namespace) -> None:
    color_enabled = COLOR_ENABLED
    secrets_dir = Path(args.secrets_dir or DEFAULT_SECRETS_DIR)
    crypto_dir = Path(args.crypto_dir or DEFAULT_CRYPTO_DIR)
    config_pillar = Path(args.config_pillar or DEFAULT_CONFIG_PILLAR)
    work_dir = Path(args.work_dir or DEFAULT_WORK_DIR)
    vagrantfile = Path(args.vagrantfile or DEFAULT_VAGRANTFILE)
    preseed_keys_dir = Path(args.preseed_keys_dir or DEFAULT_PRESEED_KEYS_DIR)
    ensure_dir(work_dir)
    backup_key_fingerprint: Optional[str] = None
    backup_key_reminder_mode: Optional[str] = None

    for tool in ("openssl", "gpg"):
        if which(tool) is None:
            raise FileNotFoundError(f"Required tool not found in PATH: {tool}")

    existing_ca = [args.root_ca_cert, args.intermediate_ca_cert, args.intermediate_ca_key]
    use_existing_ca = any(existing_ca)
    if use_existing_ca and not all(existing_ca):
        raise ValueError("--root-ca-cert, --intermediate-ca-cert and --intermediate-ca-key go together")
    if use_existing_ca and (args.root_days is not None or args.intermediate_days is not None):
        raise ValueError("--root-days and --intermediate-days only apply when init generates the CAs")
    if args.intermediate_ca_key_passphrase_file and not use_existing_ca:
        raise ValueError("--intermediate-ca-key-passphrase-file only applies with --intermediate-ca-key")

    # check the backup key options before doing any work
    backup_key_source = resolve_key_source(
        args.backup_key_source,
        key_id=args.backup_key_id,
        url=args.backup_key_url,
        key_file=args.backup_key_file,
        options={
            "source": "--backup-key-source",
            "key_id": "--backup-key-id",
            "url": "--backup-key-url",
            "file": "--backup-key-file",
        },
    )

    if backup_key_source is not None and backup_key_source != "generate":
        generate_only = [
            option for option, value in (
                ("--backup-key-uid", args.backup_key_uid),
                ("--backup-key-type", args.backup_key_type),
                ("--backup-key-length", args.backup_key_length),
                ("--backup-key-expire", args.backup_key_expire),
                ("--backup-key-passphrase-file", args.backup_key_passphrase_file),
                ("--backup-key-export-secret", args.backup_key_export_secret),
            ) if value
        ]
        if generate_only:
            raise ValueError(f"{', '.join(generate_only)} only apply to --backup-key-source generate")
    if args.backup_key_gpg_home and backup_key_source in ("keyserver", "url", "file"):
        raise ValueError("--backup-key-gpg-home only applies to --backup-key-source generate or keyring")

    banner("SaltShaker Secrets Init", enabled=color_enabled)
    print(
        "Provide a development domain (used for local VMs and /etc/hosts) and\n"
        "a production domain (used for internet-facing services). You'll also\n"
        "configure the internal service domain and CA metadata used when\n"
        "issuing certs.\n"
    )

    dev_domain = args.dev_domain or prompt("Development domain (for wildcard)", option="--dev-domain")
    # an explicit empty --prod-domains= means "none", as in the rerun command printed at the end
    prod_domains = sanitize_domains(
        args.prod_domains if args.prod_domains is not None
        else prompt("Production domains (comma-separated)", "", option="--prod-domains")
    )
    internal_domain = args.internal_domain or prompt(
        "Internal service domain",
        default_internal_domain(dev_domain, prod_domains),
        option="--internal-domain",
    )

    if not prod_domains:
        warn("No production domains supplied; live-ssl.sls will be stubbed.", enabled=color_enabled)

    base_domain = prod_domains[0] if prod_domains else dev_domain
    root_ca_name = Path(args.root_ca_cert).name if use_existing_ca else root_ca_filename(base_domain)
    for marker in ([] if use_existing_ca else [crypto_dir / root_ca_name]) + [secrets_dir / "common.sls"]:
        if marker.exists() and not args.force:
            raise FileExistsError(
                f"{marker} exists, so the secrets are already initialized. Use --force to generate new ones and "
                "replace them."
            )
    if use_existing_ca:
        # check the CA before asking anything else
        int_cert = Path(args.intermediate_ca_cert)
        int_key = prepare_existing_ca(
            work_dir, root_cert=Path(args.root_ca_cert), intermediate_cert=int_cert,
            intermediate_key=Path(args.intermediate_ca_key), passphrase_file=args.intermediate_ca_key_passphrase_file,
            leaf_days=args.leaf_days,
        )
    org = args.org or prompt("Organization name", "SaltShaker", option="--org")
    country = args.country or prompt("Country code", "DE", option="--country")
    state = args.state or prompt("State/Province", "BY", option="--state")
    locality = args.locality or prompt("City/Locality", "Munich", option="--locality")
    email = args.email or prompt("CA email", f"ca@{base_domain}", option="--email")

    # Collect every answer and fetch an existing backup key before writing anything, so a missing value or an
    # unavailable key doesn't leave a half-initialized secrets directory behind.
    fetch_acme_now = args.fetch_acme
    if fetch_acme_now is None:
        fetch_acme_now = bool(prod_domains) and prompt_yes_no("Fetch production wildcard via ACME now?", default=False)
    if prod_domains and fetch_acme_now and which("certbot") is None:
        raise FileNotFoundError("certbot not found in PATH; install it or skip ACME for now")

    signing_key = args.signing_key
    if signing_key is None:
        signing_key = any(
            value is not None
            for value in (
                args.signing_key_uid,
                args.signing_key_type,
                args.signing_key_length,
                args.signing_key_expire,
                args.signing_key_passphrase_file,
            )
        ) or prompt_yes_no("Generate a package signing GPG key now?", default=True)
    signing_key_uid = args.signing_key_uid
    signing_key_type = args.signing_key_type
    signing_key_length = args.signing_key_length
    signing_key_expire = args.signing_key_expire
    signing_passphrase = ""
    if signing_key:
        signing_key_uid = signing_key_uid or prompt(
            "Signing key UID",
            f"{org} package signing key <packaging@{base_domain}>",
            option="--signing-key-uid",
        )
        signing_key_type = signing_key_type or prompt_choice(
            "Signing key type", [(t, t) for t in GPG_KEY_TYPES], DEFAULT_GPG_KEY_TYPE, option="--signing-key-type"
        )
        if signing_key_type == "rsa":
            signing_key_length = signing_key_length or int(
                prompt("Signing key length", "4096", option="--signing-key-length")
            )
        signing_key_expire = signing_key_expire or prompt("Signing key expiration", "3y", option="--signing-key-expire")
        signing_passphrase = read_passphrase(
            args.signing_key_passphrase_file,
            SIGNING_KEY_PASSPHRASE_ENV,
            "Signing key passphrase",
            "--signing-key-passphrase-file",
        )

    backup_key = args.backup_key
    if backup_key is None:
        backup_key = backup_key_source is not None or any(
            value is not None
            for value in (
                args.backup_key_uid,
                args.backup_key_type,
                args.backup_key_length,
                args.backup_key_expire,
                args.backup_key_passphrase_file,
            )
        ) or prompt_yes_no("Configure a backup GPG key now?", default=True)
    backup_key_gpg_home = args.backup_key_gpg_home
    backup_key_id = args.backup_key_id
    backup_key_url = args.backup_key_url
    backup_key_file = args.backup_key_file
    backup_key_uid = args.backup_key_uid
    backup_key_type = args.backup_key_type
    backup_key_length = args.backup_key_length
    backup_key_expire = args.backup_key_expire
    backup_key_export_secret = args.backup_key_export_secret
    backup_passphrase = ""
    backup_public_key = ""
    if backup_key:
        backup_key_source = backup_key_source or prompt_choice(
            "Backup key source",
            [
                ("generate", "Generate a new backup key"),
                ("keyring", "Export an existing key from your GnuPG keyring"),
                ("keyserver", "Fetch an existing key from keys.openpgp.org"),
                ("url", "Download an armored public key from a URL"),
                ("file", "Read an armored public key from a local file"),
            ],
            "generate",
            option="--backup-key-source",
        )
        if backup_key_source == "generate":
            backup_key_reminder_mode = "generated"
            if backup_key_gpg_home is None:
                backup_key_gpg_home = prompt(
                    f"GnuPG home to generate the backup key in (empty for gpg's default, {Path.home() / '.gnupg'})",
                    "",
                    option="--backup-key-gpg-home",
                ) or None
            backup_key_uid = backup_key_uid or prompt(
                "Backup key UID",
                f"{org} backup key <admin@{base_domain}>",
                option="--backup-key-uid",
            )
            backup_key_type = backup_key_type or prompt_choice(
                "Backup key type", [(t, t) for t in GPG_KEY_TYPES], DEFAULT_GPG_KEY_TYPE, option="--backup-key-type"
            )
            if backup_key_type == "rsa":
                backup_key_length = backup_key_length or int(
                    prompt("Backup key length", "4096", option="--backup-key-length")
                )
            backup_key_expire = backup_key_expire or prompt("Backup key expiration", "3y", option="--backup-key-expire")
            backup_passphrase = read_passphrase(
                args.backup_key_passphrase_file,
                BACKUP_KEY_PASSPHRASE_ENV,
                "Backup key passphrase",
                "--backup-key-passphrase-file",
            )
            # None: ask (or the default with --no-input), "": --no-backup-key-export-secret, else: the path
            if backup_key_export_secret is None:
                default_export = str(Path.home() / ".gnupg" / "saltshaker_admin_secretkey.pem")
                if prompt_yes_no("Export the backup secret key to a separate file?", default=True):
                    backup_key_export_secret = prompt(
                        "Backup secret key export path", default_export, option="--backup-key-export-secret"
                    )
                else:
                    backup_key_export_secret = ""
            if gpg_key_exists(uid=backup_key_uid, gpg_home=backup_key_gpg_home):
                raise FileExistsError(
                    f"{backup_key_gpg_home or 'Your GnuPG keyring'} already has a key for {backup_key_uid}. Use it "
                    f"with --backup-key-source keyring --backup-key-id '{backup_key_uid}', or pick another "
                    "--backup-key-uid."
                )
            if backup_key_export_secret and Path(backup_key_export_secret).exists() and not args.force:
                raise FileExistsError(f"Refusing to overwrite {backup_key_export_secret}. Use --force to replace.")
        else:
            backup_key_reminder_mode = "supplied"
            if backup_key_source in ("keyring", "keyserver"):
                backup_key_id = backup_key_id or prompt(
                    "Key ID, fingerprint or email of the key in your GnuPG keyring" if backup_key_source == "keyring"
                    else "Key ID, fingerprint or email to fetch from keys.openpgp.org",
                    option="--backup-key-id",
                )
            elif backup_key_source == "url":
                backup_key_url = backup_key_url or prompt("URL for armored public key", option="--backup-key-url")
            else:
                backup_key_file = backup_key_file or prompt("Path to armored public key", option="--backup-key-file")

            backup_key_fingerprint, backup_public_key = obtain_public_key(
                backup_key_source,
                work_dir=work_dir,
                key_id=backup_key_id,
                url=backup_key_url,
                key_file=backup_key_file,
                gpg_home=backup_key_gpg_home if backup_key_source == "keyring" else None,
            )

    if use_existing_ca:
        root_cert = Path(args.root_ca_cert)
    else:
        int_subject = f"/C={country}/ST={state}/L={locality}/O={org}/CN={org} Intermediate CA/emailAddress={email}"
        info("Generating root and intermediate CA...", enabled=color_enabled)
        root_key, root_cert = generate_root_ca(
            work_dir,
            subject=f"C = {country}\nST = {state}\nL = {locality}\nO = {org}\nCN = {org} Root CA\nemailAddress = {email}",
            days=args.root_days or DEFAULT_CA_DAYS,
            ec_curve=args.ec_curve,
        )
        int_key, int_cert = generate_intermediate_ca(
            work_dir,
            subject=int_subject,
            days=args.intermediate_days or DEFAULT_CA_DAYS,
            ec_curve=args.ec_curve,
            root_key=root_key,
            root_cert=root_cert,
        )

    specs = build_cert_specs(dev_domain, prod_domains, internal_domain)
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
    run_id = new_run_id()
    header = run_header(run_id)
    # an existing root CA that already is in the crypto dir (like maurusnet-rootca.crt) is used where it is
    if not (crypto_dir / root_ca_name).exists() or not (crypto_dir / root_ca_name).samefile(root_cert):
        write_file(crypto_dir / root_ca_name, load_pem(root_cert), force=args.force)

    info("Rendering pillar files...", enabled=color_enabled)
    write_file(secrets_dir / "init.sls", header + build_empty_init_sls(), force=args.force)
    common_sls = build_common_sls(load_pem(int_cert))
    write_file(secrets_dir / "common.sls", header + common_sls, force=args.force)

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
        write_file(secrets_dir / sls_name, header + sls, force=args.force)

    info("Generating Vagrant preseed keys...", enabled=color_enabled)
    for hostname in vagrant_machine_hostnames(dev_domain):
        generate_vagrant_preseed_keypair(preseed_keys_dir, hostname, force=args.force)

    info("Updating Vagrantfile testing domain...", enabled=color_enabled)
    update_vagrantfile_testing_domain(vagrantfile, dev_domain)

    acme_created = False
    if prod_domains and fetch_acme_now:
        update_acme(argparse.Namespace(
            acme_email=args.acme_email or email,
            prod_domains=",".join(prod_domains),
            secrets_dir=str(secrets_dir),
            work_dir=str(work_dir),
        ))
        acme_created = True
    else:
        write_live_ssl_placeholder(secrets_dir, force=args.force, header=header)
    write_file(secrets_dir / "smtp-relay.sls", header + build_smtp_relay_sls(), force=args.force)

    if signing_key:
        # A fresh GnuPG home each run: the key only lives on in the pillar, and gpg won't create a second key with
        # the same UID in a home that already has one (e.g. rerunning with --force).
        with tempfile.TemporaryDirectory(prefix="gnupg-package-signing-", dir=work_dir) as signing_home:
            _signing_fingerprint, public_key, secret_key = generate_gpg_key(
                homedir=Path(signing_home),
                uid=signing_key_uid,
                key_type=signing_key_type,
                key_length=signing_key_length or 0,
                expire=signing_key_expire,
                passphrase=signing_passphrase,
                usage="sign",
            )
        gpg_sls = build_gpg_sls(public_key.strip() + "\n" + secret_key.strip() + "\n")
        write_file(secrets_dir / "gpg-package-signing.sls", header + gpg_sls, force=args.force)

    installed_keys: List[tuple[str, str, str]] = []
    if backup_key:
        if backup_key_source == "generate":
            backup_key_fingerprint, backup_public_key, backup_secret_key = generate_gpg_key(
                homedir=Path(backup_key_gpg_home) if backup_key_gpg_home else None,
                uid=backup_key_uid,
                key_type=backup_key_type,
                key_length=backup_key_length or 0,
                expire=backup_key_expire,
                passphrase=backup_passphrase,
                usage="encrypt",
            )
            if backup_key_export_secret:
                write_file(Path(backup_key_export_secret), backup_secret_key, force=args.force)
        installed_keys.append(("saltshaker-backup-admin", backup_public_key, backup_key_fingerprint))

    installed_keys_sls = build_installed_keys_sls(installed_keys)
    write_file(secrets_dir / "gpg-installed-keys.sls", header + installed_keys_sls, force=args.force)

    info("Rendering global config pillar...", enabled=color_enabled)
    config_sls = build_config_sls(
        dev_domain, internal_domain, root_ca_name,
        install_root_ca=not ca_installed_by_shared_pillar(config_pillar, root_ca_name),
    )
    write_file(config_pillar, header + config_sls, force=True)

    ok(f"Secrets initialization complete (run {run_id}, root CA {crypto_dir / root_ca_name}).", enabled=color_enabled)
    print("\nNext config checks:")
    print(f"- Verify global domain settings in `{config_pillar}`")
    print(f"- Verify external_tld in `srv/pillar/local/wellknown.sls` is {dev_domain}")
    print(f"- `vagrant/Vagrantfile` has been updated for {dev_domain} and is ready for use")
    if prod_domains:
        print(f"- Verify external_tld in `srv/pillar/hetzner/wellknown.sls` (env/hcloud) matches {prod_domains[0]}")
        if acme_created:
            print("- Use `python3 tools/saltshaker_secrets.py update-acme ...` later to renew the production wildcard certificate")
        else:
            print("- Run `python3 tools/saltshaker_secrets.py update-acme ...` to create or renew `shared/secrets/live-ssl.sls`")
    print("- Review SSH public keys in `srv/pillar/shared/ssh.sls` and update as needed")
    if backup_key_fingerprint:
        print(
            f"- Use {backup_key_fingerprint[-16:]} for `duplicity-backup:gpg-keys` and `vault:encrypt-vault-keys-with-gpg` as needed"
        )

    rerun = [
        "python3",
        "tools/saltshaker_secrets.py",
        "init",
        "--no-input",
        f"--dev-domain={dev_domain}",
        f"--prod-domains={','.join(prod_domains)}",
        f"--internal-domain={internal_domain}",
        f"--org={org}",
        f"--country={country}",
        f"--state={state}",
        f"--locality={locality}",
        f"--email={email}",
        f"--ec-curve={args.ec_curve}",
    ]
    append_option(rerun, "--secrets-dir", args.secrets_dir)
    append_option(rerun, "--crypto-dir", args.crypto_dir)
    append_option(rerun, "--config-pillar", args.config_pillar)
    append_option(rerun, "--work-dir", args.work_dir)
    append_option(rerun, "--vagrantfile", args.vagrantfile)
    append_option(rerun, "--preseed-keys-dir", args.preseed_keys_dir)
    append_option(rerun, "--root-days", args.root_days)
    append_option(rerun, "--intermediate-days", args.intermediate_days)
    append_option(rerun, "--root-ca-cert", args.root_ca_cert)
    append_option(rerun, "--intermediate-ca-cert", args.intermediate_ca_cert)
    append_option(rerun, "--intermediate-ca-key", args.intermediate_ca_key)
    append_option(rerun, "--intermediate-ca-key-passphrase-file", args.intermediate_ca_key_passphrase_file)
    append_option(rerun, "--leaf-days", args.leaf_days)
    append_bool_option(rerun, "--fetch-acme", fetch_acme_now)
    append_option(rerun, "--acme-email", (args.acme_email or email) if fetch_acme_now else None)
    passphrase_envs = []
    append_bool_option(rerun, "--signing-key", signing_key)
    if signing_key:
        append_option(rerun, "--signing-key-uid", signing_key_uid)
        append_option(rerun, "--signing-key-type", signing_key_type)
        append_option(rerun, "--signing-key-length", signing_key_length if signing_key_type == "rsa" else None)
        append_option(rerun, "--signing-key-expire", signing_key_expire)
        append_option(rerun, "--signing-key-passphrase-file", args.signing_key_passphrase_file)
        if not args.signing_key_passphrase_file:
            passphrase_envs.append((SIGNING_KEY_PASSPHRASE_ENV, "--signing-key-passphrase-file"))
    append_bool_option(rerun, "--backup-key", backup_key)
    if backup_key:
        append_option(rerun, "--backup-key-source", backup_key_source)
        append_option(rerun, "--backup-key-gpg-home", backup_key_gpg_home)
        append_option(rerun, "--backup-key-id", backup_key_id)
        append_option(rerun, "--backup-key-url", backup_key_url)
        append_option(rerun, "--backup-key-file", backup_key_file)
        if backup_key_source == "generate":
            append_option(rerun, "--backup-key-uid", backup_key_uid)
            append_option(rerun, "--backup-key-type", backup_key_type)
            append_option(rerun, "--backup-key-length", backup_key_length if backup_key_type == "rsa" else None)
            append_option(rerun, "--backup-key-expire", backup_key_expire)
            append_option(rerun, "--backup-key-passphrase-file", args.backup_key_passphrase_file)
            if not args.backup_key_passphrase_file:
                passphrase_envs.append((BACKUP_KEY_PASSPHRASE_ENV, "--backup-key-passphrase-file"))
            if backup_key_export_secret:
                append_option(rerun, "--backup-key-export-secret", backup_key_export_secret)
            else:
                rerun.append("--no-backup-key-export-secret")
    if args.force:
        rerun.append("--force")
    print("\nRepeat without prompts:")
    print("  " + " ".join(shlex.quote(part) for part in rerun))
    for env_var, option in passphrase_envs:
        print(f"  (set {env_var} or add {option})")
    if backup_key_reminder_mode is not None:
        show_backup_gpg_disclaimer(
            generated=backup_key_reminder_mode == "generated",
            enabled=color_enabled,
        )


def build_parser() -> argparse.ArgumentParser:
    # options every subcommand takes, after the subcommand name
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--verbose", action="store_true", help="Show the output of the commands this tool runs")
    common.add_argument("--color", action=argparse.BooleanOptionalAction, default=None,
                        help="Colored output (Default: when stdout is a terminal)")
    common.add_argument("--no-input", action="store_true",
                        help="Never prompt. Use the default where there is one and fail on other missing values")
    common.add_argument("--work-dir", help=f"Directory for temporary artifacts (Default: {DEFAULT_WORK_DIR})")
    secrets = argparse.ArgumentParser(add_help=False)
    secrets.add_argument("--secrets-dir", help=f"Secrets pillar directory (Default: {DEFAULT_SECRETS_DIR})")

    parser = argparse.ArgumentParser(description="SaltShaker secrets pillar initializer")
    sub = parser.add_subparsers(dest="command", required=True)

    init_parser = sub.add_parser("init", parents=[common, secrets], help="Initialize secrets pillars")
    init_parser.add_argument("--force", action="store_true", help="Overwrite existing output files")
    init_parser.add_argument("--dev-domain")
    init_parser.add_argument("--prod-domains", help="Comma-separated. An empty value means none")
    init_parser.add_argument("--internal-domain")
    init_parser.add_argument("--crypto-dir")
    init_parser.add_argument("--config-pillar")
    init_parser.add_argument("--vagrantfile")
    init_parser.add_argument("--preseed-keys-dir")
    init_parser.add_argument("--org")
    init_parser.add_argument("--country")
    init_parser.add_argument("--state")
    init_parser.add_argument("--locality")
    init_parser.add_argument("--email")
    init_parser.add_argument("--root-days", type=int, help=f"Validity of a generated root CA (Default: {DEFAULT_CA_DAYS})")
    init_parser.add_argument("--intermediate-days", type=int,
                             help=f"Validity of a generated intermediate CA (Default: {DEFAULT_CA_DAYS})")
    init_parser.add_argument("--leaf-days", type=int, default=825,
                             help="Validity of the service and dev wildcard certificates (Default: %(default)s)")
    init_parser.add_argument("--ec-curve", default=DEFAULT_EC_CURVE)
    init_parser.add_argument("--fetch-acme", action=argparse.BooleanOptionalAction, default=None)
    init_parser.add_argument("--acme-email")

    existing_ca = init_parser.add_argument_group(
        "existing CA",
        "Issue the certificates from an existing CA instead of generating a root and intermediate CA. A root CA "
        "certificate that's already in the crypto dir (like maurusnet-rootca.crt) is used where it is.",
    )
    existing_ca.add_argument("--root-ca-cert", metavar="PATH")
    existing_ca.add_argument("--intermediate-ca-cert", metavar="PATH")
    existing_ca.add_argument("--intermediate-ca-key", metavar="PATH")
    existing_ca.add_argument("--intermediate-ca-key-passphrase-file", metavar="PATH",
                             help=f"For an encrypted key. Alternatively set {INTERMEDIATE_CA_KEY_PASSPHRASE_ENV}")

    signing = init_parser.add_argument_group("package signing key")
    signing.add_argument("--signing-key", action=argparse.BooleanOptionalAction, default=None,
                         help="Generate a package signing key")
    signing.add_argument("--signing-key-uid")
    signing.add_argument("--signing-key-type", choices=GPG_KEY_TYPES)
    signing.add_argument("--signing-key-length", type=int, help="Only for --signing-key-type rsa (Default: 4096)")
    signing.add_argument("--signing-key-expire", help="(Default: 3y)")
    signing.add_argument("--signing-key-passphrase-file", metavar="PATH",
                         help=f"Read the passphrase from this file. Alternatively set {SIGNING_KEY_PASSPHRASE_ENV}")

    backup = init_parser.add_argument_group(
        "backup key",
        "The key Vault, duplicity and vaultwarden can encrypt to. Generate one, or use an existing key with "
        "--backup-key-source (inferred from --backup-key-id, --backup-key-url or --backup-key-file).",
    )
    backup.add_argument("--backup-key", action=argparse.BooleanOptionalAction, default=None,
                        help="Configure a backup key")
    backup.add_argument("--backup-key-source", choices=["generate"] + KEY_SOURCES)
    backup.add_argument("--backup-key-id", help="Key ID, fingerprint or email for the keyring and keyserver sources")
    backup.add_argument("--backup-key-url")
    backup.add_argument("--backup-key-file")
    backup.add_argument("--backup-key-gpg-home", metavar="PATH",
                        help="GnuPG home to generate the key in or export it from (Default: gpg's default)")
    backup.add_argument("--backup-key-uid")
    backup.add_argument("--backup-key-type", choices=GPG_KEY_TYPES)
    backup.add_argument("--backup-key-length", type=int, help="Only for --backup-key-type rsa (Default: 4096)")
    backup.add_argument("--backup-key-expire", help="(Default: 3y)")
    backup.add_argument("--backup-key-passphrase-file", metavar="PATH",
                        help=f"Read the passphrase from this file. Alternatively set {BACKUP_KEY_PASSPHRASE_ENV}")
    backup.add_argument("--backup-key-export-secret", metavar="PATH",
                        help="Write the generated secret key to this file")
    backup.add_argument("--no-backup-key-export-secret", dest="backup_key_export_secret", action="store_const",
                        const="", help="Don't write the generated secret key to a file")
    init_parser.set_defaults(func=init)

    acme_parser = sub.add_parser("update-acme", parents=[common, secrets],
                                 help="Fetch or renew the production wildcard ACME certificate (replaces live-ssl.sls)")
    acme_parser.add_argument("--prod-domains", help="Comma-separated")
    acme_parser.add_argument("--acme-email")
    acme_parser.set_defaults(func=update_acme)

    add_key_parser = sub.add_parser(
        "add-gpg-key",
        parents=[common, secrets],
        help="Add a public key to the shared managed keyring pillar (shared/secrets/gpg-installed-keys.sls)",
        description="Add an existing public key to gpg-installed-keys.sls in the secrets pillar, creating the file "
                    "if needed and keeping the other keys in it. A key with the same --name is replaced. Salt "
                    "imports these keys into the shared managed keyring, where Vault, duplicity and vaultwarden "
                    "can encrypt to them.",
    )
    add_key_parser.add_argument("--source", choices=KEY_SOURCES,
                                help="Where to get the key (Default: inferred, --key-id means keyring)")
    add_key_parser.add_argument("--key-id", help="Key ID, fingerprint or email for the keyring and keyserver sources")
    add_key_parser.add_argument("--url", help="Download an armored public key")
    add_key_parser.add_argument("--file", help="Read an armored public key from a file")
    add_key_parser.add_argument("--gpg-home", metavar="PATH",
                                help="GnuPG home to export from with --source keyring (Default: gpg's default)")
    add_key_parser.add_argument("--name", default="saltshaker-backup-admin",
                                help="Name of the key in the gpg:keys pillar (Default: %(default)s)")
    add_key_parser.set_defaults(func=add_gpg_key)

    clean_parser = sub.add_parser("clean", parents=[common], help="Remove generated working artifacts")
    clean_parser.set_defaults(func=clean)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    set_color_enabled(bool(args.color) if args.color is not None else sys.stdout.isatty())
    set_verbose(bool(args.verbose))
    set_no_input(bool(args.no_input))
    try:
        args.func(args)
    except EOFError:
        err("Input ended while waiting for an answer. Pass the missing options, and use --no-input to have "
            "missing values reported instead of prompted for.", enabled=sys.stdout.isatty())
        return 2
    except FileExistsError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except FileNotFoundError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except RuntimeError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except ValueError as exc:
        err(str(exc), enabled=sys.stdout.isatty())
        return 2
    except subprocess.CalledProcessError as exc:
        err(f"Command failed: {exc}", enabled=sys.stdout.isatty())
        return exc.returncode or 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
