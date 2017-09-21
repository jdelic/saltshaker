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
    echo ""
    echo "This script will execute all executable files in"
    echo "/etc/duplicity.d/[ct]/prescripts without recursing into subfolders. It will then"
    echo "backup folders symlinked from /etc/duplicity.d/[ct]/folderlinks taking care to"
    echo "check if prescripts or postscripts contains a folder of the same name as the"
    echo "symlink. If they do t\is script will execute these pre and postscripts before"
    echo "and after backing up the symlink's target folder."
    echo "After completing all backup jobs, this script will execute all executable"
    echo "files in /etc/duplicity.d/[ct]/postscripts without recursing into subfolders."
    echo "This allows you to execute scripts before and after all of the backups by just"
    echo "dropping them into /etc/duplicity.d/[ct]/prescripts and "
    echo "/etc/duplicity.d/[ct]/postscripts and also execute them before and after each"
    echo "individual backup job by putting them into subfolders of prescripts/postscripts"
    echo "that share the symlinks name in /etc/duplicity.d/folderlinks."
    echo ""
    echo "Valid detected [crontype] values are:"
    for DIR in /etc/duplicity.d/*; do
        if [ -d $DIR ]; then
            echo "    $DIR"
        fi
    done
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
        continue
    fi
done

for LINK in /etc/duplicity.d/$1/folderlinks/*; do
    FOLDER=""
    BL="$(basename $LINK)"
    if [ -h $LINK ]; then
        FOLDER="$(readlink $LINK)"
    else
        echo "$LINK is not a symlink. /etc/duplicity.d/$1/folderlinks/ should only contain symlinks"
        continue
    fi

    if [ -d "/etc/duplicity.d/$1/prescripts/$BL" ]; then
        for PRESCRIPT in /etc/duplicity.d/$1/prescripts/$BL/*; do
            if [ -x $PRESCRIPT ]; then
                echo "executing prescript:$BL:$(basename $PRESCRIPT)"
                $PRESCRIPT
            else
                echo "warning: $PRESCRIPT\n    is not executable. Subfolders of /etc/duplicity.d/[ct]/prescripts should"
                echo "    only contain script files."
            fi
        done
    fi

    echo "Running duplicity {{additional_options|replace('"', '\"')}}" \
         "--encrypt-key={{gpg_key_id|replace('"', '\"')}} " \
         "--gpg-options='{{gpg_options|replace('"', '\"')}}' $FOLDER {{backup_target_url}}"

    /usr/bin/duplicity {{additional_options}} --encrypt-key={{gpg_key_id}} \
        --gpg-options='{{gpg_options}}' $FOLDER {{backup_target_url}}

    if [ -d "/etc/duplicity.d/$1/postscripts/$BL" ]; then
        for POSTSCRIPT in /etc/duplicity.d/$1/postscripts/$BL/* ]; do
            if [ -x $POSTSCRIPT ]; then
                echo "executing postscript:$BL:$(basename $POSTSCRIPT)"
                $POSTSCRIPT
            else
                echo "warning: $POSTSCRIPT\n    is not executable. Subfolders of /etc/duplicity.d/[ct]/postscripts"
                echo "    should only contain script files."
            fi
        done
    fi
done

for POSTSCRIPT in /etc/duplicity.d/$1/postscripts/*; do
    if [ -x $POSTSCRIPT ]; then
        echo "executing postscript:$POSTSCRIPT"
        $POSTSCRIPT
    else
        continue
    fi
done
