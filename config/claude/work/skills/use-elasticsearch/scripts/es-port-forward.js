#!/usr/bin/env node
// Manage the Elasticsearch port-forward for log querying.
// Usage: es-port-forward.js start | stop | status
//
// Starts a kubectl port-forward to the ES cluster in the infra namespace.
// If kubectl is not authenticated, the command will block until the user
// completes authentication (e.g. browser-based OIDC flow).

import { spawn, execSync, execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, unlinkSync, existsSync } from "node:fs";

const LOCAL_PORT = 9200;
const REMOTE_PORT = 9200;
const NAMESPACE = "infra";
const SERVICE = "svc/logs-es-http";
const PIDFILE = "/tmp/es-port-forward.pid";

function getApiKey() {
  const key = process.env.ELASTICSEARCH_API_KEY;
  if (!key) {
    console.error("ERROR: ELASTICSEARCH_API_KEY environment variable is not set.");
    process.exit(1);
  }
  return key;
}

function portInUse() {
  try {
    const out = execSync(`lsof -iTCP:${LOCAL_PORT} -sTCP:LISTEN -t`, {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    });
    return out.trim().length > 0;
  } catch {
    return false;
  }
}

function readPid() {
  if (!existsSync(PIDFILE)) return null;
  const content = readFileSync(PIDFILE, "utf-8").trim();
  const pid = parseInt(content, 10);
  return Number.isNaN(pid) ? null : pid;
}

function pidAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

function esReachable() {
  const apiKey = process.env.ELASTICSEARCH_API_KEY;
  if (!apiKey) return false;
  try {
    const out = execFileSync(
      "curl",
      ["-sk", "--max-time", "3", "-H", `Authorization: ApiKey ${apiKey}`, `https://localhost:${LOCAL_PORT}/`],
      { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] },
    );
    return out.includes("cluster_name");
  } catch {
    return false;
  }
}

function isRunning() {
  const pid = readPid();
  const processUp = (pid && pidAlive(pid)) || portInUse();
  return processUp && esReachable();
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForEs(maxWaitSecs) {
  for (let waited = 0; waited < maxWaitSecs; waited += 2) {
    if (esReachable()) return true;
    await sleep(2000);
  }
  return esReachable();
}

function doStop() {
  const pid = readPid();
  if (pid && pidAlive(pid)) {
    console.log(`Stopping ES port-forward (PID ${pid})...`);
    try { process.kill(pid, "SIGTERM"); } catch {}
    for (let waited = 0; waited < 10; waited++) {
      if (!pidAlive(pid)) break;
      execSync("sleep 1");
    }
    if (pidAlive(pid)) {
      try { process.kill(pid, "SIGKILL"); } catch {}
    }
  }
  try { unlinkSync(PIDFILE); } catch {}
  console.log("ES port-forward stopped.");
}

async function doStart() {
  if (isRunning()) {
    console.log(`ES port-forward is already active on port ${LOCAL_PORT}.`);
    process.exit(0);
  }

  // Clean up stale process
  const stalePid = readPid();
  if (stalePid && pidAlive(stalePid)) {
    try { process.kill(stalePid, "SIGTERM"); } catch {}
    await sleep(1000);
  }
  try { unlinkSync(PIDFILE); } catch {}

  getApiKey(); // validates env var is set

  console.log(`Starting ES port-forward (${NAMESPACE}/${SERVICE} -> localhost:${LOCAL_PORT})...`);
  console.log("If kubectl needs authentication, complete the login flow now.");

  const child = spawn(
    "kubectl",
    ["port-forward", "-n", NAMESPACE, SERVICE, `${LOCAL_PORT}:${REMOTE_PORT}`],
    { stdio: "inherit", detached: true },
  );

  const pid = child.pid;
  writeFileSync(PIDFILE, String(pid));
  child.unref();

  console.log(`Port-forward starting (PID ${pid}). Waiting for ES to become reachable...`);

  if (await waitForEs(120)) {
    console.log(`ES is reachable on localhost:${LOCAL_PORT}.`);
  } else {
    console.error("WARNING: ES did not become reachable within 120s.");
    console.error("You may need to authenticate with kubectl first.");
    process.exit(1);
  }
}

function doStatus() {
  if (isRunning()) {
    console.log(`ES port-forward is active on port ${LOCAL_PORT}.`);
  } else {
    const pid = readPid();
    if (pid && pidAlive(pid)) {
      console.log(`Port-forward process is running (PID ${pid}) but ES is not reachable.`);
    } else if (portInUse()) {
      console.log(`Port ${LOCAL_PORT} is in use but ES is not reachable (different process?).`);
    } else {
      console.log("ES port-forward is not running.");
    }
  }
}

const command = process.argv[2];
switch (command) {
  case "start":
    doStart();
    break;
  case "stop":
    doStop();
    break;
  case "status":
    doStatus();
    break;
  default:
    console.log("Usage: es-port-forward.js {start|stop|status}");
    process.exit(1);
}
