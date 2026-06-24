// RTK (Rust Token Killer) 扩展 — 拦截 bash 命令，改写为 rtk 等价命令以节省 token。
// 搬运并改写自：https://github.com/rtk-ai/rtk/blob/ee9e2f8/hooks/pi/rtk.ts
//
// 原理：监听 tool_call 事件，对 bash 类型的调用执行 rtk rewrite 查询，
// 如果存在等价的 rtk 命令则原地改写 event.input.command。
// 所有过滤逻辑由 rtk 二进制负责，本扩展只做命令路由。
//
// rtk rewrite 退出码协议：
//   0 + stdout → 有改写，允许执行
//   1          → 无 RTK 等价，原样放行
//   2          → deny 规则命中（本扩展不处理）
//   3 + stdout → 有改写（advisory），允许执行

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

const REWRITE_TIMEOUT_MS = 2_000;
const MIN_SUPPORTED_RTK_MINOR = 23;

// 解析 "X.Y.Z" semver，返回 [major, minor, patch] 或 null
function parseSemver(raw: string): [number, number, number] | null {
  const m = raw.trim().match(/(\d+)\.(\d+)\.(\d+)/);
  if (!m) return null;
  return [parseInt(m[1], 10), parseInt(m[2], 10), parseInt(m[3], 10)];
}

export default async function (pi: ExtensionAPI) {
  // 启动时探测 rtk 版本，未安装或过旧则禁用
  const ver = await pi.exec("rtk", ["--version"], {
    timeout: REWRITE_TIMEOUT_MS,
  });

  if (ver.code !== 0) {
    pi.on("session_start", async (_event, ctx) => {
      ctx.ui.notify(
        "rtk binary not found in PATH — rtk extension disabled",
        "warning",
      );
    });
    return;
  }

  const parsed = parseSemver(ver.stdout.replace(/^rtk\s+/, ""));
  if (parsed) {
    const [major, minor] = parsed;
    if (major === 0 && minor < MIN_SUPPORTED_RTK_MINOR) {
      pi.on("session_start", async (_event, ctx) => {
        ctx.ui.notify(
          `rtk ${ver.stdout.trim()} is too old (need >= 0.23.0) — rtk extension disabled`,
          "warning",
        );
      });
      return;
    }
  }

  // 注册 tool_call 事件监听，对 bash 命令做 rewrite
  pi.on("tool_call", async (event, ctx) => {
    try {
      if (!isToolCallEventType("bash", event)) return;

      const cmd = event.input.command;
      if (typeof cmd !== "string" || cmd.trim() === "") return;
      if (cmd.startsWith("rtk ")) return;
      if (process.env.RTK_DISABLED === "1") return;

      // 调用 rtk rewrite 查询改写结果
      const result = await pi.exec("rtk", ["rewrite", cmd], {
        timeout: REWRITE_TIMEOUT_MS,
        signal: ctx.signal,
      });

      if (result.killed) return;
      if (result.code !== 0 && result.code !== 3) return;

      const rewritten = result.stdout.trim();
      if (!rewritten || rewritten === cmd) return;

      // 改写命令并通知用户
      event.input.command = rewritten;
      ctx.ui.notify(`rtk: ${cmd} → ${rewritten}`, "info");
    } catch {
      // fail-open：出错时静默放行，不阻塞命令执行
      return;
    }
  });
}
