#!/usr/bin/env node

/**
 * Execute ES|QL queries against Elasticsearch.
 *
 * Usage:
 *   ./esql.js raw "ES|QL query"                  - Execute raw ES|QL
 *   ./esql.js indices [pattern]                  - List indices
 *   ./esql.js schema <index>                     - Get index mappings
 *   ./esql.js test                               - Test connection and ES|QL availability
 */

import { Client } from "@elastic/elasticsearch";

// =============================================================================
// Elasticsearch Client Setup
// =============================================================================

function createClient() {
  const cloudId = process.env.ELASTICSEARCH_CLOUD_ID;
  const apiKey = process.env.ELASTICSEARCH_API_KEY;
  const url = process.env.ELASTICSEARCH_URL;
  const username = process.env.ELASTICSEARCH_USERNAME;
  const password = process.env.ELASTICSEARCH_PASSWORD;
  const insecure = process.env.ELASTICSEARCH_INSECURE === "true";

  const config = {};

  // Cloud ID takes precedence
  if (cloudId) {
    config.cloud = { id: cloudId };
  } else if (url) {
    config.node = url;
  } else {
    console.error("Error: No Elasticsearch connection configured.");
    console.error("");
    console.error("Set one of these environment variable combinations:");
    console.error("  1. Elastic Cloud: ELASTICSEARCH_CLOUD_ID + ELASTICSEARCH_API_KEY");
    console.error("  2. Direct URL + API Key: ELASTICSEARCH_URL + ELASTICSEARCH_API_KEY");
    console.error("  3. Basic Auth: ELASTICSEARCH_URL + ELASTICSEARCH_USERNAME + ELASTICSEARCH_PASSWORD");
    console.error("");
    console.error("For local development, use start-local to run Elasticsearch via Docker:");
    console.error("  https://github.com/elastic/start-local");
    console.error("");
    console.error("  curl -fsSL https://elastic.co/start-local | sh");
    console.error("");
    console.error("Then configure the environment:");
    console.error("  source elastic-start-local/.env");
    console.error('  export ELASTICSEARCH_URL="$ES_LOCAL_URL"');
    console.error('  export ELASTICSEARCH_API_KEY="$ES_LOCAL_API_KEY"');
    process.exit(1);
  }

  // Authentication
  if (apiKey) {
    config.auth = { apiKey };
  } else if (username && password) {
    config.auth = { username, password };
  }

  // TLS settings
  if (insecure) {
    config.tls = { rejectUnauthorized: false };
  }

  // Set User-Agent for tracking agentic API usage
  config.headers = { "User-Agent": "elastic-agentic" };

  return new Client(config);
}

// =============================================================================
// ES|QL Execution
// =============================================================================

async function executeEsql(client, query, format = "json") {
  try {
    const response = await client.esql.query({
      query,
      format,
    });
    return { success: true, data: response };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      query,
      details: error.meta?.body?.error || error,
    };
  }
}

// =============================================================================
// Cluster Info
// =============================================================================

function parseVersion(versionString) {
  const clean = versionString.replace(/-SNAPSHOT.*$/, "");
  const [major, minor, patch] = clean.split(".").map(Number);
  return { major, minor, patch: patch || 0, snapshot: versionString.includes("-SNAPSHOT"), raw: versionString };
}

