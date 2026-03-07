{% from "config.sls" import external_tld %}

standardnotes:
    hostname: stdnotes.{{external_tld}}
