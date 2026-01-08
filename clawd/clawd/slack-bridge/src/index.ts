// ABOUTME: Slack-to-clawdis gateway bridge using Socket Mode
// ABOUTME: Forwards Slack DMs to clawdis and routes responses back

import { App } from "@slack/bolt";
import WebSocket from "ws";

// Configuration from environment variables (required)
const SLACK_BOT_TOKEN = process.env.SLACK_BOT_TOKEN;
const SLACK_APP_TOKEN = process.env.SLACK_APP_TOKEN;
const GATEWAY_URL = process.env.CLAWDIS_GATEWAY_URL || "ws://127.0.0.1:18789";
const GATEWAY_TOKEN = process.env.CLAWDIS_GATEWAY_TOKEN || "";

if (!SLACK_BOT_TOKEN || !SLACK_APP_TOKEN) {
  console.error("[slack-bridge] SLACK_BOT_TOKEN and SLACK_APP_TOKEN environment variables are required");
  process.exit(1);
}

// Protocol version expected by clawdis gateway (must match gateway's PROTOCOL_VERSION)
const PROTOCOL_VERSION = 2;

// Track pending requests
const pendingRequests = new Map<string, {
  resolve: (value: unknown) => void;
  reject: (error: Error) => void;
  channelId: string;
  threadTs?: string;
}>();

const activeRuns = new Map<string, {
  channelId: string;
  threadTs?: string;
  sent: boolean;
}>();

let ws: WebSocket | null = null;
let connId: string | null = null;
let requestCounter = 0;

// Initialize Slack app with Socket Mode
const app = new App({
  token: SLACK_BOT_TOKEN,
  appToken: SLACK_APP_TOKEN,
  socketMode: true,
});

function generateRequestId(): string {
  return `slack-${Date.now()}-${++requestCounter}`;
}

function connectToGateway(): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log(`[slack-bridge] connecting to gateway at ${GATEWAY_URL}`);

    ws = new WebSocket(GATEWAY_URL);

    ws.on("open", () => {
      console.log("[slack-bridge] WebSocket connected, sending hello");

      // Send connect/hello frame
      const connectFrame = {
        type: "req",
        id: generateRequestId(),
        method: "connect",
        params: {
          minProtocol: PROTOCOL_VERSION,
          maxProtocol: PROTOCOL_VERSION,
          client: {
            name: "slack-bridge",
            version: "1.0.0",
            platform: "node",
            mode: "bridge",
          },
          auth: GATEWAY_TOKEN ? { token: GATEWAY_TOKEN } : undefined,
        },
      };

      ws!.send(JSON.stringify(connectFrame));
    });

    ws.on("message", (data) => {
      try {
        const frame = JSON.parse(data.toString());

        if (frame.type === "res" && frame.ok && frame.payload?.type === "hello-ok") {
          connId = frame.payload.server?.connId;
          console.log(`[slack-bridge] connected to gateway (connId=${connId})`);
          resolve();
          return;
        }

        if (frame.type === "res" && !frame.ok) {
          console.error("[slack-bridge] gateway error:", frame.error?.message);
          if (!connId) {
            reject(new Error(frame.error?.message || "Connection failed"));
          }
          return;
        }

        handleGatewayFrame(frame);
      } catch (err) {
        console.error("[slack-bridge] failed to parse gateway message:", err);
      }
    });

    ws.on("error", (err) => {
      console.error("[slack-bridge] WebSocket error:", err);
      reject(err);
    });

    ws.on("close", (code, reason) => {
      console.log(`[slack-bridge] WebSocket closed: ${code} ${reason}`);
      connId = null;

      // Reconnect after delay
      setTimeout(() => {
        connectToGateway().catch(console.error);
      }, 5000);
    });
  });
}

function handleGatewayFrame(frame: {
  type: string;
  id?: string;
  ok?: boolean;
  payload?: unknown;
  error?: { message: string };
  event?: string;
}): void {
  if (frame.type === "res") {
    // Response to a request we sent
    const pending = frame.id ? pendingRequests.get(frame.id) : null;
    if (pending) {
      pendingRequests.delete(frame.id!);
      if (frame.ok) {
        pending.resolve(frame.payload);
      } else {
        pending.reject(new Error(frame.error?.message || "Unknown error"));
      }
    }
    return;
  }

  if (frame.type === "event") {
    if (frame.event === "chat") {
      console.log(`[slack-bridge] chat event: ${JSON.stringify(frame.payload).slice(0, 300)}`);
      handleChatEvent(frame.payload);
    }
    if (frame.event === "agent") {
      handleAgentEvent(frame.payload);
    }
    return;
  }
}