async function getClusterInfo(client) {
  try {
    const info = await client.info();
    const version = parseVersion(info.version.number);
    const buildFlavor = info.version.build_flavor || "default";
    const isServerless = buildFlavor === "serverless";
    return {
      success: true,
      cluster: info.cluster_name,
      version: info.version.number,
      parsed: version,
      buildFlavor,
      isServerless,
      lucene: info.version.lucene_version,
    };
  } catch {
    // GET / requires cluster:monitor — fall back to SHOW INFO (ES|QL only needs query privileges).
    // SHOW INFO returns version/date/hash. On Serverless the version field is a build hash
    // (e.g. "a]b1c2d3e4f5") rather than a semver string — we use this to detect Serverless.
    try {
      const result = await client.esql.query({ query: "SHOW INFO", format: "json" });
      if (result.values?.[0]) {
        const [version] = result.values[0];
        const isSemver = /^\d+\.\d+\.\d+/.test(version);
        const isServerless = !isSemver;
        const parsed = isSemver ? parseVersion(version) : parseVersion("8.11.0");
        return {
          success: true,
          cluster: "(unknown — limited API key)",
          version: isServerless ? `${version} (Serverless)` : version,
          parsed,
          buildFlavor: isServerless ? "serverless" : "default",
          isServerless,
          lucene: "(unknown)",
          viaShowInfo: true,
        };
      }
    } catch (fallbackError) {
      return { success: false, error: fallbackError.message };
    }
    return { success: false, error: "Could not determine cluster info via GET / or SHOW INFO" };
  }
}

function formatClusterHeader(info) {
  if (!info.success) return "";
  const type = info.isServerless ? "Serverless" : info.parsed.snapshot ? "Snapshot" : "Self-managed";
  const suffix = info.viaShowInfo ? " (via SHOW INFO — API key lacks cluster:monitor)" : "";
  return `[Elasticsearch ${info.version} (${type}) | Cluster: ${info.cluster}]${suffix}`;
}

// =============================================================================
// Index Operations
// =============================================================================

async function listIndices(client, pattern = "*") {
  try {
    const query = `FROM ${pattern} METADATA _index | STATS doc_count = COUNT(*) BY _index | SORT doc_count DESC | LIMIT 1000`;
    const response = await client.esql.query({ query, format: "json" });
    const data = response.values.map((row) => ({
      index: row[1],
      "docs.count": String(row[0]),
    }));
    return { success: true, data };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function getSchema(client, index) {
  try {
    const query = `FROM ${index} | LIMIT 0`;
    const response = await client.esql.query({ query, format: "json" });
    const fields = (response.columns || []).map((col) => ({
      field: col.name,
      type: col.type,
    }));
    fields.sort((a, b) => a.field.localeCompare(b.field));
    return { success: true, data: fields };
  } catch (error) {
    return { success: false, error: error.message };
  }
}


// =============================================================================
// Output Formatting
// =============================================================================

function formatEsqlResults(response) {
  if (!response.columns || !response.values) {
    return JSON.stringify(response, null, 2);
  }

  const columns = response.columns.map((c) => c.name);
  const rows = response.values;

  if (rows.length === 0) {
    return "No results found.";
  }

  // Calculate column widths
  const widths = columns.map((col, i) => {
    const values = rows.map((row) => String(row[i] ?? "null"));
    return Math.max(col.length, ...values.map((v) => v.length));
  });

  // Format header
  const header = columns.map((col, i) => col.padEnd(widths[i])).join(" | ");
  const separator = widths.map((w) => "-".repeat(w)).join("-+-");

  // Format rows
  const formattedRows = rows.map((row) => row.map((val, i) => String(val ?? "null").padEnd(widths[i])).join(" | "));

  return [header, separator, ...formattedRows].join("\n");
}

// =============================================================================
// TSV Output
// =============================================================================

function formatAsTsv(response, includeHeader = true) {
  if (!response.columns || !response.values) {
    return "";
  }

  const columns = response.columns.map((c) => c.name);
  const rows = response.values;

  if (rows.length === 0) {
    return "";
  }

  const lines = [];

  // Header
  if (includeHeader) {
    lines.push(columns.join("\t"));
  }

  // Data rows
  for (const row of rows) {
    const formattedRow = row.map((val) => {
      if (val === null || val === undefined) return "";
      // Format dates more cleanly for charting
      if (typeof val === "string" && val.includes("T") && val.includes("Z")) {
        return val.replace("T", " ").replace("Z", "").split(".")[0];
      }
      return String(val);
    });
    lines.push(formattedRow.join("\t"));
  }

  return lines.join("\n");
}

function formatIndices(indices) {
  if (!indices || indices.length === 0) {
    return "No indices found.";
  }

  const maxNameLen = Math.max(...indices.map((idx) => idx.index.length), 5);
  const lines = indices.map((idx) => {
    const docs = idx["docs.count"] || "0";
    return `${idx.index.padEnd(maxNameLen)}  ${docs.padStart(12)} docs`;
  });

  return [`${"index".padEnd(maxNameLen)}  ${"docs".padStart(12)}`, "-".repeat(maxNameLen + 14), ...lines].join("\n");
}

function formatSchema(fields) {
  if (!fields || fields.length === 0) {
    return "No fields found.";
  }

  const maxFieldLen = Math.max(...fields.map((f) => f.field.length), 5);
  const maxTypeLen = Math.max(...fields.map((f) => f.type.length), 4);

  const header = `${"Field".padEnd(maxFieldLen)} | ${"Type".padEnd(maxTypeLen)}`;
  const separator = `${"-".repeat(maxFieldLen)}-+-${"-".repeat(maxTypeLen)}`;

  const lines = fields.map((f) => `${f.field.padEnd(maxFieldLen)} | ${f.type.padEnd(maxTypeLen)}`);

  return [header, separator, ...lines].join("\n");
}

// =============================================================================
// Main CLI
// =============================================================================

function parseArgs(args) {
  const flags = {
    tsv: false,
    header: true,
    help: false,
  };
  const positional = [];

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--tsv" || arg === "-t") {
      flags.tsv = true;
    } else if (arg === "--no-header") {
      flags.header = false;
    } else if (arg === "--help" || arg === "-h") {
      flags.help = true;
    } else if (!arg.startsWith("-")) {
      positional.push(arg);
    }
  }

  return { flags, positional };
}

