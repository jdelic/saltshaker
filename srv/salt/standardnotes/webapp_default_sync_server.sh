#!/bin/sh
set -eu

target_html="/usr/share/nginx/html/index.html"
default_sync_server="${DEFAULT_SYNC_SERVER:-https://api.standardnotes.com}"

if [ -f "$target_html" ]; then
  # Runtime replacement is required because the web image ships prebuilt static assets.
  sed -i "s|https://api.standardnotes.com|${default_sync_server}|g" "$target_html"
fi