function dedupeText(text: string): string {
  const half = Math.floor(text.length / 2);
  const firstHalf = text.slice(0, half);
  const secondHalf = text.slice(half);
  if (firstHalf === secondHalf) {
    return firstHalf;
  }
  return text;
}

function handleChatEvent(payload: unknown): void {
  if (!payload || typeof payload !== "object") return;
  const evt = payload as Record<string, unknown>;
  const runId = evt.runId as string | undefined;
  const state = evt.state as string | undefined;
  const message = evt.message as Record<string, unknown> | undefined;
  const content = message?.content as Array<{ type: string; text?: string }> | undefined;
  let text = content?.[0]?.text;

  if (!runId) return;
  const context = activeRuns.get(runId);
  if (!context || context.sent) return;

  if (state === "final" && text?.trim()) {
    context.sent = true;
    text = dedupeText(text.trim());
    sendSlackMessage(context.channelId, text, context.threadTs);
    activeRuns.delete(runId);
  }
}

function handleAgentEvent(payload: unknown): void {
  if (!payload || typeof payload !== "object") return;

  const evt = payload as Record<string, unknown>;
  const runId = evt.runId as string | undefined;
  const stream = evt.stream as string | undefined;
  const data = evt.data as Record<string, unknown> | undefined;

  if (!runId) return;

  const context = activeRuns.get(runId);
  if (!context) return;

  if (stream === "job" && data?.error) {
    sendSlackMessage(context.channelId, `Error: ${data.error}`, context.threadTs);
    activeRuns.delete(runId);
  }
}

async function sendSlackMessage(channelId: string, text: string, threadTs?: string): Promise<void> {
  try {
    await app.client.chat.postMessage({
      channel: channelId,
      text,
      thread_ts: threadTs,
    });
  } catch (err) {
    console.error("[slack-bridge] failed to send Slack message:", err);
  }
}

async function sendToGateway(
  channelId: string,
  message: string,
  threadTs?: string
): Promise<void> {
  if (!ws || ws.readyState !== WebSocket.OPEN) {
    throw new Error("Gateway not connected");
  }

  const requestId = generateRequestId();

  const agentFrame = {
    type: "req",
    id: requestId,
    method: "agent",
    params: {
      message,
      sessionKey: `slack:${channelId}`,
      idempotencyKey: requestId,
      deliver: false,
    },
  };

  return new Promise((resolve, reject) => {
    pendingRequests.set(requestId, {
      resolve: (payload) => {
        const result = payload as { runId?: string };
        if (result?.runId) {
          activeRuns.set(result.runId, { channelId, threadTs, sent: false });
          console.log(`[slack-bridge] tracking runId=${result.runId.slice(0, 8)}`);
        }
        resolve();
      },
      reject: (error) => {
        sendSlackMessage(channelId, `Error: ${error.message}`, threadTs);
        reject(error);
      },
      channelId,
      threadTs,
    });

    ws!.send(JSON.stringify(agentFrame));
    console.log(`[slack-bridge] sent message to gateway: ${message.slice(0, 50)}...`);
  });
}

app.event("message", async ({ event, say }) => {
  if ("bot_id" in event && event.bot_id) return;
  if ("subtype" in event) return;

  const text = "text" in event ? event.text : undefined;
  if (!text) return;

  console.log(`[slack-bridge] received message: ${text.slice(0, 50)}...`);

  try {
    await app.client.reactions.add({
      channel: event.channel,
      timestamp: event.ts,
      name: "eyes",
    });
  } catch (err) {
    console.error("[slack-bridge] reaction failed:", err);
  }

  try {
    await sendToGateway(event.channel, text, event.ts);
  } catch (err) {
    console.error("[slack-bridge] failed to send to gateway:", err);
    await say(`Sorry, I couldn't process that: ${err instanceof Error ? err.message : "Unknown error"}`);
  }
});

async function main() {
  console.log("[slack-bridge] starting...");

  await connectToGateway();

  await app.start();
  console.log("[slack-bridge] Slack app is running!");

  const authTest = await app.client.auth.test();
  console.log(`[slack-bridge] Connected as: ${authTest.user} (bot_id: ${authTest.bot_id})`);
}

main().catch((err) => {
  console.error("[slack-bridge] fatal error:", err);
  process.exit(1);
});
