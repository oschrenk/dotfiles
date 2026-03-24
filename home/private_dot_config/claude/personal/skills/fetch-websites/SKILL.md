---
name: fetch-websites
description: Use this skill when fetching website content, especially JavaScript-rendered pages (SPAs, React, Vue, dynamic content). Replaces the built-in WebFetch tool with lightpanda, a headless browser that renders JavaScript. Use when the user asks to fetch, scrape, or read a website URL, or when you need to retrieve web page content for any task.
---

# Fetch Websites with Lightpanda

Use `lightpanda` instead of the WebFetch tool to fetch website content. Lightpanda is a headless browser that fully renders JavaScript, making it ideal for SPAs and dynamic pages.

## Basic Usage

```bash
lightpanda fetch --dump markdown <URL>
```

## Dump Formats

| Format | Flag | Use Case |
|--------|------|----------|
| Markdown | `--dump markdown` | Best default — clean, readable content (Recommended) |
| HTML | `--dump html` | When you need raw HTML structure |
| Semantic tree | `--dump semantic_tree` | When you need the DOM tree |
| Semantic tree text | `--dump semantic_tree_text` | Text-only DOM tree |

## Stripping Unnecessary Content

Use `--strip_mode` to remove noise from the output:

| Mode | Removes |
|------|---------|
| `js` | Scripts and script preloads |
| `css` | Styles and stylesheets |
| `ui` | Images, pictures, video, CSS, SVG |
| `full` | All of the above (js + ui + css) |

For most use cases, strip everything:

```bash
lightpanda fetch --dump markdown --strip_mode full <URL>
```

## Wait Strategies

By default, lightpanda waits up to 5000ms for the `done` event. Adjust if needed:

- `--wait_until load` — Wait for page load event
- `--wait_until domcontentloaded` — Wait for DOM ready
- `--wait_until networkidle` — Wait until network is idle
- `--wait_until done` — Wait until fully done (default)
- `--wait_ms <ms>` — Custom timeout (default: 5000)

For heavy SPAs that need more time:

```bash
lightpanda fetch --dump markdown --wait_ms 10000 <URL>
```

## Workflow

1. Run `lightpanda fetch --dump markdown --strip_mode full <URL>` via Bash
2. The output is the rendered page content in markdown
3. Process the content as needed for the user's task

## Notes

- Lightpanda renders JavaScript, so it works with SPAs, React apps, and dynamically loaded content
- Use `--strip_mode full` by default to keep output clean and concise
- If the output is too large, consider using `--strip_mode` options or processing specific sections
- For pages behind authentication, lightpanda won't help — use specialized MCP tools instead
