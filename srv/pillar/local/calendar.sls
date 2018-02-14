{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

calendar:
    hostname: calendar.{{external_tld}}
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP
    bind-port: 8990
