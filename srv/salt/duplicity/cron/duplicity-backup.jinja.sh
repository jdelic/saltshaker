#!/usr/bin/env bash

{% if accumulator is defined and 'duplicity-cron-pre-script' in accumulator %}
    {% for script in accumulator['duplicity-cron-pre-script'] %}
{{script}}
    {% endfor %}
{% endif %}

{% for folder in backup_folders %}
/usr/bin/duplicity {{additional_options}} --encrypt-key={{gpg_key_id}} --gpg-options='{{gpg_options}}' {{folder}} \
    {{backup_target_url}}
{% endfor %}

{% if accumulator is defined and 'duplicity-cron-folders' in accumulator %}
    {% for folder in accumulator['duplicity-cron-folders'] %}
/usr/bin/duplicity {{additional_options}} --encrypt-key={{gpg_key_id}} --gpg-options='{{gpg_options}}' {{folder}} \
        {{backup_target_url}}
    {% endfor %}
{% endif %}

{% if accumulator is defined and 'duplicity-cron-post-script' in accumulator %}
    {% for script in accumulator['duplicity-cron-post-script'] %}
{{script}}
    {% endfor %}
{% endif %}
