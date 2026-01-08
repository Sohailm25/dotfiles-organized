#!/usr/bin/env node
// ABOUTME: Skylight Calendar CLI for managing chores, tasks, and lists
// ABOUTME: Uses unofficial Skylight API with email/password auth

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const BASE_URL = "https://app.ourskylight.com/api";
const CONFIG_PATH = join(homedir(), ".clawdis", "clawdis.json");
const TOKEN_CACHE_PATH = join(homedir(), ".clawdis", "skylight-token.json");

// ─────────────────────────────────────────────────────────────────────────────
// Config & Auth
// ─────────────────────────────────────────────────────────────────────────────

function loadConfig() {
  if (!existsSync(CONFIG_PATH)) {
    console.error("Config not found at", CONFIG_PATH);
    process.exit(1);
  }
  const config = JSON.parse(readFileSync(CONFIG_PATH, "utf-8"));
  const skylight = config.skills?.entries?.skylight;
  if (!skylight?.email || !skylight?.password) {
    console.error("Skylight credentials not configured in clawdis.json");
    console.error("Add: skills.entries.skylight.email and .password");
    process.exit(1);
  }
  return skylight;
}

function loadCachedToken() {
  if (!existsSync(TOKEN_CACHE_PATH)) return null;
  try {
    const cached = JSON.parse(readFileSync(TOKEN_CACHE_PATH, "utf-8"));
    // Check if token is less than 24 hours old
    if (Date.now() - cached.timestamp < 24 * 60 * 60 * 1000) {
      return cached;
    }
  } catch {
    // Invalid cache
  }
  return null;
}

function saveTokenCache(userId, token, frameId) {
  const data = { userId, token, frameId, timestamp: Date.now() };
  writeFileSync(TOKEN_CACHE_PATH, JSON.stringify(data, null, 2));
  return data;
}

async function login(email, password) {
  const resp = await fetch(`${BASE_URL}/sessions`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Login failed: ${resp.status} ${text}`);
  }

  const json = await resp.json();
  const userId = json.data.id;
  const token = json.data.attributes.token;

  // Get frame ID
  const authHeader = makeAuthHeader(userId, token);
  const framesResp = await fetch(`${BASE_URL}/frames`, {
    headers: { Authorization: authHeader },
  });

  if (!framesResp.ok) {
    throw new Error(`Failed to get frames: ${framesResp.status}`);
  }

  const framesJson = await framesResp.json();
  const frameId = framesJson.data?.[0]?.id;

  if (!frameId) {
    throw new Error("No Skylight frame found for this account");
  }

  return saveTokenCache(userId, token, frameId);
}

function makeAuthHeader(userId, token) {
  const encoded = Buffer.from(`${userId}:${token}`).toString("base64");
  return `Basic ${encoded}`;
}

async function getAuth() {
  let cached = loadCachedToken();
  if (cached) return cached;

  const config = loadConfig();
  cached = await login(config.email, config.password);
  return cached;
}

function getHeaders(auth) {
  return {
    Authorization: makeAuthHeader(auth.userId, auth.token),
    "Content-Type": "application/json",
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// API Functions
// ─────────────────────────────────────────────────────────────────────────────

async function listChores(auth, fromDate, toDate) {
  const params = new URLSearchParams();
  if (fromDate) params.set("after", fromDate);
  if (toDate) params.set("before", toDate);

  const url = `${BASE_URL}/frames/${auth.frameId}/chores?${params}`;
  const resp = await fetch(url, { headers: getHeaders(auth) });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Failed to list chores: ${resp.status} ${text}`);
  }

  return resp.json();
}

