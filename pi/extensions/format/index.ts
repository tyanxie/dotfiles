import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// formatter 配置：扩展名 → [命令, 构建参数的函数]
const FORMATTERS: Record<
  string,
  { cmd: string; args: (file: string) => string[] }
> = {
  ".go": { cmd: "goimports", args: (f) => ["-w", f] },
  ".js": { cmd: "prettier", args: (f) => ["--write", f] },
  ".jsx": { cmd: "prettier", args: (f) => ["--write", f] },
  ".ts": { cmd: "prettier", args: (f) => ["--write", f] },
  ".tsx": { cmd: "prettier", args: (f) => ["--write", f] },
  ".vue": { cmd: "prettier", args: (f) => ["--write", f] },
  ".html": { cmd: "prettier", args: (f) => ["--write", f] },
  ".css": { cmd: "prettier", args: (f) => ["--write", f] },
  ".md": { cmd: "prettier", args: (f) => ["--write", f] },
};

export default function (pi: ExtensionAPI) {
  // 缓存 formatter 可用性：true = 可用，false = 不可用（已警告）
  const availability = new Map<string, boolean>();

  async function checkAvailable(cmd: string): Promise<boolean> {
    if (availability.has(cmd)) return availability.get(cmd)!;

    const result = await pi.exec("which", [cmd], { timeout: 3000 });
    const available = result.code === 0;
    availability.set(cmd, available);
    return available;
  }

  pi.on("tool_result", async (event, ctx) => {
    // 只处理 edit/write 成功的情况
    if (event.isError) return;
    if (event.toolName !== "edit" && event.toolName !== "write") return;

    const filePath = (event.input as { path?: string }).path;
    if (!filePath) return;

    // 匹配扩展名
    const ext = filePath.slice(filePath.lastIndexOf(".")).toLowerCase();
    const formatter = FORMATTERS[ext];
    if (!formatter) return;

    // 检测 formatter 是否可用
    const available = await checkAvailable(formatter.cmd);
    if (!available) {
      // 首次检测到不可用时警告（checkAvailable 内部缓存保证只走一次）
      if (!availability.has(formatter.cmd + ":warned")) {
        availability.set(formatter.cmd + ":warned", true);
        ctx.ui.notify(
          `[format] '${formatter.cmd}' not found in PATH, skipping ${ext} files`,
          "warning",
        );
      }
      return;
    }

    // 执行格式化
    const args = formatter.args(filePath);
    const result = await pi.exec(formatter.cmd, args, { timeout: 10000 });

    if (result.code === 0) {
      ctx.ui.notify(
        `[format] ${filePath} formatted by ${formatter.cmd}`,
        "info",
      );
    } else {
      const fullCmd = `${formatter.cmd} ${args.join(" ")}`;
      const stderr =
        result.stderr?.trim() || result.stdout?.trim() || "unknown error";
      ctx.ui.notify(`[format] failed: \`${fullCmd}\`\n${stderr}`, "warning");
    }
  });
}
