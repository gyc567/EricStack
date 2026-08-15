# EricStack

**AI-native engineering loop system — 26 skills covering planning, review, simplification, documentation, and knowledge accumulation.**
/>
**AI 原生工程循环系统 — 26 个技能，覆盖计划、审查、简化、文档和知识积累。**

> EricStack transforms a project into a compounding engineering intelligence. Every decision, review, and discussion becomes a persistent wiki page. Every process is a closed loop.
>
> EricStack 将一个项目转变为一个持续积累的工程智能体。每个决策、每次审查、每次讨论都沉淀为持久的 wiki 页面。每个流程都是闭合循环。

---

## What Is EricStack? | 什么是 EricStack？

EricStack is a LoopX-powered skill system for engineering teams. It provides **26 skills** organized in two tiers:

EricStack 是一个基于 LoopX 的工程团队技能系统，提供 **26 个技能**，分为两个层级：

| Tier / 层级 | Count / 数量 | Purpose / 用途 |
|---|---|---|
| `erics-process-*` (Discipline / 纪律) | 11 | Enforce standards — code review, prose quality, docs, simplification / 执行标准 — 代码审查、prose 质量、文档、简化 |
| `erics-ability-*` (Action / 能力) | 15 | Execute workflows — planning, debugging, benchmarking, retros / 执行工作流 — 计划、调试、性能基准、回顾 |

Skills run inside Claude Code (or any LoopX-compatible host). No separate server, no daemon, no API keys required for the skill system itself.
技能运行在 Claude Code（或任何兼容 LoopX 的 host）中。技能系统本身无需独立服务器、无需守护进程、无需额外 API key。

---

## One-Click Install | 一键安装

粘贴以下内容到任意 AI Agent（Claude Code / Codex / PI / OpenCode / OpenClaw / Hermes Agent / OMP / JCODE）：

```markdown
帮我安装 EricStack：
1. 运行：git clone https://github.com/gyc567/EricStack.git ~/EricStack
2. 检测我的 Agent 平台（Claude Code / Codex / PI / OpenCode / OpenClaw / Hermes Agent / OMP / JCODE）
3. 将 ~/EricStack/.loopx/skills/ 下的所有 skills 复制到平台的 skills 目录
4. 将我的项目上下文切换到 ~/EricStack
5. 运行 /erics-loop-router 确认安装成功
```

支持平台 / Supported platforms：

| Platform 平台 | Skills directory 技能目录 |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex (codex-app) | `~/.claude/skills/` |
| PI | `~/.claude/skills/` |
| OpenCode | `~/.claude/skills/` |
| OpenClaw | `~/.claude/skills/` |
| Hermes Agent | `~/.claude/skills/` |
| OMP | `~/.claude/skills/` |
| JCODE | `~/.claude/skills/` |

所有平台共享同一个 `~/.claude/skills/` 目录 — 安装一次，所有 host 都能使用。

---

## Quick Start | 快速上手

### 1. Clone | 克隆

```bash
git clone https://github.com/gyc567/EricStack.git
cd EricStack
```

### 2. Open in llm_wiki | 在 llm_wiki 中打开

