---
name: gitlab-operations
description: >-
  Work with GitLab merge requests and CI via the glab CLI on git.timewax.com.
  List, view, create, and update MRs, post comments (including inline diff
  comments), reply to and resolve discussions, and check pipelines. Triggers on
  "my MRs", "create an MR", "comment on MR !1234", "is CI green", "why did the
  pipeline fail".
user-invocable: true
---

# GitLab Operations

Work with GitLab using the `glab` CLI (on your PATH). The instance is self-hosted at
`git.timewax.com`.

## Command Mapping

| User Query | Route |
|------------|-------|
| "What are my open MRs?" / "MRs waiting on my review" | `list.md` |
| "Show MR !1234" / "get the diff" / "what comments are on it?" | `view.md` |
| "Create an MR" / "update the MR description" | `create.md` |
| "Comment on MR !1234" / "reply to that thread" / "resolve it" | `comment.md` |
| "Is CI green?" / "why did the pipeline fail?" | `ci.md` |

Read the matching file in this skill directory, then follow it. Only read the file(s) you need.

## Shared rules

- **Host detection.** Inside a repo whose remote is `git.timewax.com`, `glab` picks up the host
  and project automatically — no `GITLAB_HOST`, no `--repo`. Only outside such a repo, add
  `GITLAB_HOST=git.timewax.com` and `-R timewax/backend`.
- **`glab api` placeholders.** In endpoint paths, `:fullpath` and `:id` expand to the current
  repo's project — write `projects/:fullpath/merge_requests/...`, never hand-encode
  `timewax%2Fbackend` inside a repo.
- **MR numbers are iids.** The `!1234` number is the `iid` — that's what `glab mr <cmd> 1234`
  and `merge_requests/1234` in API paths take. Most `glab mr` commands also accept a branch
  name or no argument (current branch's MR).
- **Structured output.** `glab mr view/list -F json` for parseable output; `glab api` returns
  JSON by default (`--paginate` for full result sets).
- **Writes need intent.** Don't create MRs, post comments, approve, or merge unless the user
  asked for that action. Verify writes by viewing the result afterward.
- **Multi-line bodies:** write the body to a scratchpad file and use `-d "$(cat file)"` /
  `--input file` — avoids shell-quoting pain.

## Other one-liners

```bash
glab mr checkout 1234        # check out the MR branch locally
glab mr approve 1234
glab mr merge 1234           # only when explicitly asked
glab mr issues 1234          # related issues
```
