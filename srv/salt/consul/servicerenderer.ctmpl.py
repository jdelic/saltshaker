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
# HAProxy example:
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
#

import re
import sys
import jinja2
import argparse
import subprocess
import contextlib


# The Go template is in the comments (yes, this works and therefor keeps
# IntelliJ's Python plugin from freaking out)
_services = [
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


class SmartstackService(object):
    def __init__(self, servicedict, protocol=None, port=None, host=None, mode=None):
        self.protocol = protocol
        self._port = port
        self.host = host
        self.mode = mode
        self.svc = servicedict

    @property
    def port(self):
        if self._port:
            return self._port
        else:
            return self.svc["port"]

    @port.setter
    def port(self, value):
        self._port = value

    @property
    def name(self):
        return self.svc["name"]

    @property
    def ip(self):
        return self.svc["ip"]

    @property
    def tags(self):
        return self.svc["tags"]

    def tagvalue(self, tagpart):
        for tag in self.svc["tags"]:
            if tag.startswith(tagpart):
                return tag[len(tagpart):]
        return None


class SmartstackServiceContainer(object):
    def __init__(self, services=None, all_services=None, grouped_by=None, group_by_type=None,
                 filtered_to=None):
        self.services = services if services is not None else all_services or []
        self.all_services = all_services
        self.grouped_by = grouped_by or []
        self.group_by_type = group_by_type or []
        self.filtered_to = filtered_to or []

    def add(self, service):
        if isinstance(self.services, list):
            self.services.append(service)
        else:
            raise ValueError(".add() can't be called on SmartstackServiceContainers that contain a grouping dict (%s)" %
                             repr(self))

    def iter_services(self, all=False):
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

    def ungroup(self):
        return SmartstackServiceContainer(all_services=self.all_services)

    def __iter__(self):
        return self.iter_services()

    def __getitem__(self, item):
        if isinstance(self.services, dict):
            if item not in self.services:
                raise KeyError("%s not in %s (%s)" % (item, type(self.services), repr(self)))
        return self.services[item]

    def __getattr__(self, item):
        if item not in self.services:
            raise KeyError("%s not in %s (%s)" % (item, type(self.services), repr(self)))
        return self.services[item]

    def __contains__(self, item):
        return item in self.services

    def __repr__(self):
        return "SmartstackServiceContainer<%s services of %s known services, grouped: %s, group_by_type: %s, " \
               "filtered_to: %s>" % (len(list(self.iter_services())), len(self.all_services),
                                    ".".join(self.grouped_by) if self.grouped_by is not None else "None",
                                    ".".join(self.group_by_type) if self.group_by_type is not None else "None",
                                    ".".join(self.filtered_to if self.filtered_to is not None else "None"))

    def keys(self):
        res = self.services.keys()
        if "__untagged" in res:
            del res["__untagged"]
        return res

    def items(self):
        return self.services.items()

    def count(self):
        if isinstance(self.services, dict):
            return len(self.keys())
        elif isinstance(self.services, list):
            return len(self.services)

    def group_by(self, field):
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

    def group_by_tagvalue(self, tagpart):
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

    def value_set(self, field):
        res = set()
        for ss in self.iter_services():
            if field in ss.svc:
                res.add(ss.svc[field])
        return res

    def tagvalue_set(self, tagpart):
        res = set()
        for ss in self.iter_services():
            for tag in ss.svc["tags"]:
                if tag.startswith(tagpart):
                    res.add(tag[len(tagpart):])
        return res


@contextlib.contextmanager
def file_or_stdout(filename=None):
    if filename and filename != "-":
        fh = open(filename, "w")
    else:
        fh = sys.stdout

    try:
        yield fh
    finally:
        if fh is not sys.stdout:
            fh.close()


def filter_services(svcs):
    filtered = []

    # filter includes
    if _args.include:
        for sv in svcs:
            for inc in _args.include:
                if inc in sv["tags"] and sv not in filtered:
                    filtered.append(sv)

    if _args.match:
        for sv in svcs:
            for regex in _args.match:
                for tag in sv["tags"]:
                    if re.match(regex, tag) and sv not in filtered:
                        filtered.append(sv)

    if not filtered and not _args.include and not _args.match:
        filtered = svcs

    if _args.exclude:
        for sv in list(filtered):  # operate on a copy, otherwise .remove would change the list under our feet
            for exc in _args.exclude:
                if exc in sv["tags"]:
                    filtered.remove(sv)

    if _args.nomatch:
        for sv in list(filtered):
            for regex in _args.nomatch:
                for tag in sv["tags"]:
                    if re.match(regex, tag):
                        filtered.remove(sv)

    return filtered


def parse_smartstack_tags(service):
    sv = SmartstackService(service)
    for tag in service["tags"]:
        if re.match("^smartstack:port:([0-9]+)$", tag):
            sv.port = int(tag.split(":")[2])

        if tag.startswith("smartstack:host:"):
            sv.host = tag.split(":")[2]

        if tag.startswith("smartstack:mode:"):
            sv.mode = tag.split(":")[2]

        if tag.startswith("smartstack:protocol:"):
            sv.protocol = tag.split(":")[2]
    return sv


def main():
    global _args
    parser = argparse.ArgumentParser(
        description="Don't invoke this directly. This script is meant to be a GO TEMPLATE that is "
                    "processed by consul-template and then invoked from consul-template."
    )
    parser.add_argument("template",
                        help="The Jinja2 template to render")
    parser.add_argument("-c", "--command", dest="command", required=True,
                        help="The command to invoke after rendering the template. Will be executed in a shell.")
    parser.add_argument("-o", "--output", dest="output", help="The target file. Renders to stdout if not specified.")
    parser.add_argument("--has", dest="include", action="append",
                        help="Only render services that have the (all of the) specified tag(s). This parameter "
                             "can be specified multiple times.")
    parser.add_argument("--match", dest="match", action="append",
                        help="Only render services that have tags which match the passed regular expressions.")
    parser.add_argument("--has-not", dest="exclude", action="append",
                        help="Only render services that do NOT have (any of the) specified tag(s). This parameter "
                             "can be specified multiple times.")
    parser.add_argument("--no-match", dest="nomatch",  action="append",
                        help="Only render services that do NOT have tags which match the passed regular "
                             "expressions.")
    parser.add_argument("--smartstack-localip", dest="localip", default="127.0.0.1",
                        help="Sets the local ip address all smartstack services should bind to. (Default: 127.0.0.1)")

    _args = parser.parse_args()

    filtered = filter_services(_services)
    parsed = []

    for sv in filtered:
        parsed.append(parse_smartstack_tags(sv))

    context = {
        "services": SmartstackServiceContainer(all_services=parsed),
        "localip": _args.localip,
    }

    env = jinja2.Environment(extensions=['jinja2.ext.do'])

    with open(_args.template) as inf, file_or_stdout(_args.output) as outf:
        tplstr = inf.read()
        tpl = env.from_string(tplstr)
        outf.write(tpl.render(context))

    if _args.command:
        subprocess.call(_args.command, shell=True)


if __name__ == "__main__":
    main()
