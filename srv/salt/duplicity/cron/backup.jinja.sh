#!/usr/bin/env bash

{% for envvar, value in envvars %}
export {{envvar}}="{{value}}"
{% endfor %}

if [ ! -e /etc/duplicity.d ]; then
    echo "configuration folder /etc/duplicity.d is missing"
    exit 1;
fi

if [ $# -ne 1 ]; then
    echo "usage: duplicity-backup.sh [crontype]"
    echo "where [crontype] is the name of a subfolder of /etc/duplicity.d"
    exit 1;
fi

if [ ! -e "/etc/duplicity.d/$1" ]; then
    echo "folder does not exist /etc/duplicity.d/$1"
    exit 1;
fi

if [ ! -x /usr/bin/duplicity ]; then
    echo "/usr/bin/duplicity does not exist or is not executable"
    exit 1;
fi

for PRESCRIPT in /etc/duplicity.d/$1/prescripts/*; do
    if [ -x $PRESCRIPT ]; then
        echo "executing prescript:$PRESCRIPT"
        $PRESCRIPT
    else
        echo "$PRESCRIPT is not a file or not executable"
        continue
    fi
done

for LINK in /etc/duplicity.d/$1/folderlinks/*; do
    FOLDER=""
    if [ -h $LINK ]; then
        FOLDER="$(readlink $LINK)"
    else
        echo "$LINK is not a symlink. /etc/duplicity.d/$1/folderlinks/ should only contain symlinks"
        continue
    fi

    echo "Running duplicity {{additional_options|replace('"', '\"')}}" \
         "--encrypt-key={{gpg_key_id|replace('"', '\"')}} " \
         "--gpg-options='{{gpg_options|replace('"', '\"')}}' $FOLDER {{backup_target_url}}"

    /usr/bin/duplicity {{additional_options}} --encrypt-key={{gpg_key_id}} \
        --gpg-options='{{gpg_options}}' $FOLDER {{backup_target_url}}
done

for POSTSCRIPT in /etc/duplicity.d/$1/postscripts/*; do
    if [ -x $POSTSCRIPT ]; then
        echo "executing postscript:$POSTSCRIPT"
        $POSTSCRIPT
    else
        echo "$POSTSCRIPT is not a file or not executable"
        continue
    fi
done
