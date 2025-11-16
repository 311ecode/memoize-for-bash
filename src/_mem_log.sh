#!/usr/bin/env bash
_mem_log() {
    if [ -n "$DEBUG" ]; then
        echo "[memoize] $*" >&2
    fi
}
