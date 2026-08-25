# EricStack

**AI-native engineering loop system — 46 skills covering planning, review, simplification, documentation, and knowledge accumulation.**
/>
**AI 原生工程循环系统 — 46 个技能，覆盖计划、审查、简化、文档和知识积累。**

> EricStack transforms a project into a compounding engineering intelligence. Every decision, review, and discussion becomes a persistent wiki page. Every process is a closed loop.
>
> EricStack 将一个项目转变为一个持续积累的工程智能体。每个决策、每次审查、每次讨论都沉淀为持久的 wiki 页面。每个流程都是闭合循环。

---

## 项目定位

EricStack 是一个**技能元项目 + 工具集**，不是独立应用。本仓库本身包含：

| 组件 | 数量 | 用途 |
|---|---|---|
| SKILL.md 文件 | 41 | 可复用 AI 技能（流程纪律 + 工程能力） |
| .loopx/bin/ 脚本 | 4 | install / uninstall / sync / aps 安装 |
| .loopx/acceptance-pipeline/ | 1 | APS 框架配置（7 阶段管道规范） |
| `src/main.rs` | 1 | Rust 占位符 — 参见 [`src/README.md`](src/README.md) |
| `docs/` | 4 | 教程、审计、整合方案、wiki 参考 |

**重要：** EricStack **不**附送可运行的应用。`src/` 目录是**有意保留的占位符**。所有 skill 设计为在安装后对**你自己的代码库**进行操作。

### Skills 的力量从何而来？

Skill 是 prompt 模板 + 工作流规则 — **不是代码生成器**。它们的工作方式：

1. **读取** 你的项目结构（文件、git、约定）。
2. **调用** host 工具（`Read`、`Bash`、`Grep`、`Edit`）。
3. **写入** 工件到你的仓库（wiki 页面、plan 文件、PR）。

Skill **不能**为不存在的代码创建、测试或变异。例如：

- `erics-ability-bdd` 为**你的**登录表单生成 `.feature` 文件，不是 demo。
- `erics-process-mutation` 对**你的**测试套件运行变异测试。
- `erics-process-acceptance-pipeline` 需要**你的** features 和**你的** step handlers。

### 你需要提供什么

| 需要 | 示例 |
|---|---|
| 真实代码库 | 任意 Rust / Python / Go / TypeScript 项目 |
| 测试框架 | pytest、Jest、cargo test、go test 等 |
| 可选：BDD step handlers | APS 生成的测试要真正运行所必需 |

如果你想在集成前评估 EricStack，请阅读 [Quick Start 教程](docs/TUTORIAL.md) 获取 5 分钟的样例项目演练。

---
## What Is EricStack? | 什么是 EricStack？

EricStack is a LoopX-powered skill system for engineering teams. It provides **46 skills** organized in two tiers:

EricStack 是一个基于 LoopX 的工程团队技能系统，提供 **46 个技能**，分为两个层级：

| Tier / 层级 | Count / 数量 | Purpose / 用途 |
|---|---|---|
| `erics-process-*` (Discipline / 纪律) | 13 | Enforce standards — code review, prose quality, docs, simplification / 执行标准 — 代码审查、prose 质量、文档、简化 |
| `erics-ability-*` (Action / 能力) | 27 | Execute workflows — planning, debugging, benchmarking, retros / 执行工作流 — 计划、调试、性能基准、回顾 |

Skills run inside Claude Code (or any LoopX-compatible host). No separate server, no daemon, no API keys required for the skill system itself.
技能运行在 Claude Code（或任何兼容 LoopX 的 host）中。技能系统本身无需独立服务器、无需守护进程、无需额外 API key。

---

## One-Click Install | 一键安装

粘贴以下内容到任意 AI Agent（Claude Code / Codex / PI / OpenCode / OpenClaw / Hermes Agent / OMP / JCODE）：

