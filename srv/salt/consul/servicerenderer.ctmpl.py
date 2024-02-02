#!/usr/bin/env python

# This script template takes a list of dicts describing services in Consul,
# rendered directly into this script by consul-template and then
# filters them and executes a Jinja2 template to write a haproxy
# configuration to disk. It then executes a shell command provided on
# the command-line. This script is meant to be run as the "command"
# portion of a consul-template template stanza.
#
# i.e.
# $ consul-template \
#     -template 'haproxy_servicerenderer.ctmpl.py:/output/lb1.py:/output/lb1.py
#                --cmd "systemctl reload haproxy"' \
#                -o /etc/haproxy/haproxy.conf
#                test.tpl
#
# Inside the Jinja2 template you will have access to the "services" variable,
# a nested dict-like structure that can be grouped and filtered by its
# attributes and the service's tags defined in Consul.
#
# You can also add Jinja variables from the commandline using -D varname=value.
#
# HAProxy example: {{/*
# {# all services that have the "smartstack:protocol:http" tag in Consul #}
# {% set http_services = services.group_by_tagvalue("smartstack:protocol:")["http"] %}
# {# group the http subset of services by their "name" attribute, so we get
#    services with the same name in a list under their name #}
# {% for svcname, svclist in http_services.group_by("name").items() %}
#     {# now create a set of each unique hostname tag mentioned the by services
#        with each name #}
#     {% for hostname in svclist.tagvalue_set("smartstack:hostname:") %}
#         acl host_{{svcname}} hdr(host) -i {{hostname}}
#     {% endfor %}
#     use_backend backend-{{svcname}} if host_{{svcname}}
# {% endfor %}
# */}}
#
# If run as root, it can also call /sbin/iptables and create all necessary
# INPUT and OUTPUT rules for incoming connections based of the
# smartstack:protocol and smartstack:extport tags.
#
import ipaddress
import os
import re
import sys
from typing import Dict, Union, List, Optional, Set, Self, Iterator, Tuple, TextIO, Iterable

import jinja2
import argparse
import subprocess
import contextlib


t_servicedict = Dict[str, Union[str, int, List[str]]]

# The Go template is in the comments (yes, this works and therefor keeps
# IntelliJ's Python plugin from freaking out)
_services: List[t_servicedict] = [
    # {{ range services }}
    #    {{ range service .Name }}
    {
        "name": "{{.Name}}",
        "ip": "{{.Address}}",
        "port": int("{{.Port}}"),
        "tags": [  # {{ range .Tags}}
            "{{.}}",  # {{ end }}
        ]
    },
    #    {{ end }}
    # {{ end }}
]


_args = None


class SmartstackService:
    def __init__(self, servicedict: t_servicedict, port: Optional[int] = None, mode: Optional[str] = None) -> None:
        self._port = port
        self.mode = mode
        self.svc = servicedict

    @property
    def port(self) -> int:
        if self._port:
            return self._port
        else:
            return self.svc["port"]

    @port.setter
    def port(self, value) -> None:
        self._port = value

    @property
    def name(self) -> str:
        return self.svc["name"]

    @property
    def ip(self) -> str:
        return self.svc["ip"]

    @property
    def tags(self) -> List[str]:
        return self.svc["tags"]

    def tagvalue(self, tagpart: str) -> Union[str, None]:
        for tag in self.svc["tags"]:
            if tag.startswith(tagpart):
                return tag[len(tagpart):]
        return None

    def tagvalue_set(self, tagpart: str) -> Set[str]:
        res = set()
        for tag in self.svc["tags"]:
            if tag.startswith(tagpart):
                res.add(tag[len(tagpart):])
        return res


