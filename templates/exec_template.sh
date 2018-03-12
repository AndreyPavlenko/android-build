#!/bin/sh
___EXEC_DIR___="$(cd $(dirname "$0") && pwd)"
exec "$___EXEC_DIR___/#NAME#" #ARGS# "$@"
