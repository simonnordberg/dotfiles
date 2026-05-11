#!/bin/bash
result=""
while true; do
    if [ -n "$result" ]; then
        input=$(echo "$result" | fuzzel -d --prompt="= ")
    else
        input=$(fuzzel -d --prompt="calc: ")
    fi
    [ -z "$input" ] && break
    result=$(qalc -t "$input")
done
[ -n "$result" ] && echo "$result" | wl-copy
