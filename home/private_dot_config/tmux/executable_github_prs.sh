#!/bin/sh
gh pr -R vandebron/Vandebron list --search "is:open is:pr review-requested:oschrenk archived:false" --json number | jq -r '.[] | .number = "#\(.number)" | .number' | head -3 | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
