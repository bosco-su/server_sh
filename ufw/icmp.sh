#!/bin/bash

# on | off default
action="$1"

# default
flag_debug="$2"

rules_file=/etc/ufw/before.rules

_exit() {
    echo "----------------------------------------"
    exit $1
}

backup() {
    local -r backup_file=${rules_file}.bak
    [[ -f $backup_file ]] || {
        cp $rules_file $backup_file
        echo "backup:" $backup_file
    }
}

icmp_status() {
    local -r rules_first=$(grep -m 1 -w "icmp-type" $rules_file)

    if [[ $rules_first == \#* ]]; then
        echo "off"
    else
        echo "on"
    fi
}

set_icmp() {
    local -r action=$1
    local -r match="$2"
    local -r status=$(icmp_status)
    echo "rules_file:" $rules_file

    [[ -n "$flag_debug" ]] && {
        echo "$action:" "debug"
        sed $match $rules_file | grep -w "icmp-type"
        return 0
    }

    [[ $action == $status ]] && {
        echo "current icmp status(${status}) == $action"
        echo "skipping..."
        return 0
    }

    sed -i $match $rules_file
    ufw reload
    echo "$action:" "ok"
}

main() {
    [[ -n "$action" ]] || {
        echo "no action"
        _exit 0
    }
    backup

    case "$action" in
    "on" | "off")
        local match='/^#.*icmp-type/s/^#//g'
        [[ $action == "off" ]] && {
            match='s/^[^#].*icmp-type*/#&/g'
        }

        set_icmp $action $match
        ;;

    *)
        printf 'unknown action: %s\n' "$action"
        _exit 1
        ;;
    esac

    _exit 0
}

main
