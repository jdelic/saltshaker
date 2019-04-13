#!/bin/bash

/usr/local/bin/fly -t salt_ciadmin login -n main -c ${CONCOURSE_URL} -u sysop -p ${CONCOURSE_SYSOP_PASSWORD}

check() {
    echo "check team $1 $2" >&2
    if /usr/local/bin/fly teams -t salt_ciadmin -d --json | \
          jq '.[]|.name + "=" + .auth.owner.groups[],.name + "=" + .auth.owner.users[]' | \
          grep "$1=oauth:$2" >/dev/null 2>/dev/null; then
        echo "found"
    else
        echo "not found";
    fi
}

RETCODE=0

setteam() {
    echo "set team $1 $2" >&2
    if test "$(check $1 $2)" == "found"; then
        RETCODE=0
    else
        /usr/local/bin/fly set-team --non-interactive -t salt_ciadmin -n "$1" --oauth-group="$2"
        RETCODE=$?
    fi
}


cleanup() {
    /usr/local/bin/fly logout -t salt_ciadmin
}


trap cleanup EXIT SIGINT


if test "x$1" == "xcheck"; then
    if test "$(check $2 $3)" == "found"; then
        RETCODE=0
    else
        RETCODE=1
    fi
fi


if test "x$1" == "xset"; then
    setteam $2 $3
fi


exit ${RETCODE}
