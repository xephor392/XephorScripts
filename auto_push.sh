#!/bin/bash
cd ~/XephorScripts
while true; do
    git add .
    git commit -m "Auto update $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
    git push 2>/dev/null
    sleep 60
done