class SmartstackServiceContainer:
    def __init__(self, services: Optional[Union[Dict[str, Self], List[SmartstackService]]] = None,
                 all_services: Optional[List[SmartstackService]] = None, grouped_by: Optional[List[str]] = None,
                 group_by_type: Optional[List[str]] = None,
                 filtered_to: Optional[List[str]] = None):
        self.services = services if services is not None else all_services or []
        self.all_services = all_services
        self.grouped_by = grouped_by or []
        self.group_by_type = group_by_type or []
        self.filtered_to = filtered_to or []

    def add(self, service: SmartstackService) -> None:
        if isinstance(self.services, list):
            self.services.append(service)
        else:
            raise ValueError(".add() can't be called on SmartstackServiceContainers that contain a grouping dict (%s)" %
                             repr(self))

    def iter_services(self, all: bool = False):
        if all:
            for ss in self.all_services:
                yield ss

        if isinstance(self.services, dict):
            for sk in self.services.keys():
                if sk != "__untagged" and not all:
                    for ss in self.services[sk]:
                        yield ss
        elif isinstance(self.services, list):
            for ss in self.services:
                yield ss

    def ungroup(self) -> Self:
        return SmartstackServiceContainer(all_services=self.all_services)

    def __iter__(self) -> Iterator[SmartstackService]:
        return self.iter_services()

    def __getitem__(self, item: str) -> Union[List[SmartstackService], SmartstackService]:
        if isinstance(self.services, dict):
            if item not in self.services:
                raise KeyError("%s not in %s (%s)" % (item, type(self.services), repr(self)))
        return self.services[item]

    def __getattr__(self, item: str) -> Union[List[SmartstackService], SmartstackService]:
        if item not in self.services:
            raise KeyError("%s not in %s (%s)" % (item, type(self.services), repr(self)))
        return self.services[item]

    def __contains__(self, item: str) -> bool:
        return item in self.services

    def __repr__(self) -> str:
        return "SmartstackServiceContainer<%s services of %s known services, grouped: %s, group_by_type: %s, " \
               "filtered_to: %s>" % (len(list(self.iter_services())), len(self.all_services),
                                     ".".join(self.grouped_by) if self.grouped_by is not None else "None",
                                     ".".join(self.group_by_type) if self.group_by_type is not None else "None",
                                     ".".join(self.filtered_to if self.filtered_to is not None else "None"))

    def __add__(self, other: Self) -> Self:
        if isinstance(other.services, dict) and isinstance(self.services, dict):
            combined = dict(self.services)
            combined.update(other.services)
            return SmartstackServiceContainer(combined, all_services=self.all_services,
                                              filtered_to=["__combined"])
        elif isinstance(other.services, list) and isinstance(self.services, list):
            return SmartstackServiceContainer(self.services + other.services, all_services=self.all_services,
                                              filtered_to=["__combined"])
        else:
            raise ValueError("Trying to combine list of services with dict of services")

    def keys(self) -> List[str]:
        res = list(self.services.keys())
        if "__untagged" in res:
            res.remove("__untagged")
        return res

    def items(self) -> Iterable[Union[Tuple[int, SmartstackService],
                                      Tuple[str, SmartstackService],
                                      Tuple[str, Self]]]:
        return self.services.items()

    def count(self) -> int:
        if isinstance(self.services, dict):
            return len(self.keys())
        elif isinstance(self.services, list):
            return len(self.services)

    def group_by(self, field: str) -> Self:
        grouped = {}

        for ss in self.iter_services():
            if field in ss.svc:
                if ss.svc[field] not in grouped:
                    grouped[ss.svc[field]] = SmartstackServiceContainer([], all_services=self.all_services,
                                                                        filtered_to=self.filtered_to + [field])
                grouped[ss.svc[field]].add(ss)
            else:
                if "__untagged" not in grouped:
                    grouped["__untagged"] = SmartstackServiceContainer([], all_services=self.all_services,
                                                                       filtered_to=self.filtered_to + ["__untagged"])
                grouped["__untagged"].add(ss)
        return SmartstackServiceContainer(grouped, all_services=self.all_services,
                                          grouped_by=self.grouped_by + [field],
                                          group_by_type=self.group_by_type + ["field"])

    def group_by_tagvalue(self, tagpart: str) -> Self:
        grouped = {}

        for ss in self.iter_services():
            v = ss.tagvalue(tagpart)
            if v is None:
                if "__untagged" not in grouped:
                    grouped["__untagged"] = SmartstackServiceContainer([], all_services=self.all_services,
                                                                       filtered_to=self.filtered_to + ["__untagged"])
                grouped["__untagged"].add(ss)
            else:
                if v not in grouped:
                    grouped[v] = SmartstackServiceContainer([], all_services=self.all_services,
                                                            filtered_to=self.filtered_to + [v])
                grouped[v].add(ss)
        return SmartstackServiceContainer(grouped, all_services=self.all_services,
                                          grouped_by=self.grouped_by + [tagpart],
                                          group_by_type=self.group_by_type + ["tag"])

    def value_set(self, field: str) -> Set[Union[str, int, List[str]]]:
        res = set()
        for ss in self.iter_services():
            if field in ss.svc:
                res.add(ss.svc[field])
        return res

    def tagvalue_set(self, tagpart: str) -> Set[str]:
        res = set()
        for ss in self.iter_services():
            for tag in ss.svc["tags"]:
                if tag.startswith(tagpart):
                    res.add(tag[len(tagpart):])
        return res

    def empty(self):
        return SmartstackServiceContainer([], all_services=self.all_services, filtered_to=["__empty"])


