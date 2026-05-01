---
name: powerflow
description: 用于需要设计决策的新功能开发或重大重构。触发条件：用户提出新功能需求、要求重构现有模块、需要多文件协作改动、涉及架构决策。不适用于：单文件小修改、typo修复、纯配置变更、bug修复。
---

# Powerflow 工作流

## 适用场景

- 需要设计决策的新功能开发
- 涉及多个文件或模块的重构
- 用户明确要求使用 powerflow（「用 powerflow」「走工作流」「完整流程」）

## 不适用场景

- 简单明确的修改（typo、格式调整、单行修复）
- 单一文件的小幅改动
- 纯配置变更
- Bug 修复（除非用户明确要求）

## 核心流程

1. **现状分析** → 查看相关文件、文档、近期提交
2. **头脑风暴** → 逐个提问、提出 2-3 种方案、推荐方案
3. **确认设计方案** → 用户认可推荐方案
4. **路径选择** → 必须停下来询问用户，给出倾向性建议及判断依据
5. 进入对应路径执行

## 关键规则

1. **禁止中途提交**：开发过程中绝不 git commit
2. **必须询问用户**：设计方案确认 ≠ 开发路径确认。方案确认后必须停下来询问走完整流程还是直接开发，给出倾向性建议及判断依据
3. **review loop 强制 subagent**：spec/plan/code review 必须派遣 subagent，不得自行审阅
4. **提交需用户确认**：列出文件清单，禁止 `git add .` / `git add -A`

## 触发词

- 需求类：「新功能」「需求」「重构」「重新设计」「改造」
- 规模类：「多个文件」「多模块」「架构」「大改」
- 显式调用：「用 powerflow」「走工作流」「完整流程」

识别到适用场景后，请 `read` 本文件完整内容获取详细指引。

<!-- CORE_GUIDE_END -->

---

# 完整工作流指引

## 两条路径简介

**完整流程**：适用于复杂需求。产出正式的设计文档和开发计划，经过 subagent 审阅和用户审阅后再开发。优势是质量可控、可回溯；代价是耗时较长。

**直接开发**：适用于中等复杂度需求。在头脑风暴确认方案后直接编码，不产出正式文档。优势是快速迭代；代价是缺少可回溯的设计记录。

## 共有阶段

无论哪条路径，都从这里开始：

1. **现状分析** — 查看相关文件、文档、近期提交
2. **头脑风暴** — 逐个提问澄清需求，提出 2-3 种方案，推荐方案（详见 [guides/brainstorming.md](./guides/brainstorming.md)）
3. **确认设计方案** — 用户认可推荐方案（或调整后认可）

## 路径选择（必须停下来询问用户）

方案确认后，**必须**停下来询问用户选择哪条路径，绝不能自行决定。

询问时需要：
- 简要说明两条路径的区别（完整流程会产出 spec + plan，直接开发则跳过）
- 给出自己的倾向性建议，并说明判断依据

建议依据参考：
- 涉及 3+ 个模块、架构变动、多人协作 → 建议完整流程
- 单模块、逻辑清晰、影响范围可控 → 建议直接开发
- 不确定时 → 判断核心是「实现方案是否有歧义需要正式文档来对齐」，如果没有歧义则直接开发

询问示例：
> 方案已确认。接下来有两条路径：
> - **完整流程**：产出 spec + plan 文档，经 subagent 审阅后再开发（适合需要对齐设计的场景）
> - **直接开发**：跳过文档，直接编码（适合方案已足够清晰的场景）
>
> 建议：这次改动涉及 X 和 Y 两个模块，但交互逻辑明确，我倾向**直接开发**。你觉得呢？

## 完整流程路径

用户选择完整流程后，依次执行：

### 阶段 A：编写设计文档

1. 按 [guides/writing-spec.md](./guides/writing-spec.md) 指引编写 spec
2. 保存至 `docs/powerflow/YYYY-MM-DD-feature-name/spec.md`
3. 进入 **spec review loop**：派遣 subagent 审阅，有问题则修改并重审
4. 通过后交给用户审阅
5. 用户有意见 → 修改 → 回到步骤 3 重新审阅

### 阶段 B：编写开发计划

1. 按 [guides/writing-plan.md](./guides/writing-plan.md) 指引编写 plan
2. 保存至 `docs/powerflow/YYYY-MM-DD-feature-name/plan.md`
3. 进入 **plan review loop**：派遣 subagent 审阅，有问题则修改并重审
4. 通过后交给用户审阅
5. 用户有意见 → 修改 → 回到步骤 3 重新审阅

### 阶段 C：执行开发

1. 按 [guides/execution.md](./guides/execution.md) 指引执行
2. 有依赖的任务 inline 顺序执行，无依赖的任务 subagent 并行执行
3. 开发过程中绝不提交

### 阶段 D：代码审阅与提交