async function createChore(auth, summary, date, categoryId, points = 0) {
  const body = {
    data: {
      type: "chore",
      attributes: {
        summary,
        start: date,
        start_time: null,
        status: "pending",
        recurring: false,
        recurrence_set: null,
        reward_points: points || null,
        emoji_icon: null,
      },
      relationships: {
        category: {
          data: {
            type: "category",
            id: String(categoryId),
          },
        },
      },
    },
  };

  const resp = await fetch(`${BASE_URL}/frames/${auth.frameId}/chores`, {
    method: "POST",
    headers: getHeaders(auth),
    body: JSON.stringify(body),
  });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Failed to create chore: ${resp.status} ${text}`);
  }

  return resp.json();
}

async function listCategories(auth) {
  const resp = await fetch(`${BASE_URL}/frames/${auth.frameId}/categories`, {
    headers: getHeaders(auth),
  });

  if (!resp.ok) {
    throw new Error(`Failed to list categories: ${resp.status}`);
  }

  return resp.json();
}

async function listLists(auth) {
  const resp = await fetch(`${BASE_URL}/frames/${auth.frameId}/lists`, {
    headers: getHeaders(auth),
  });

  if (!resp.ok) {
    throw new Error(`Failed to list lists: ${resp.status}`);
  }

  return resp.json();
}

async function getList(auth, listId) {
  const resp = await fetch(
    `${BASE_URL}/frames/${auth.frameId}/lists/${listId}`,
    { headers: getHeaders(auth) }
  );

  if (!resp.ok) {
    throw new Error(`Failed to get list: ${resp.status}`);
  }

  return resp.json();
}

async function addListItem(auth, listId, label) {
  const body = {
    data: {
      type: "list_item",
      attributes: { label, status: "pending" },
    },
  };

  const resp = await fetch(
    `${BASE_URL}/frames/${auth.frameId}/lists/${listId}/list_items`,
    {
      method: "POST",
      headers: getHeaders(auth),
      body: JSON.stringify(body),
    }
  );

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Failed to add list item: ${resp.status} ${text}`);
  }

  return resp.json();
}

// ─────────────────────────────────────────────────────────────────────────────
// CLI
// ─────────────────────────────────────────────────────────────────────────────

function parseArgs(args) {
  const result = { _: [] };
  for (let i = 0; i < args.length; i++) {
    if (args[i].startsWith("--")) {
      const key = args[i].slice(2);
      const next = args[i + 1];
      if (next && !next.startsWith("--")) {
        result[key] = next;
        i++;
      } else {
        result[key] = true;
      }
    } else {
      result._.push(args[i]);
    }
  }
  return result;
}