async function main() {
  const args = process.argv.slice(2);
  const { flags, positional } = parseArgs(args);
  const command = positional[0];
  const input = positional.slice(1).join(" ");

  if (!command || flags.help) {
    printUsage();
    process.exit(flags.help ? 0 : 1);
  }

  // Handle help
  if (command === "help" || command === "--help" || command === "-h") {
    printUsage();
    process.exit(0);
  }

  // Handle commands that need client
  const client = createClient();

  try {
    switch (command) {
      case "raw":
        if (!input) {
          console.error("Error: No ES|QL query provided.");
          console.error('Usage: ./esql.js raw "FROM index | STATS count = COUNT(*)"');
          process.exit(1);
        }

        const result = await executeEsql(client, input);

        if (result.success) {
          if (flags.tsv) {
            // TSV output mode - clean output for charting
            console.log(formatAsTsv(result.data, flags.header));
          } else {
            // Normal verbose output
            console.log("=== ES|QL Query ===");
            console.log(input);
            console.log("\n=== Executing... ===\n");
            console.log("=== Results ===");
            console.log(formatEsqlResults(result.data));

            if (result.data.values) {
              console.log(`\n(${result.data.values.length} rows)`);
            }
          }
        } else {
          console.error("=== Error ===");
          console.error(result.error);
          if (result.details?.reason) {
            console.error("\nDetails:", result.details.reason);
          }
          console.log("\n=== Failed Query ===");
          console.log(result.query);
          process.exit(1);
        }
        break;

      case "indices":
        const pattern = input || "*";
        const indicesClusterInfo = await getClusterInfo(client);
        console.log(formatClusterHeader(indicesClusterInfo));
        console.log(`=== Indices matching "${pattern}" ===\n`);

        const indicesResult = await listIndices(client, pattern);

        if (indicesResult.success) {
          console.log(formatIndices(indicesResult.data));
        } else {
          console.error("Error:", indicesResult.error);
          process.exit(1);
        }
        break;

      case "schema":
        if (!input) {
          console.error("Error: No index specified.");
          console.error("Usage: ./esql.js schema <index-name>");
          process.exit(1);
        }

        const schemaClusterInfo = await getClusterInfo(client);
        console.log(formatClusterHeader(schemaClusterInfo));
        console.log(`=== Schema for "${input}" ===\n`);

        const schemaResult = await getSchema(client, input);

        if (schemaResult.success) {
          console.log(formatSchema(schemaResult.data));
        } else {
          console.error("Error:", schemaResult.error);
          process.exit(1);
        }
        break;

      case "test":
        // Test connection and show ES|QL feature availability
        console.log("=== Testing Elasticsearch Connection ===\n");
        try {
          const clusterInfo = await getClusterInfo(client);
          if (!clusterInfo.success) {
            console.error("✗ Connection failed:", clusterInfo.error);
            process.exit(1);
          }

          const { parsed: ver, isServerless, buildFlavor } = clusterInfo;
          const { major, minor } = ver;

          console.log("✓ Connected successfully!");
          console.log(`  Cluster:      ${clusterInfo.cluster}`);
          console.log(`  Version:      ${clusterInfo.version}`);
          console.log(`  Build flavor: ${buildFlavor}`);
          if (clusterInfo.viaShowInfo)
            console.log("  NOTE: Version detected via SHOW INFO (API key lacks cluster:monitor)");
          if (ver.snapshot) console.log(`  Snapshot:     yes (treating as ${major}.${minor})`);
          if (isServerless)
            console.log("  NOTE: Serverless — all ES|QL features available regardless of reported version");
          console.log(`  Lucene:       ${clusterInfo.lucene}`);

          console.log("\n=== ES|QL Feature Availability ===");

          // Test ES|QL availability
          const testResult = await executeEsql(client, 'ROW message = "ES|QL is working!"');
          if (testResult.success) {
            console.log("✓ ES|QL is available");
          } else {
            console.log("✗ ES|QL not available:", testResult.error);
            break;
          }

          // On Serverless, all features are available
          const allAvailable = isServerless;

          const features = [
            { name: "ES|QL (GA)", minVersion: [8, 14], status: "GA" },
            { name: "Async queries", minVersion: [8, 13], status: "GA" },
            { name: "Spatial functions", minVersion: [8, 14], status: "GA" },
            { name: "Type casting (::)", minVersion: [8, 15], status: "GA" },
            {
              name: "MATCH/QSTR functions",
              minVersion: [8, 17],
              status: major >= 9 ? "GA" : "Preview",
            },
            {
              name: "LOOKUP JOIN",
              minVersion: [8, 18],
              status: major >= 9 && minor >= 1 ? "GA" : "Preview",
            },
            { name: "Scoring (_score)", minVersion: [8, 18], status: "GA" },
            { name: "KQL function", minVersion: [8, 18], status: major >= 9 ? "GA" : "Preview" },
            { name: "INLINE STATS", minVersion: [9, 2], status: major >= 9 && minor >= 3 ? "GA" : "Preview" },
            { name: "Multi-field JOIN", minVersion: [9, 2], status: "GA" },
            { name: "CHANGE_POINT", minVersion: [8, 19], status: major >= 9 && minor >= 2 ? "GA" : "Preview" },
            { name: "TS command", minVersion: [9, 2], status: "Preview" },
            { name: "FORK / FUSE", minVersion: [9, 1], status: "Preview" },
            { name: "COMPLETION", minVersion: [8, 19], status: "Preview" },
            { name: "SET directive", minVersion: [9, 3], status: "Preview" },
          ];

          for (const feature of features) {
            const [minMajor, minMinor] = feature.minVersion;
            const available = allAvailable || major > minMajor || (major === minMajor && minor >= minMinor);
            const symbol = available ? "✓" : "✗";
            const status = available ? `(${feature.status})` : "(not available)";
            console.log(`${symbol} ${feature.name} ${status}`);
          }

          console.log("\n=== Limitations ===");
          console.log("• Max result rows: 10,000 (no cursor pagination)");
          console.log("• Timezone: Not supported in DATE_FORMAT/DATE_PARSE");
          console.log("• Nested fields: Not supported");
        } catch (error) {
          console.error("✗ Connection failed:", error.message);
          process.exit(1);
        }
        break;

      case "sample":
        const sampleArgs = positional.slice(1);
        const sampleIndex = sampleArgs[0];
        if (!sampleIndex) {
          console.error("Error: No index specified.");
          console.error('Usage: ./esql.js sample <index-pattern> [filter]');
          console.error('Examples:');
          console.error('  ./esql.js sample "filebeat-*"');
          console.error('  ./esql.js sample "filebeat-*" "kubernetes.namespace == \\"production\\" AND kubernetes.pod.name LIKE \\"pandora*\\""');
          process.exit(1);
        }

        const sampleClusterInfo = await getClusterInfo(client);
        console.log(formatClusterHeader(sampleClusterInfo));

        const filterClause = sampleArgs.length > 1 ? sampleArgs.slice(1).join(" ") : null;
        const sampleWhere = filterClause
          ? `WHERE @timestamp > NOW() - 1 hour AND ${filterClause}`
          : "WHERE @timestamp > NOW() - 1 hour";
        const sampleQuery = `FROM ${sampleIndex} | ${sampleWhere} | SORT @timestamp DESC | LIMIT 3`;

        console.log(`=== Sample from "${sampleIndex}" ===`);
        if (filterClause) console.log(`Filter: ${filterClause}`);
        console.log();

        try {
          const sampleResponse = await client.esql.query({ query: sampleQuery, format: "json" });
          const columns = sampleResponse.columns || [];
          const rows = sampleResponse.values || [];

          if (rows.length === 0) {
            console.log("No results in the last hour. Try a broader time range with raw query.");
            break;
          }

          // Find columns that have at least one non-null value
          const populatedCols = columns
            .map((col, i) => ({ name: col.name, type: col.type, index: i }))
            .filter((col) => rows.some((row) => row[col.index] !== null));

          console.log(`Fields with data (${populatedCols.length} of ${columns.length}):\n`);

          for (const row of rows) {
            console.log(`--- @timestamp: ${row[columns.findIndex((c) => c.name === "@timestamp")] || "?"} ---`);
            for (const col of populatedCols) {
              if (col.name === "@timestamp") continue;
              const val = row[col.index];
              if (val === null) continue;
              const display = String(val).length > 150 ? String(val).substring(0, 150) + "..." : String(val);
              console.log(`  ${col.name} (${col.type}): ${display}`);
            }
            console.log();
          }
        } catch (error) {
          console.error("Error:", error.message);
          console.error("\nFailed query:", sampleQuery);
          process.exit(1);
        }
        break;

      default:
        console.error(`Unknown command: ${command}`);
        printUsage();
        process.exit(1);
    }
  } finally {
    await client.close();
  }
}

