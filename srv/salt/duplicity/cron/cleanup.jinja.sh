#!/usr/bin/env bash

# AUTOGENERATED VIA SALT! DO NOT EDIT!

{% for envvar, value in envvars.items() %}
    export {{envvar}}="{{value}}"
{% endfor %}

if [ $# -ne 1 ]; then
    echo "usage: duplicity-cleanup.sh run"
    echo ""
    echo "This script is a helper that runs duplicity so it removes backups older than"
    echo "a certain timeframe as configured via Salt."
    echo ""
    echo "Cronjob enabled: {{cron_enabled}}
    echo "Cleanup mode: {{cleanup_mode}}"
    echo "Cleanup parameter: {{cleanup_selector}}"
    exit 1;
fi

echo "Running duplicity {{cleanup_mode}} {{cleanup_selector}} --force {{backup_target_url}}"

/usr/bin/duplicity {{cleanup_mode}} {{cleanup_selector}} --force {{backup_target_url}}