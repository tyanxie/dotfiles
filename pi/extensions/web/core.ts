/**
 * Web Core - 网络内容获取核心逻辑
 *
 * - Fetch: 使用 Jina Reader API (https://r.jina.ai/{url}) 将网页转为 Markdown
 * - Search: 使用 Tavily Search API (https://api.tavily.com) 进行网络搜索
 *
 * 纯逻辑模块，不依赖 pi API。
 */

// ─── 常量 ────────────────────────────────────────────────────────────────────────

const JINA_READER_BASE = "https://r.jina.ai/";
const TAVILY_SEARCH_ENDPOINT = "https://api.tavily.com/search";

/** 环境变量名 */
export const TAVILY_API_KEY_ENV = "TAVILY_API_KEY";

/** 返回内容最大字符数（约 5000 tokens） */
const MAX_CONTENT_CHARS = 20000;

/** 搜索结果最大条数 */
const MAX_SEARCH_RESULTS = 5;

// ─── 类型定义 ────────────────────────────────────────────────────────────────────

export interface FetchResult {
  title: string;
  url: string;
  content: string;
}

export interface SearchResultItem {
  title: string;
  url: string;
  description: string;
}

export interface SearchResult {
  query: string;
  results: SearchResultItem[];
}

// ─── 内部工具 ────────────────────────────────────────────────────────────────────

/**
 * 截断文本至指定长度
 */
function truncateContent(text: string, maxChars: number): string {
  if (text.length <= maxChars) return text;
  return text.slice(0, maxChars) + "\n\n... (content truncated)";
}

// ─── Fetch (Jina Reader) ─────────────────────────────────────────────────────────

/**
 * 拉取网页内容并转为 Markdown
 */
export async function webFetch(
  url: string,
  signal?: AbortSignal,
): Promise<FetchResult> {
  const apiUrl = JINA_READER_BASE + encodeURIComponent(url);

  const response = await fetch(apiUrl, {
    method: "GET",
    headers: {
      Accept: "application/json",
      "X-No-Cache": "true",
    },
    signal,
  });

  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(
      `HTTP ${response.status}: ${response.statusText}${body ? ` - ${body}` : ""}`,
    );
  }

  const data = (await response.json()) as {
    data?: { title?: string; url?: string; content?: string };
  };

  const result = data.data;
  if (!result?.content) {
    throw new Error("Failed to extract content from the page.");
  }

  return {
    title: result.title ?? "",
    url: result.url ?? url,
    content: truncateContent(result.content, MAX_CONTENT_CHARS),
  };
}

// ─── Search (Tavily) ─────────────────────────────────────────────────────────────

/**
 * 搜索网络内容（需要 TAVILY_API_KEY）
 */
export async function webSearch(
  query: string,
  signal?: AbortSignal,
): Promise<SearchResult> {
  const apiKey = process.env[TAVILY_API_KEY_ENV];
  if (!apiKey) {
    throw new Error(
      "Search requires TAVILY_API_KEY. Run /setup-web to configure.",
    );
  }

  const response = await fetch(TAVILY_SEARCH_ENDPOINT, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      api_key: apiKey,
      query,
      max_results: MAX_SEARCH_RESULTS,
      include_answer: false,
    }),
    signal,
  });

  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(
      `HTTP ${response.status}: ${response.statusText}${body ? ` - ${body}` : ""}`,
    );
  }

  const data = (await response.json()) as {
    results?: Array<{
      title?: string;
      url?: string;
      content?: string;
    }>;
  };

  const items = data.results;
  if (!Array.isArray(items) || items.length === 0) {
    throw new Error("No search results found.");
  }

  const results: SearchResultItem[] = items
    .slice(0, MAX_SEARCH_RESULTS)
    .map((item) => ({
      title: item.title ?? "",
      url: item.url ?? "",
      description: item.content ?? "",
    }));

  return { query, results };
}

// ─── 格式化 ──────────────────────────────────────────────────────────────────────

/**
 * 格式化 fetch 结果为文本
 */
export function formatFetchResult(result: FetchResult): string {
  const lines: string[] = [];
  if (result.title) lines.push(`# ${result.title}`);
  lines.push(`> Source: ${result.url}`);
  lines.push("");
  lines.push(result.content);
  return lines.join("\n");
}

/**
 * 格式化 search 结果为文本
 */
export function formatSearchResult(result: SearchResult): string {
  const lines: string[] = [];
  lines.push(`Search results for: "${result.query}"`);
  lines.push("");

  for (let i = 0; i < result.results.length; i++) {
    const item = result.results[i];
    lines.push(`## ${i + 1}. ${item.title}`);
    lines.push(`URL: ${item.url}`);
    if (item.description) lines.push(`> ${item.description}`);
    lines.push("");
  }

  return lines.join("\n");
}