下载 [llm_wiki](https://github.com/nashsu/llm_wiki/releases)，然后：

```bash
# 在 llm_wiki 应用中：File → Open Project → 选择 EricStack 目录
```

### 3. Use Skills in Claude Code | 在 Claude Code 中使用技能

```
/erics-loop-router     # 询问："which skill for this?" — 路由到正确技能
```

或直接调用任何技能：/ Or invoke any skill directly:

| Command 命令 | English 功能 | 中文 功能 |
|---|---|---|
| `/erics-process-code-review` | Full PR review: coverage, prose, invariants | 全方位 PR 审查：coverage、prose、invariant |
| `/erics-ability-plan-eng-review` | Architecture + data flow review | 架构 + 数据流审查 |
| `/erics-ability-investigate` | 4-phase debugging: investigate → analyze → hypothesize → implement | 四阶段调试：调查→分析→假设→实施 |
| `/erics-ability-cso` | Security audit (OWASP Top 10 + STRIDE) | 安全审计（OWASP Top 10 + STRIDE） |
| `/erics-ability-health` | Code quality dashboard: types, lint, tests, dead code | 代码质量仪表盘：类型检查、lint、测试、死代码 |
| `/erics-ability-benchmark` | Performance regression detection (Core Web Vitals) | 性能回归检测（Core Web Vitals） |
| `/erics-ability-office-hours` | YC-style six forcing questions | YC 风格六问 |
| `/erics-ability-spec` | Vague intent → executable spec in 5 phases | 模糊意图 → 五阶段可执行 spec |
| `/erics-ability-retro` | Weekly retrospective with shipping streaks | 周迭代回顾（含发版 streaks） |
| `/erics-ability-context-save` | Save working context: git state + decisions + remaining | 保存工作上下文：git 状态 + 决策 + 剩余工作 |
| `/erics-ability-context-restore` | Resume from saved context | 从保存的上下文恢复 |
| `/erics-ability-upgrade` | Check for updates | 检查更新 |
| `/erics-process-find-simplifications` | Find dead code, over-built surfaces, simplification candidates | 发现死代码、过度建设、简化候选项 |
| `/erics-process-prose-standard` | Prose completeness + editorial discipline | prose 完整性 + 编辑纪律 |
| `/erics-process-trim-cot-leakage` | Remove chain-of-thought leakage from docs | 去除文档中的思维链泄漏 |

**查看全部 26 个技能 / See all 26 skills：** [`.loopx/erics-skills-index.md`](.loopx/erics-skills-index.md)

---

## Architecture | 架构

```
EricStack/
├── .loopx/
│   ├── skills/
│   │   ├── erics-loop-router/      # Skill router / 技能路由器
│   │   ├── erics-process-* (×11)  # Discipline skills / 纪律技能
│   │   └── erics-ability-* (×15)  # Action skills / 能力技能
│   ├── wiki/                       # LLM Wiki knowledge base / LLM Wiki 知识库
│   │   ├── concepts/              # Concept pages / 概念页面
│   │   ├── entities/              # Decision records / 决策记录
│   │   └── queries/              # Q&A pairs / Q&A 对
│   ├── sync-state.json            # Upstream sync state / 上游同步状态
│   ├── VERSION                    # Current version / 当前版本
│   └── bin/sync-skills.sh        # Update checker / 更新检查脚本
└── INTEGRATION.md                  # Full integration docs / 完整整合文档
```

---

## Knowledge Base | 知识库

EricStack 的知识库遵循 [LLM Wiki](https://github.com/nashsu/llm_wiki) 模式 — 一个持久化、持续积累的 wiki，随项目成长。

```
.loopx/wiki/
├── index.md      # 技能 + 决策 + 文档目录 / Skills + decisions + docs catalog
├── overview.md   # 自动更新的项目概览 / Auto-updated project summary
├── log.md       # 操作历史（仅追加）/ Operation history (append-only)
├── concepts/    # 模式、实践、原则 / Patterns, practices, principles
├── entities/    # 决策、人物、特性 / Decisions, people, features
└── queries/    # 常见问题与经验证答案 / Common questions with verified answers
```

在 llm_wiki app 中打开，可以看到知识图谱和聊天界面。

---

## Keeping Skills Up to Date | 保持技能更新

```bash
# 检查更新（每次技能路由时自动运行）
# Check for updates (runs automatically on every skill routing)
bash .loopx/bin/sync-skills.sh --check

# 同步上游技能源（当有更新时）
# Sync upstream skill sources (when updates available)
bash .loopx/bin/sync-skills.sh --execute

# 查看当前 EricStack 版本
# Check EricStack version
cat .loopx/VERSION
```

---

## Skill Naming | 技能命名规范

| Prefix 前缀 | English 含义 | 中文 含义 | When to use / 使用场景 |
|---|---|---|---|
| `erics-process-*` | Discipline / Standards | 纪律 / 标准 | Writing, reviewing, ensuring quality / 写作、审查、确保质量 |
| `erics-ability-*` | Action / Productivity | 行动 / 生产力 | Executing a specific workflow / 执行特定工作流 |

两者都适用时，写作/审查任务优先使用 `erics-process-*`。
When both apply, prefer `erics-process-*` for writing/review tasks.

---

## Documentation | 文档

| File / 文件 | Language / 语言 | Description / 说明 |
|---|---|---|
| `README.md` | EN + CN inline | This file / 本文件 |
| `README_CN.md` | 中文 | Standalone Chinese version / 独立中文版 |
| `docs/TUTORIAL.md` | 中文 | Complete usage tutorial / 完整使用教程 |
| `INTEGRATION.md` | 中文 | Full integration plan / 完整整合方案 |
| `.loopx/llm-wiki-integration.md` | 中文 | LLM Wiki integration guide / LLM Wiki 整合指南 |

---

## License | 许可证

MIT License — see [`LICENSE`](LICENSE)
