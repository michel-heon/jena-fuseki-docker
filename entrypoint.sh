#!/bin/bash
set -e

# Default to in-memory dataset if no arguments are provided
if [ "$#" -eq 0 ]; then
    exec $FUSEKI_HOME/fuseki-server --mem /ds
else
    exec $FUSEKI_HOME/fuseki-server "$@"
fi