```markdown
帮我安装 EricStack：
1. 安装 LoopX（必需）：
   curl -fsSL https://huangruiteng.github.io/loopx/install.sh | bash
2. 运行：git clone https://github.com/gyc567/EricStack.git ~/EricStack
3. 运行：bash ~/EricStack/.loopx/bin/install-ericsstack.sh
   （这会将全部 46 个 skills 以扁平目录结构复制到 ~/.claude/skills/）
4. 将我的项目上下文切换到 ~/EricStack
5. 如果 Node.js 可用（运行：node --version && npm --version）：
   - 运行：npm install -g @nanonets/graft && graft init --agents claude
   -（如果 Graft 安装失败，跳过即可 — EricStack 不依赖 Graft）
6. 运行 /estack 确认安装成功
7. 运行 /estack-upgrade 升级到最新版本（每次更新后）
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

## 卸载 | Uninstall

完全移除 EricStack：

```markdown
帮我卸载 EricStack：
1. 运行：bash ~/EricStack/.loopx/bin/uninstall-ericsstack.sh
2.（可选）运行：rm -rf ~/EricStack
```

这会从 `~/.claude/skills/` 删除全部 46 个 skills，并解除 LoopX 运行时的链接。

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
/estack                # 主入口 — 显示 banner 并路由到正确技能
/erics-loop-router     # 查看全部 46 个技能和路由规则
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
| `/erics-process-acceptance-pipeline` | Run full APS pipeline: parse → DRY check → generate → run → mutate | 完整 APS 验收管道：解析→DRY检查→生成→运行→变异测试 |
| `/erics-process-mutation` | Source code mutation testing: prove tests are real | 源码变异测试：验证测试有效性 |
| `/erics-process-trim-cot-leakage` | Remove chain-of-thought leakage from docs | 去除文档中的思维链泄漏 |
| `/erics-ability-grill-me` | Stateless interview: loose idea → committable decisions | 无状态访谈：模糊想法 → 可承诺决策 |
| `/erics-ability-grill-with-docs` | Stateful grilling: reads code, writes `CONTEXT.md` + ADRs | 状态化质询：读代码库、写入 CONTEXT.md 与 ADR |
| `/erics-ability-wayfinder` | Multi-session map: grilling inside decision tickets | 多会话编排：在决策工单里运行质询 |

**查看全部 46 个技能 / See all 46 skills：** [`.loopx/erics-skills-index.md`](.loopx/erics-skills-index.md)

---

## Architecture | 架构

```
EricStack/
├── .loopx/
│   ├── skills/
│   │   ├── erics-loop-router/      # Skill router / 技能路由器
│   │   ├── erics-process-* (×13)  # Discipline skills / 纪律技能
│   │   └── erics-ability-* (×27)  # Action skills / 能力技能
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
| `docs/LLM_WIKI_TUTORIAL.md` | 中文 | LLM Wiki knowledge base guide / LLM Wiki 知识库使用教程 |
| `docs/APS_INTEGRATION.md` | 中文 | APS integration plan / APS 整合方案 |
| `INTEGRATION.md` | 中文 | Full integration plan / 完整整合方案 |
| `.loopx/llm-wiki-integration.md` | 中文 | LLM Wiki integration guide / LLM Wiki 整合指南 |

---

## 相关项目

EricStack 整合借鉴了以下项目：

| 项目 | 链接 | 借鉴内容 |
|---|---|---|
| **PR Agent** | [The-PR-Agent/PR-Agent](https://github.com/The-PR-Agent/PR-Agent) | 增量审查、PR Compression、自我反思、可配置工具 |
| **Graft** | [NanoNets/Graft](https://github.com/NanoNets/Graft) | 代码知识图谱、调用链追踪、高 token 效率的代码理解 |
| **GStack** | [garrytan/gstack](https://github.com/garrytan/gstack) | 上游 ability skill 来源 |
| **LoopX** | [huangruiteng/loopx](https://github.com/huangruiteng/loopx) | Skill 系统架构和 slash command 协议 |

---

## 关于作者

**ERIC** — AI技术专家，专注于人工智能和自动化工具的研究与应用

### 🔗 联系方式与平台

| 平台 | 链接 |
|---|---|
| 📧 邮箱 | gyc567@gmail.com |
| 🐦 Twitter | [@EricBlock2100](https://twitter.com/EricBlock2100) |
| 💬 微信 | 360369487 |
| 📱 Telegram | https://t.me/fatoshi_block |
| 📢 Telegram 频道 | https://t.me/cryptochanneleric |
| 👥 加密情报 TG 群 | https://t.me/btcgogopen |
| 🎥 YouTube 频道 | https://www.youtube.com/@0XBitFinance |
| 🌐 个人技术博客 | https://www.topdigg.com/ |
| 📖 公众号 | 比特财商（微信公众号）|

---

## License | 许可证

MIT License — see [`LICENSE`](LICENSE)
