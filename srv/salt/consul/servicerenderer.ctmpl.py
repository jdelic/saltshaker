#! /usr/bin/env python

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
        "port": "{{.Port}}",
        "tags": [  # {{ range .Tags}}
             "{{.}}",  # {{ end }}
        ]
    },
    #    {{ end }}
    # {{ end }}
]


_args = None


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
    for tag in service["tags"]:
        if re.match("^smartstack:port:([0-9]+)$", tag):
            service["smartstack_port"] = int(tag.split(":")[2])

        if re.match("^smartstack:host:", tag):
            service["smartstack_host"] = tag.split(":")[2]

        if re.match("^smartstack:mode:", tag):
            service["smartstack_mode"] = tag.split(":")[2]


def main():
    global _args
    parser = argparse.ArgumentParser(
        description="Don't invoke this directly. This script is meant to be a GO TEMPLATE that is "
                    "processed by consul-template and then invoked from consul-template."
    )
    parser.add_argument("template",
                        help="The Jinja2 template to render")
    parser.add_argument("--cmd", dest="command", required=True,
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

    for sv in filtered:
        parse_smartstack_tags(sv)

    context = {
        "services": filtered,
        "localip": _args.localip,
    }

    with open(_args.template) as inf, file_or_stdout(_args.output) as outf:
        tplstr = inf.read()
        tpl = jinja2.Template(tplstr)
        outf.write(tpl.render(context))

    if _args.command:
        subprocess.call(_args.command, shell=True)


if __name__ == "__main__":
    main()
