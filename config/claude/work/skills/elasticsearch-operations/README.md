# Elasticsearch Skill for Claude Code

A markdown-based skill that teaches Claude Code how to interact with Elasticsearch clusters via REST API. No SDK, no client library, no MCP server — just `curl` and knowledge.

## What's in it

- `SKILL.md`: Auth, search, CRUD, bulk ops, index management, cluster health, ILM, ES\|QL, ingest pipelines |
- `references/query-dsl.md`: Full Query DSL — bool, match, term, range, nested, geo, wildcards, runtime fields, search_after |
- `references/aggregations.md`: Metric, bucket, and pipeline aggregations — plus SRE patterns (error rates, top-N leaderboards) |

## Configuration

Set your cluster credentials as environment variables before starting Claude Code:

```bash
export ES_URL="https://your-cluster.es.cloud.elastic.co:443"
export ES_API_KEY="your-base64-api-key"
```

Optionally, for Kibana API access:

```bash
export KIBANA_URL="https://your-cluster.kb.cloud.elastic.co:443"
```

No server to run, no dependencies to install, no Docker container to spin up.