1. 进入 **code review loop**：派遣 subagent 审阅代码质量 + spec/plan 合规性
2. 通过后交给用户审阅
3. 用户有意见 → 修改 → 回到步骤 1 重新审阅
4. 检查项目文档是否需更新（README、AGENTS.md 等）
5. 列出文件清单，用户确认后执行 git add + git commit

## 直接开发路径

用户选择直接开发后，依次执行：

### 阶段 A：输出设计结论摘要

输出结构化摘要（确认的功能点、约束条件、选定方案），供后续 code review 引用。

### 阶段 B：执行开发

1. 按 [guides/execution.md](./guides/execution.md) 指引执行
2. 默认 inline 顺序执行；识别到可并行任务时询问用户确认后并行
3. 开发过程中绝不提交

### 阶段 C：代码审阅与提交

1. 进入 **code review loop**：派遣 subagent 审阅代码质量 + 需求符合度
2. 通过后交给用户审阅
3. 用户有意见 → 修改 → 回到步骤 1 重新审阅
4. 检查项目文档是否需更新
5. 列出文件清单，用户确认后执行 git add + git commit

## Review Loop 规则

### 调用方式

通过 `subagent` 工具派遣 review subagent：
- `promptFile`：使用本文件所在目录下 `prompts/` 目录的对应文件的**绝对路径**
- `task`：包含具体审阅任务描述和所需上下文

路径解析：从 `<available_skills>` 中本 skill 的 `location` 字段获取 SKILL.md 绝对路径，替换文件名即可得到 prompts 目录路径。

示例：
```
# 假设 SKILL.md 位于 /home/user/.pi/extensions/powerflow/skills/powerflow/SKILL.md
# 则 prompts 目录为 /home/user/.pi/extensions/powerflow/skills/powerflow/prompts/

subagent({
  promptFile: "/home/user/.pi/extensions/powerflow/skills/powerflow/prompts/spec-review.md",
  task: "请审阅设计文档：/path/to/project/docs/powerflow/2026-05-01-feature/spec.md。项目背景：..."
})
```

### 各 review 阶段

**spec review：**
- promptFile: [prompts/spec-review.md](./prompts/spec-review.md)
- task: `"请审阅设计文档：{spec绝对路径}。项目背景：{简要说明}"`

**plan review：**
- promptFile: [prompts/plan-review.md](./prompts/plan-review.md)
- task: `"请审阅开发计划：{plan绝对路径}。对应的设计文档：{spec绝对路径}"`

**code review（完整流程）：**
- promptFile: [prompts/code-review.md](./prompts/code-review.md)
- task: `"请审阅代码变更。设计文档：{spec绝对路径}，开发计划：{plan绝对路径}。变更文件列表：{列表}。请通过 git diff HEAD 查看所有未提交的变更。"`

**code review（直接开发）：**
- promptFile: [prompts/code-review.md](./prompts/code-review.md)
- task: `"请审阅代码变更。需求描述：{需求摘要}。变更文件列表：{列表}。请通过 git diff HEAD 查看所有未提交的变更。"`

### 输出格式要求

所有 review subagent 必须输出结构化结论（最小格式，各 prompt 可扩展额外字段）：
```
## 审阅结论：通过 / 不通过

## 问题列表（如有）

### [严重程度] 问题标题
- 位置：...
- 问题描述：...
- 修改建议：...
```

### 判断逻辑

- 结论为「通过」→ 进入下一阶段
- 结论为「不通过」→ 根据问题列表修改 → 重新派遣 subagent 审阅
- 结论模糊/无法解析 → 视为「不通过」，重新审阅

### 终止条件

- 每个 review loop 最多迭代 **3 次**
- 超过 3 次仍未通过 → 强制交给用户审阅，说明当前存在的问题
- 用户反馈修改后重新进入 review loop 时，**迭代计数器重置**

## 提交策略

1. 开发过程中**绝不**执行 git commit
2. 用户审阅代码通过后，检查项目文档是否需要更新（README.md、AGENTS.md 等）
3. 需要更新则更新，不需要则跳过
4. 列出所有将要 `git add` 的文件清单
5. **禁止**使用 `git add .` / `git add -A`
6. 用户确认文件清单后才执行 git add + git commit

## 用户中断

用户可在任何阶段终止或调整工作流范围，agent 应立即响应，无需坚持走完剩余流程。

## 上下文管理

- spec 完成并通过用户审阅后，后续阶段通过读取 spec 文件获取信息，不依赖对话历史
- plan 完成后同理，执行阶段通过读取 plan 文件获取任务列表
- 如果对话过长，用户可开新 session 并指定从某阶段继续（如「请读取 plan 文件并执行开发」）

## 需求文档存放

完整流程中产生的文档存放于项目中：
```
docs/powerflow/
  YYYY-MM-DD-feature-name/
    spec.md    # 设计文档
    plan.md    # 开发计划
```

用户可通过指示覆盖此路径。