@contextlib.contextmanager
def file_or_stdout(filename: str = None) -> TextIO:
    if filename and filename != "-":
        fh = open(filename, "w")
    else:
        fh = sys.stdout

    try:
        yield fh
    finally:
        if fh is not sys.stdout:
            fh.close()


def parse_queries(queries: List[str]) -> List[List[Dict[str, str]]]:
    result = []
    for query in queries:
        parsed_query = []
        if "," in query:
            subquery = query.split(",")
        else:
            subquery = [query]

        for part in subquery:
            if "=" in part:
                key, value = part.split("=", 1)
                if value.startswith("regex="):
                    value = re.compile(value[6:])
            else:
                print("query must be in the form key=[regex=]value. %s doesn't match that form" % part, file=sys.stderr)
                sys.exit(1)
            parsed_query.append({"key": key, "value": value})

        result.append(parsed_query)
    return result


def query_match(haystack, needle) -> bool:
    if hasattr(needle, "match"):
        if isinstance(haystack, Iterable):
            for h in haystack:
                if needle.match(h):
                    return True
            return False
    else:
        return needle in haystack


def filter_services(svcs: List[t_servicedict]) -> List[t_servicedict]:
    if _args.add_all:
        filtered = list(_services)
    else:
        filtered = []

    include_queries = parse_queries(_args.include_queries)
    exclude_queries = parse_queries(_args.exclude_queries)

    # filter includes
    if include_queries:
        for sv in svcs:
            for query in include_queries:
                match = True
                for part in query:
                    if part["key"] not in sv:
                        print("key %s not in service dictionary" % part["key"], file=sys.stderr)
                        sys.exit(1)

                    if not query_match(sv[part["key"]], part["value"]):
                        match = False

                if match:
                    filtered.append(sv)

    # filter excludes
    if exclude_queries:
        for sv in list(filtered):  # operate on a copy, otherwise .remove would change the list under our feet
            for query in exclude_queries:
                match = True
                for part in query:
                    if part["key"] not in sv:
                        print("key %s not in service dictionary" % part["key"], file=sys.stderr)
                        sys.exit(1)

                    if not query_match(sv[part["key"]], part["value"]):
                        match = False

                if match:
                    try:
                        filtered.remove(sv)
                    except ValueError:
                        pass  # Ignore if the service was in the filtered set in the first place

    return filtered


def parse_smartstack_tags(service: t_servicedict) -> SmartstackService:
    sv = SmartstackService(service)
    for tag in service["tags"]:
        if re.match("^smartstack:port:([0-9]+)$", tag):
            sv.port = int(tag.split(":")[2])

        if tag.startswith("smartstack:mode:"):
            sv.mode = tag.split(":")[2]

    return sv


