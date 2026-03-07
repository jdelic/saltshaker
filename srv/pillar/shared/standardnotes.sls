{% from "config.sls" import external_tld %}

standardnotes:
    hostname: notes.{{external_tld}}
