#!/bin/sh
set -e

# Jalankan nginx di foreground
exec nginx -g 'daemon off;'