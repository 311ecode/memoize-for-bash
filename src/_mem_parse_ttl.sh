#!/usr/bin/env bash
_mem_parse_ttl() {
    local size_key="${1:-m}"
    
    # Normalize to lowercase
    size_key=$(echo "$size_key" | tr '[:upper:]' '[:lower:]')
    
    case "$size_key" in
        xxs) echo 60 ;;        # 1 min
        xs)  echo 900 ;;       # 15 min
        s)   echo 3600 ;;      # 1 hour
        m)   echo 86400 ;;     # 1 day
        l)   echo 604800 ;;    # 1 week
        xl)  echo 2592000 ;;   # 1 month
        xxl) echo 5184000 ;;   # 2 months
        *)   
            _mem_log "Warning: Invalid TTL '$size_key', using default (m)"
            echo 86400
            ;;
    esac
}