#!/bin/sh

# This script lists all environment variables in "name : value" format.
# It uses awk to ensure variables containing multiple '=' signs are handled correctly.

env | awk -F= '{
    if (index($0, "=")) {
        name = $1;
        value = substr($0, index($0, "=") + 1);
        print name " : " value;
    }
}'