function formatDate(dateStr) {
  if (!dateStr) {
    // Default to today
    return new Date().toISOString().split("T")[0];
  }
  if (dateStr.toLowerCase() === "today") {
    return new Date().toISOString().split("T")[0];
  }
  if (dateStr.toLowerCase() === "tomorrow") {
    const d = new Date();
    d.setDate(d.getDate() + 1);
    return d.toISOString().split("T")[0];
  }
  return dateStr;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const [command, subcommand, ...rest] = args._;

  if (!command || command === "help" || args.help) {
    console.log(`
skylight - Skylight Calendar CLI

Commands:
  skylight chores list [--from DATE] [--to DATE]
  skylight chores add "TITLE" [--date DATE] [--assignee NAME] [--points N]

  skylight lists
  skylight lists show "LIST NAME"
  skylight lists add "LIST NAME" "ITEM"

  skylight categories
  skylight login

Options:
  --date     Date (YYYY-MM-DD, "today", "tomorrow")
  --from     Start date for listing
  --to       End date for listing
  --assignee Family member name
  --points   Reward points for chore
  --json     Output as JSON
`);
    return;
  }

  try {
    const auth = await getAuth();

    if (command === "login") {
      console.log("Logged in successfully!");
      console.log("Frame ID:", auth.frameId);
      return;
    }

    if (command === "categories") {
      const result = await listCategories(auth);
      if (args.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        console.log("Family members / Categories:");
        for (const cat of result.data || []) {
          const name = cat.attributes.label || cat.attributes.name || "Unknown";
          console.log(`  - ${name} (id: ${cat.id})`);
        }
      }
      return;
    }

    if (command === "chores") {
      if (subcommand === "list" || !subcommand) {
        const from = args.from || formatDate("today");
        const to = args.to || from;
        const result = await listChores(auth, from, to);

        if (args.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          console.log(`Chores (${from} to ${to}):`);
          for (const chore of result.data || []) {
            const pts = chore.attributes.reward_points;
            const ptsStr = pts ? ` [${pts} pts]` : "";
            console.log(`  - ${chore.attributes.summary}${ptsStr}`);
          }
          if (!result.data?.length) {
            console.log("  (none)");
          }
        }
        return;
      }

      if (subcommand === "add") {
        const title = rest[0];
        if (!title) {
          console.error("Usage: skylight chores add \"TITLE\" [--date DATE] [--assignee NAME]");
          process.exit(1);
        }

        const date = formatDate(args.date);
        const points = parseInt(args.points || "0", 10);

        // Get categories to find assignee
        const cats = await listCategories(auth);

        let categoryId = null;
        if (args.assignee) {
          const match = cats.data?.find(
            (c) =>
              (c.attributes.label || c.attributes.name || "").toLowerCase() === args.assignee.toLowerCase()
          );
          if (match) {
            categoryId = match.id;
          } else {
            console.error(`Assignee "${args.assignee}" not found`);
            console.log("Available:");
            for (const c of cats.data || []) {
              console.log(`  - ${c.attributes.label || c.attributes.name}`);
            }
            process.exit(1);
          }
        } else {
          // Default to first category (usually the account owner)
          categoryId = cats.data?.[0]?.id;
          if (!categoryId) {
            console.error("No categories found. Please specify --assignee");
            process.exit(1);
          }
        }

        const result = await createChore(auth, title, date, categoryId, points);

        if (args.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          console.log(`Created chore: ${title}`);
          console.log(`  Date: ${date}`);
          if (args.assignee) console.log(`  Assignee: ${args.assignee}`);
          if (points) console.log(`  Points: ${points}`);
        }
        return;
      }
    }

    if (command === "lists") {
      if (!subcommand) {
        const result = await listLists(auth);

        if (args.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          console.log("Lists:");
          for (const list of result.data || []) {
            const name = list.attributes.label || list.attributes.name || "Unknown";
            console.log(`  - ${name} (id: ${list.id})`);
          }
        }
        return;
      }

      if (subcommand === "show") {
        const listName = rest[0];
        if (!listName) {
          console.error('Usage: skylight lists show "LIST NAME"');
          process.exit(1);
        }

        // Find list by name
        const lists = await listLists(auth);
        const match = lists.data?.find(
          (l) => (l.attributes.label || l.attributes.name || "").toLowerCase() === listName.toLowerCase()
        );

        if (!match) {
          console.error(`List "${listName}" not found`);
          process.exit(1);
        }

        const result = await getList(auth, match.id);

        if (args.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          const listLabel = match.attributes.label || match.attributes.name;
          console.log(`${listLabel}:`);
          const items = result.included?.filter((i) => i.type === "list_item") || [];
          for (const item of items) {
            const status = item.attributes.status === "completed" ? "[x]" : "[ ]";
            console.log(`  ${status} ${item.attributes.label}`);
          }
          if (!items.length) {
            console.log("  (empty)");
          }
        }
        return;
      }

      if (subcommand === "add") {
        const listName = rest[0];
        const itemLabel = rest[1];

        if (!listName || !itemLabel) {
          console.error('Usage: skylight lists add "LIST NAME" "ITEM"');
          process.exit(1);
        }

        // Find list by name
        const lists = await listLists(auth);
        const match = lists.data?.find(
          (l) => (l.attributes.label || l.attributes.name || "").toLowerCase() === listName.toLowerCase()
        );

        if (!match) {
          console.error(`List "${listName}" not found`);
          console.log("Available lists:");
          for (const l of lists.data || []) {
            console.log(`  - ${l.attributes.label || l.attributes.name}`);
          }
          process.exit(1);
        }

        const result = await addListItem(auth, match.id, itemLabel);
        const listLabel = match.attributes.label || match.attributes.name;

        if (args.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          console.log(`Added "${itemLabel}" to ${listLabel}`);
        }
        return;
      }
    }

    console.error(`Unknown command: ${command} ${subcommand || ""}`);
    process.exit(1);
  } catch (err) {
    console.error("Error:", err.message);
    process.exit(1);
  }
}

main();