def _setup_iptables(services: List[SmartstackService], ips: List[str], mode: str, debug: bool = False,
                    verbose: bool = False) -> None:
    if debug:
        print("========= IPTABLES RULES DEBUG =========")

    for ip in ips:
        if isinstance(ipaddress.ip_address(ip), ipaddress.IPv6Address):
            print("ERROR: iptables setup does not support ipv6.")
            sys.exit(1)

    if len(ips) > 1:
        print("ERROR: iptables supports only one IP. Use nftables to support more than one IP and IPv6.")
        sys.exit(1)

    ip = ips[0]

    for svc in services:
        _extports = set()
        for port in svc.tagvalue_set("smartstack:extport:"):
            try:
                _extports.add(int(port))
            except ValueError:
                print("Port number for 'smartstack:extport:' must be an integer not %s" %
                      svc.tagvalue("smartstack:extport:"), file=sys.stderr)
                continue

        _protocol = svc.tagvalue("smartstack:protocol:")
        if _protocol == "udp":
            prot = "udp"
            mode = "plain"  # udp can't be used with -m state
        elif _protocol == "http":
            prot = "tcp"
            _extports.add(80)
        elif _protocol == "https":
            prot = "tcp"
            _extports.add(443)
        else:
            prot = "tcp"

        if "https-redirect" in svc.tagvalue_set("smartstack:"):
            _extports.add(80)

        if not _extports:
            print("no external port (smartstack:extport:) for service %s, or no well-known protocol in "
                  "'smartstack:protocol:' so not creating iptables rule" % svc.name,
                  file=sys.stderr)
            continue

        for ruleport in _extports:
            input_rule = None
            output_rule = None

            if mode == "plain":
                input_rule = ["INPUT", "-p", prot, "-m", prot, "-s", "0/0", "-d", "%s/32" % ip, "--dport",
                              str(ruleport), "-j", "ACCEPT"]
                output_rule = ["OUTPUT", "-p", prot, "-m", prot, "-s", "%s/32" % ip, "-d", "0/0", "--sport",
                               str(ruleport), "-j", "ACCEPT"]
            elif mode == "conntrack":
                input_rule = ["INPUT", "-p", prot, "-m", "state", "--state", "NEW", "-m", prot, "-s", "0/0",
                              "-d", "%s/32" % ip, "--dport", str(ruleport), "-j", "ACCEPT"]
                output_rule = None

            if input_rule:
                if debug:
                    print("%s: %s" % (svc.name, " ".join(["/usr/sbin/iptables", "-A"] + input_rule)))
                else:
                    try:
                        # check if the rule exists first... iptables wille exit with 0 if it does
                        # also, suppress output (if the rule doesn't exist iptables will print "bad rule", which is
                        # pretty confusing
                        with open(os.devnull, "w") as devnull:
                            subprocess.check_call(["/usr/sbin/iptables", "-C"] + input_rule, stdout=devnull, stderr=devnull)
                    except subprocess.CalledProcessError as e:
                        if e.returncode == 1:
                            subprocess.call(["/usr/sbin/iptables", "-A"] + input_rule)
                    else:
                        if verbose:
                            print("%s: INPUT rule exists" % svc.name, file=sys.stderr)
            if output_rule:
                if debug:
                    print("%s: %s" % (svc.name, " ".join(["/usr/sbin/iptables", "-A"] + output_rule)))
                else:
                    try:
                        subprocess.check_call(["/usr/sbin/iptables", "-C"] + output_rule)
                    except subprocess.CalledProcessError as e:
                        if e.returncode == 1:
                            subprocess.call(["/usr/sbin/iptables", "-A"] + output_rule)
                    else:
                        if verbose:
                            print("%s: OUTPUT rule exists" % svc.name, file=sys.stderr)


def _check_nftables_rule(table: str, chain: str, rule: List[str | Tuple[str, ...]]) -> bool:
    try:
        nft_output = subprocess.check_output(
            ["nft", "list", "chain", table, chain], stderr=subprocess.STDOUT,
            text=True
        )
    except subprocess.CalledProcessError as exc:
        print(f"Error running nft command: {exc.output}")
        return False

    components = [f"{' '.join(part)}" for part in rule if isinstance(part, tuple)]
    nft_output_lines = nft_output.split("\n")
    for line in nft_output_lines:
        match = True
        for component in components:
            if component not in line:
                match = False
                break
        if match:
            return True
    return False


