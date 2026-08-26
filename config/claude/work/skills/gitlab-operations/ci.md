# Pipelines / CI

## Status

```bash
glab ci status                        # current branch; -b <branch> for another
glab ci status -F json                # parseable
glab ci get -b <branch> -d           # pipeline + per-job details as JSON
glab ci list                          # recent pipelines for the project
```

For an MR's pipeline (covers detached/merged-result pipelines that branch lookup can miss):

```bash
glab api "projects/:fullpath/merge_requests/1234/pipelines" | jq '.[0] | {id, status, web_url}'
```

## Why did it fail?

```bash
glab api "projects/:fullpath/pipelines/<pipeline-id>/jobs?scope[]=failed" |
  jq '.[] | {id, name, stage, failure_reason}'
glab ci trace <job-id>                # full job log (streams live if still running)
```

Job logs can be huge — pipe `glab ci trace` to a scratchpad file and search it.

## Actions (only when asked)

```bash
glab ci retry <job-id>
glab ci run -b <branch>               # trigger a new pipeline
glab ci artifact <ref> <job-name>     # download artifacts from last pipeline
```