function printUsage() {
  console.log(`
ES|QL Executor

Usage:
  ./esql.js <command> [options] [arguments]

Commands:
  raw <esql>            Execute a raw ES|QL query directly
  indices [pattern]     List indices (optional pattern filter)
  schema <index>        Show field mappings for an index
  sample <index> [filter]  Show recent docs with populated fields
  test                  Test Elasticsearch connection and ES|QL availability
  help                  Show this help message

Options:
  --tsv, -t             Output as TSV (tab-separated values)
  --no-header           Omit header row in TSV output

Environment Variables:
  ELASTICSEARCH_CLOUD_ID    Elastic Cloud deployment ID
  ELASTICSEARCH_URL         Direct Elasticsearch URL
  ELASTICSEARCH_API_KEY     API key for authentication
  ELASTICSEARCH_USERNAME    Username for basic auth
  ELASTICSEARCH_PASSWORD    Password for basic auth
  ELASTICSEARCH_INSECURE    Set to "true" to skip TLS verification

Examples:
  ./esql.js test
  ./esql.js indices "logs-*"
  ./esql.js schema "logs-2024.01.01"
  ./esql.js raw "FROM logs-* | STATS count = COUNT(*) BY host.name | LIMIT 10"
`);
}

main().catch((error) => {
  console.error("Fatal error:", error.message);
  process.exit(1);
});
