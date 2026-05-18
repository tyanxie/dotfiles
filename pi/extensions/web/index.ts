/**
 * Web Extension
 *
 * 网络内容获取扩展，全局可用。
 * 提供网页拉取（fetch）和搜索（search）能力。
 * - Fetch: Jina Reader API（免费，无需 key）
 * - Search: Tavily Search API（需要 TAVILY_API_KEY）
 *
 * Tool: web
 *   - action: "search" — 搜索网络内容
 *   - action: "fetch"  — 拉取指定 URL 的网页内容
 */

import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import {
  webFetch,
  webSearch,
  formatFetchResult,
  formatSearchResult,
  TAVILY_API_KEY_ENV,
  type FetchResult,
  type SearchResult,
} from "./core.js";

// ─── 渲染辅助 ────────────────────────────────────────────────────────────────────

interface WebDetails {
  action: "search" | "fetch";
  query?: string;
  url?: string;
  response: string;
}

const MAX_TRUNCATE_CHARS = 80;

function truncateText(text: string, flag: { hasTruncation: boolean }): string {
  const normalized = text.replace(/\s+/g, " ").trim();
  if (normalized.length <= MAX_TRUNCATE_CHARS) return normalized;
  flag.hasTruncation = true;
  return normalized.slice(0, MAX_TRUNCATE_CHARS - 3) + "...";
}

function renderCall(args: Record<string, unknown>, theme: Theme): Text {
  const a = args as { action?: string; query?: string; url?: string };
  const action = a.action ?? "fetch";
  const target = action === "search" ? (a.query ?? "") : (a.url ?? "");
  const text =
    theme.fg("toolTitle", theme.bold("web ")) +
    theme.fg("accent", action) +
    " " +
    theme.fg("dim", target);
  return new Text(text, 0, 0);
}

function renderResult(
  result: {
    content: Array<{ type: string; text?: string }>;
    details?: unknown;
  },
  options: { expanded?: boolean; isPartial?: boolean },
  theme: Theme,
): Text {
  const details = result.details as WebDetails | undefined;

  if (!details) {
    const text = result.content[0];
    return new Text(
      text?.type === "text" ? (text.text ?? "") : "(no output)",
      0,
      0,
    );
  }

  const expanded = options?.expanded ?? false;
  const indent = "  ";
  const lines: string[] = [""];
  const flag = { hasTruncation: false };

  // [Input]
  const inputLabel =
    details.action === "search"
      ? `query: "${details.query}"`
      : `url: ${details.url}`;

  if (expanded) {
    lines.push(indent + theme.fg("mdHeading", "[Input]"));
    lines.push(indent + inputLabel);
    lines.push("");
  } else {
    lines.push(indent + theme.fg("mdHeading", "[Input]") + " " + inputLabel);
  }

  // [Output]
  if (expanded) {
    lines.push(indent + theme.fg("mdHeading", "[Output]"));
    for (const line of details.response.split("\n")) {
      lines.push(indent + line);
    }
  } else {
    lines.push(
      indent +
        theme.fg("mdHeading", "[Output]") +
        " " +
        truncateText(details.response, flag),
    );
  }

  if (flag.hasTruncation) {
    lines.push("");
    lines.push(indent + theme.fg("dim", "(Ctrl+O to expand)"));
  }

  return new Text(lines.join("\n"), 0, 0);
}

// ─── Tool 参数 schema ────────────────────────────────────────────────────────────

const WebParams = Type.Object({
  action: Type.Union([Type.Literal("search"), Type.Literal("fetch")], {
    description:
      'Action to perform: "search" for web search, "fetch" for fetching a URL',
  }),
  query: Type.Optional(
    Type.String({
      description: "Search query (required when action is search)",
    }),
  ),
  url: Type.Optional(
    Type.String({
      description: "URL to fetch (required when action is fetch)",
    }),
  ),
});

// ─── Setup 引导 ──────────────────────────────────────────────────────────────────

const SETUP_GUIDE = [
  "Web Extension Setup (Tavily API Key)",
  "",
  "The fetch action works without a key.",
  "To enable search, configure TAVILY_API_KEY:",
  "",
  "1. Visit https://app.tavily.com/ and sign up with GitHub/Google (Free: 1000 queries/month)",
  "2. Copy your API key from the dashboard",
  "3. Add to ~/.zshrc or ~/.bashrc:",
  '   export TAVILY_API_KEY="tvly-..."',
  "4. Restart pi to activate web search.",
].join("\n");

// ─── 扩展入口 ────────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, _ctx) => {
    // 注册 /setup-web 命令
    pi.registerCommand("setup-web", {
      description: "Configure Tavily API key for web search",
      handler: async (_args, cmdCtx) => {
        if (process.env[TAVILY_API_KEY_ENV]) {
          cmdCtx.ui.notify(
            "TAVILY_API_KEY already configured. Web search is active.",
            "info",
          );
          return;
        }
        pi.sendMessage({
          customType: "web-setup",
          content: SETUP_GUIDE,
          display: true,
        });
      },
    });

    // 注册 setup 消息渲染器
    pi.registerMessageRenderer("web-setup", (message, _options, theme) => {
      const lines = (message.content as string).split("\n");
      let text = "";
      for (const line of lines) {
        if (line === lines[0]) {
          text += theme.fg("accent", theme.bold(line));
        } else if (line.match(/^\d\./)) {
          text += theme.fg("toolOutput", line);
        } else {
          text += theme.fg("dim", line);
        }
        text += "\n";
      }
      return new Text(text.trimEnd(), 0, 0);
    });

    // 注册 web tool
    pi.registerTool({
      name: "web",
      label: "Web",
      description:
        "Search the web or fetch a URL's content as Markdown. " +
        'Use action "search" with a query to find information, ' +
        'or action "fetch" with a URL to retrieve page content.',
      promptSnippet: "Search the web or fetch URL content as Markdown",
      parameters: WebParams,
      execute: async (_toolCallId, params, signal) => {
        const p = params as {
          action: "search" | "fetch";
          query?: string;
          url?: string;
        };

        let responseText: string;

        if (p.action === "search") {
          if (!p.query)
            throw new Error("Parameter 'query' is required for search action.");
          const result: SearchResult = await webSearch(p.query, signal);
          responseText = formatSearchResult(result);
        } else {
          if (!p.url)
            throw new Error("Parameter 'url' is required for fetch action.");
          const result: FetchResult = await webFetch(p.url, signal);
          responseText = formatFetchResult(result);
        }

        const details: WebDetails = {
          action: p.action,
          query: p.query,
          url: p.url,
          response: responseText,
        };

        return {
          content: [{ type: "text" as const, text: responseText }],
          details,
        };
      },
      renderCall,
      renderResult,
    });
  });
}