def _setup_nftables(services: List[SmartstackService], ips: List[str], mode: str, input_chainname: str,
                    output_chainname: str, debug: bool = False, verbose: bool = False) -> None:
    if debug:
        print("========= NFTABLES RULES DEBUG =========")

    for svc in services:
        _extports = set()
        for port in svc.tagvalue_set("smartstack:extport:"):
            try:
                _extports.add(int(port))
            except ValueError:
                print("Port number for 'smartstack:extport:' must be an integer not %s" %
                      svc.tagvalue("smartstack:extport:"), file=sys.stderr)
                continue

        _protocol = svc.tagvalue("smartstack:protocol:")
        if _protocol == "udp":
            prot = "udp"
            mode = "plain"  # udp can't be used with -m state
        elif _protocol == "http":
            prot = "tcp"
            _extports.add(80)
        elif _protocol == "https":
            prot = "tcp"
            _extports.add(443)
        else:
            prot = "tcp"

        if "https-redirect" in svc.tagvalue_set("smartstack:"):
            _extports.add(80)

        if not _extports:
            print("no external port (smartstack:extport:) for service %s, or no well-known protocol in "
                  "'smartstack:protocol:' so not creating iptables rule" % svc.name,
                  file=sys.stderr)
            continue

        for ip in ips:
            ipaddr = ipaddress.ip_address(ip)

            for ruleport in _extports:
                input_rule = None
                output_rule = None

                if mode == "plain":
                    # Tuples in these arrays will be used to check for the rule in nft output, but only tuples
                    input_rule = ["rule", "ip6" if isinstance(ipaddr, ipaddress.IPv6Address) else "ip",
                                  "filter", input_chainname, ("saddr", "0/0"),
                                  ("daddr", f"{ip}/128" if isinstance(ipaddr, ipaddress.IPv6Address) else f"{ip}/32"),
                                  (prot, "dport", str(ruleport)), ("accept",)]
                    output_rule = ["rule", "ip6" if isinstance(ipaddr, ipaddress.IPv6Address) else "ip",
                                   "filter", output_chainname,
                                   ("saddr", f"{ip}/128" if isinstance(ipaddr, ipaddress.IPv6Address) else f"{ip}/32"),
                                   ("daddr", "0/0"), (prot, "sport", str(ruleport)), ("accept",)]
                elif mode == "conntrack":
                    input_rule = ["rule", "ip6" if isinstance(ipaddr, ipaddress.IPv6Address) else "ip",
                                  "filter", input_chainname, ("saddr", "0/0"),
                                  ("daddr", f"{ip}/128" if isinstance(ipaddr, ipaddress.IPv6Address) else f"{ip}/32"),
                                  (prot, "dport", str(ruleport)), ("ct", "state", "new"), ("accept",)]
                    output_rule = None

                if input_rule:
                    input_cmd = [f"{' '.join(part)}" if isinstance(part, tuple) else part for part in input_rule]
                    if debug:
                        print("%s: %s" % (svc.name, " ".join(["/usr/sbin/nft", "add", "filter", input_chainname] +
                                                             input_cmd)))
                    else:
                        # check if the rule exists first...
                        if _check_nftables_rule("filter", input_chainname, input_rule):
                            subprocess.call(["/usr/sbin/nft", "add", "filter", input_chainname] + input_cmd)
                        else:
                            if verbose:
                                print("%s: INPUT rule already exists" % svc.name, file=sys.stderr)
                if output_rule:
                    output_cmd = [f"{' '.join(part)}" if isinstance(part, tuple) else part for part in output_rule]
                    if debug:
                        print("%s: %s" % (svc.name, " ".join(["/usr/sbin/nft", "add", "filter", output_chainname] +
                                                             output_cmd)))
                    else:
                        if _check_nftables_rule("filter", output_chainname, output_rule):
                            subprocess.call(["/usr/sbin/nft", "add", "filter", output_chainname] + output_cmd)
                        else:
                            if verbose:
                                print("%s: OUTPUT rule already exists" % svc.name, file=sys.stderr)


