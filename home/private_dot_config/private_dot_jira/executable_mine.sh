#!/usr/bin/env sh
jira issue list --plain --no-headers -a$(jira me) -s"In Progress" 2>/dev/null| head -3 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
