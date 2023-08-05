#!/bin/sh
jira issue list --plain --no-headers -a$(jira me) -s"In Progress" | head -3 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
