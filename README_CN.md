# EricStack

**AI 原生工程循环系统 — 26 个技能，覆盖计划、审查、简化、文档和知识积累。**

> EricStack 将 EricStack 从一个项目转变为一个持续积累的工程智能体。每个决策、每次审查、每次讨论都沉淀为持久的 wiki 页面。每个流程都是闭合循环。

## 什么是 EricStack？

EricStack 是一个基于 LoopX 的工程团队技能系统，提供 **26 个技能**，分为两个层级：

| 层级 | 数量 | 用途 |
|---|---|---|
| `erics-process-*`（纪律） | 11 | 执行标准 — 代码审查、prose 质量、文档、简化 |
| `erics-ability-*`（能力） | 15 | 执行工作流 — 计划、调试、性能基准、回顾 |

技能运行在 Claude Code（或任何兼容 LoopX 的 host）中。技能系统本身无需独立服务器、无需守护进程、无需额外 API key。

## 核心特性

- **26 个生产就绪技能** — 流程纪律 + 工程能力
- **持续积累的知识库** — 由 [llm_wiki](https://github.com/nashsu/llm_wiki) 驱动，每个决策都持久化
- **自动更新检测** — 每次路由决策时检查 EricStack 版本和上游技能源
- **零依赖技能** — 所有技能仅使用 Read、Write、Bash、Grep，无需特殊 CLI
- **品牌纯净** — 已移除所有 `gstack-` / `dsh-` / `deepseek-harness` 引用，统一为 EricStack

## 快速上手

### 1. 克隆

```bash
git clone https://github.com/gyc567/EricStack.git
cd EricStack
```

### 2. 在 llm_wiki 中打开（推荐，用于知识库）

下载 [llm_wiki](https://github.com/nashsu/llm_wiki/releases)，然后：

```bash
# 在 llm_wiki 应用中：File → Open Project → 选择 EricStack 目录
```

### 3. 在 Claude Code 中使用技能

```
/erics-loop-router     # 询问："which skill for this?" — 路由到正确技能
```

或直接调用任何技能：

| 命令 | 功能 |
|---|---|
| `/erics-process-code-review` | 全方位 PR 审查：coverage、prose、invariant |
| `/erics-ability-plan-eng-review` | 架构 + 数据流审查 |
| `/erics-ability-investigate` | 四阶段调试：调查→分析→假设→实施 |
| `/erics-ability-cso` | 安全审计（OWASP Top 10 + STRIDE） |
| `/erics-ability-health` | 代码质量仪表盘：类型检查、lint、测试、死代码 |
| `/erics-ability-benchmark` | 性能回归检测（Core Web Vitals） |
| `/erics-ability-office-hours` | YC 风格六问 |
| `/erics-ability-spec` | 模糊意图 → 五阶段可执行 spec |
| `/erics-ability-retro` | 周迭代回顾（含发版 streaks） |
| `/erics-ability-context-save` | 保存工作上下文：git 状态 + 决策 + 剩余工作 |
| `/erics-ability-context-restore` | 从保存的上下文恢复 |
| `/erics-ability-upgrade` | 检查更新 |
| `/erics-process-find-simplifications` | 发现死代码、过度建设、简化候选项 |
| `/erics-process-prose-standard` | prose 完整性 + 编辑纪律 |
| `/erics-process-trim-cot-leakage` | 去除文档中的思维链泄漏 |

**查看全部 26 个技能：** [`.loopx/erics-skills-index.md`](.loopx/erics-skills-index.md)

## 架构

```
EricStack/
├── .loopx/
│   ├── skills/
│   │   ├── erics-loop-router/      # 技能路由器
│   │   ├── erics-process-* (×11)  # 纪律技能
│   │   └── erics-ability-* (×15)  # 能力技能
│   ├── wiki/                       # LLM Wiki 知识库
│   │   ├── concepts/              # 概念页面
│   │   ├── entities/              # 决策记录
│   │   └── queries/              # Q&A 对
│   ├── sync-state.json            # 上游同步状态
│   ├── VERSION                    # 当前版本
│   └── bin/sync-skills.sh        # 更新检查脚本
└── INTEGRATION.md                  # 完整整合文档
```

## 知识库

EricStack 的知识库遵循 [LLM Wiki](https://github.com/nashsu/llm_wiki) 模式 — 一个持久化、持续积累的 wiki，随项目成长。

```
.loopx/wiki/
├── index.md      # 技能 + 决策 + 文档目录
├── overview.md   # 自动更新的项目概览
├── log.md       # 操作历史（仅追加）
├── concepts/    # 模式、实践、原则
├── entities/    # 决策、人物、特性
└── queries/     # 常见问题与经验证答案
```

## 保持技能更新

```bash
# 检查更新（每次技能路由时自动运行）
bash .loopx/bin/sync-skills.sh --check

# 同步上游技能源（当有更新时）
bash .loopx/bin/sync-skills.sh --execute

# 查看当前 EricStack 版本
cat .loopx/VERSION
```

## 技能命名规范

| 前缀 | 含义 | 使用场景 |
|---|---|---|
| `erics-process-*` | 纪律 / 标准 | 写作、审查、确保质量 |
| `erics-ability-*` | 行动 / 生产力 | 执行特定工作流 |

两者都适用时，写作/审查任务优先使用 `erics-process-*`。

## 许可证

MIT License — 见 [`LICENSE`](LICENSE)
