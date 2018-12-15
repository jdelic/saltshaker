sync_all_the_things:
    local.saltutil.sync_all:
        - tgt: {{ data['id'] }}
        - kwarg:
            refresh: True