def main() -> None:
    global _args
    preparser = argparse.ArgumentParser(add_help=False)
    preparser.add_argument("--only-iptables", dest="only_iptables", default=False, action="store_true",
                           help=argparse.SUPPRESS)
    preparser.add_argument("--debug-iptables", dest="debug_iptables", default=False, action="store_true",
                           help=argparse.SUPPRESS)
    preparser.add_argument("--only-nftables", dest="only_nftables", default=False, action="store_true",
                           help=argparse.SUPPRESS)
    preparser.add_argument("--debug-nftables", dest="debug_nftables", default=False, action="store_true",
                           help=argparse.SUPPRESS)
    args, _ = preparser.parse_known_args()

    if len(_services) == 1:
        description = ("Don't invoke this directly. This script is meant to be a GO TEMPLATE that is "
                       "processed by consul-template and then invoked from consul-template.")
    else:
        description = ("This script is (re)generated automatically by consul-template. It operates on "
                       "the Consul service catalog.")

    parser = argparse.ArgumentParser(
        description=description
    )

    if not (args.only_iptables or args.only_nftables) and not (args.debug_iptables or args.debug_nftables):
        # only add required arguments if we actually need them
        parser.add_argument("template",
                            help="The Jinja2 template to render. This template is passed a set of services selected "
                                 "using the command-line parameters.")
        parser.add_argument("-c", "--command", dest="command", required=True,
                            help="The command to invoke after rendering the template. Will be executed in a shell.")

    parser.add_argument("-o", "--output", dest="output", help="The target file. Renders to stdout if not specified.")
    parser.add_argument("--add-all", dest="add_all", default=False, action="store_true",
                        help="Add all known services to the selected set. Use this if you just want to exclude "
                             "services.")
    parser.add_argument("--include", dest="include_queries", action="append", default=[],
                        help="Takes a comma-seperated list of 'key=value' pairs as argument. Valid keys are all "
                             "service catalog fields (e.g. 'name', 'ip', 'port', 'tags'). When value starts with "
                             "'regex=', it's treated like a regular expression. If all 'value's exists in 'key's (or "
                             "the regular expession matches), the service is added to the selected set. Comma-"
                             "separated values are treated as boolean AND. Pass this parameter multiple times to get "
                             "boolean OR semantics.")
    parser.add_argument("--exclude", dest="exclude_queries", action="append", default=[],
                        help="The opposite of --include-query.")
    parser.add_argument("--smartstack-localip", dest="localips", default=[], action="append",
                        help="Sets the local ip address all smartstack services should bind to. This is passed to the"
                             "template as the 'localip' variable. Can be specified multiple times (Default: 127.0.0.1)")
    parser.add_argument("--open-iptables", dest="open_iptables", default=None, choices=["conntrack", "plain"],
                        help="When this is set, this program will append iptables rules to the INPUT and OUTPUT chains "
                             "for all services it renders on the IP provided by --smartstack-localip. 'plain' will set "
                             "up plain INPUT and OUTPUT rules from anywhere to everywhere and vice versa. 'conntrack' "
                             "will only set up rules for NEW incoming connections, assuming that your default iptables "
                             "ruleset allows RELATED incoming and outgoing traffic. The iptables rules will be set up "
                             "before [command] is executed.")
    parser.add_argument("--only-iptables", dest="only_iptables", default=False, action="store_true",
                        help="Use this parameter to only set up iptables rules, and not do anything else. No templates "
                             "will be rendered and no commands executed.")
    parser.add_argument("--debug-iptables", dest="debug_iptables", default=False, action="store_true",
                        help="Like --only-iptables, but output the rules to stdout instead of executing them.")
    parser.add_argument("--open-nftables", dest="open_nftables", default=None, choices=["conntrack", "plain"],
                        help="When this is set, this program will append nftables rules to the INPUT and OUTPUT chains "
                             "for all services it renders on the IP provided by --smartstack-localip. 'plain' will set "
                             "up plain INPUT and OUTPUT rules from anywhere to everywhere and vice versa. 'conntrack' "
                             "will only set up rules for NEW incoming connections, assuming that your default iptables "
                             "ruleset allows RELATED incoming and outgoing traffic. The nftables rules will be set up "
                             "before [command] is executed.")
    parser.add_argument("--nftables-input-chain", dest="nftables_input_chain", default="input",
                        help="The name of the input filter chain to use for nftables.")
    parser.add_argument("--nftables-output-chain", dest="nftables_output_chain", default="input",
                        help="The name of the output filter chain to use for nftables.")
    parser.add_argument("--only-nftables", dest="only_nftables", default=False, action="store_true",
                        help="Use this parameter to only set up iptables rules, and not do anything else. No templates "
                             "will be rendered and no commands executed.")
    parser.add_argument("--debug-nftables", dest="debug_nftables", default=False, action="store_true",
                        help="Like --only-iptables, but output the rules to stdout instead of executing them.")
    parser.add_argument("-D", "--define", dest="defines", action="append", default=[],
                        help="Define a template variable for the rendering in the form 'varname=value'. 'varname' will "
                             "be added directly to the Jinja rendering context. Setting 'varname' multiple times will "
                             "create a list.")
    parser.add_argument("-v", "--verbose", dest="verbose", action="store_true", default=False,
                        help="Provide additional output while executing.")

    _args = parser.parse_args()

    if _args.open_iptables:
        if os.getuid() != 0:
            print("Must run as root if --open-iptables is used")
            sys.exit(1)

    if _args.open_nftables:
        if os.getuid() != 0:
            print("Must run as root if --open-nftables is used")
            sys.exit(1)

    if _args.open_iptables and _args.open_nftables:
        print("ERROR: setting up iptables and nftables at the same time makes no sense. Choose one.")
        sys.exit(1)

    for ip in _args.localip:
        try:
            ipaddress.ip_address(ip)
        except ValueError:
            print("ERROR: %s is not a valid ip address" % str(ip))
            sys.exit(1)

    if len(_args.localip) == 0:
        if _args.verbose:
            print("No local ip addres supplied. Using ipv4 localhost (127.0.0.1).")
        _args.localip.append("127.0.0.1")

    add_params = {}
    # convert defines from varname=value to a dict
    for define in _args.defines:
        if "=" not in define:
            print("ERROR: No '=' in -D,--define. Must be in the form 'varname=value'.")
            sys.exit(1)
        varname = define.split("=", 1)[0]
        value = define.split("=", 1)[1]
        if varname in add_params:
            if isinstance(add_params[varname], list):
                add_params[varname].append(value)
            else:
                add_params[varname] = [add_params[varname], value]
        else:
            add_params[define.split("=", 1)[0]] = define.split("=", 1)[1]

    filtered = filter_services(_services)
    parsed = []

    for sv in filtered:
        parsed.append(parse_smartstack_tags(sv))

    context = {
        "services": SmartstackServiceContainer(all_services=parsed),
        "localips": _args.localip,
    }

    context.update(add_params)

    if _args.verbose:
        print("Jinja Context:")
        for key, value in context.items():
            print("    %s = %s" % (key, value))

    if (_args.open_iptables and _args.only_iptables) or _args.debug_iptables:
        _setup_iptables(context["services"], context["localips"], _args.open_iptables, debug=_args.debug_iptables,
                        verbose=_args.verbose)
        sys.exit(0)

    if (_args.open_nftables and _args.only_nftables) or _args.debug_nftables:
        _setup_nftables(context["services"], context["localips"], _args.open_nftables, debug=_args.debug_nftables,
                        verbose=_args.verbose)
        sys.exit(0)

    env = jinja2.Environment(extensions=['jinja2.ext.do'])

    with open(_args.template) as inf, file_or_stdout(_args.output) as outf:
        tplstr = inf.read()
        tpl = env.from_string(tplstr)
        outf.write(tpl.render(context))

    if _args.open_iptables:
        _setup_iptables(context["services"], context["localips"], _args.open_iptables, debug=_args.debug_iptables,
                        verbose=_args.verbose)
    if _args.open_nftables:
        _setup_nftables(context["services"], context["localips"], _args.open_nftables, debug=_args.debug_nftables,
                        verbose=_args.verbose)
    if _args.command:
        if _args.verbose:
            print("Executing command: %s" % _args.command)
        subprocess.call(_args.command, shell=True)


if __name__ == "__main__":
    main()
