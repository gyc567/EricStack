# EricStack 完整使用教程

> 本教程面向希望用 EricStack 提升工程质量的团队和个人开发者。
> 教程基于 v0.1.0，发布日期 2026-08-15。

---

## 目录

1. [概念入门](#1-概念入门)
   - [1.4 LoopX 与 EricStack 的关系](#14-loopx-与-ericsstack-的关系)
2. [路由系统：如何找到正确的技能](#2-路由系统如何找到正确的技能)
3. [纪律技能详解](#3-纪律技能详解)
4. [能力技能详解](#4-能力技能详解)
5. [知识库使用](#5-知识库使用)
6. [自动更新与版本管理](#6-自动更新与版本管理)
7. [自定义与贡献](#7-自定义与贡献)
8. [故障排查](#8-故障排查)

---

## 1. 概念入门

### 1.1 EricStack 是什么

EricStack 是一个基于 **LoopX** 的工程循环系统。它提供 38 个技能（skills），覆盖工程生命周期的每个环节：

```
想法 → 计划 → 审查 → 代码 → 发版 → 回顾 → 知识沉淀
  ↑                                              ↓
  └────────────── 上下文保存与恢复 ───────────────┘
```

### 1.2 两个技能层级

| 层级 | 命名模式 | 数量 | 本质 |
|---|---|---|---|
| **纪律（Process）** | `erics-process-*` | 13 | 无论你想不想做，都应该做 |
| **能力（Ability）** | `erics-ability-*` | 24 | 你选择做的时候，有工具支撑 |

**纪律技能**确保工程质量，**能力技能**帮你执行具体工作。

### 1.3 核心理念

**1. Boil the Ocean（做完整的事）**

AI 让边际成本趋近于零，所以做完整的事情是目标。不要只写 happy path 测试，不要只做部分审查。当你知道完整事情是什么的时候，不要偷懒。

**2. 持续积累的知识（Compounding Knowledge）**

每个决策、每次审查、每次讨论，都应该沉淀为 wiki 页面，而不是随 session 消失。知识应该是 compounding 的，不是一次性的。

**3. 闭环循环（Closed Loops）**

每个技能都是一个闭环：有输入、有过程、有输出、有验证。没有闭环的流程是无效的。

### 1.4 LoopX 与 EricStack 的关系

EricStack 是跑在 **LoopX** 平台上的工程技能集合。两者定位不同：

| 维度 | `/loopx` | `/estack` |
|---|---|---|
| **层级** | LoopX 框架层 | EricStack 应用层 |
| **用途** | 目标管理 + 生命周期 | 技能路由 + banner 展示 |
| **持久化** | goal / todo / quota 跨 session | 仅当前 session 技能路由 |
| **触发方式** | 长期目标、项目级任务 | 快速任务、不知道用哪个 skill |
| **是否需要 goal** | 是 | 否 |

**典型使用场景：**

```
# 场景 1：不知道该用什么技能
/estack
→ 描述需求："帮我 review 这个 PR"
→ 路由到 erics-process-code-review

# 场景 2：启动目标驱动的会话
/loopx auto-research 审计下所有代码
→ LoopX 创建 goal，建立 todo，持久化状态
→ agent 内部调用具体 skill 执行任务
→ /loopx refresh-state 更新进度

# 场景 3：日常工程任务（不需要 LoopX goal）
/erics-ability-investigate           # debug
/erics-process-code-review           # review
/erics-process-acceptance-pipeline run features/**/*.feature  # APS 管道
```

**简单说：** `/loopx` 管"做什么项目的什么目标"，`/estack` 管"这个任务用哪个 skill"。

---

## 2. 路由系统：如何找到正确的技能

### 2.1 使用路由技能

当你不知道该用什么技能时：

```
你：/erics-loop-router
    "帮我 review 这个 PR"

→ erics-process-code-review —纪律优先：coverage、prose、invariant 全面审查
```

### 2.2 路由规则

| 任务 | 应该用的技能 | 原因 |
|---|---|---|
| Review PR | `erics-process-code-review` | 纪律优先，覆盖完整性 |
| Plan 一个功能 | `erics-ability-plan-eng-review` | 架构 + 数据流 + 边界情况 |
| Debug 错误 | `erics-ability-investigate` | 四阶段调试流程 |
| 安全审计 | `erics-ability-cso` | OWASP + STRIDE |
| 代码质量检查 | `erics-ability-health` | 类型检查、lint、测试、死代码 |
| 性能回归 | `erics-ability-benchmark` | Core Web Vitals |
| 头脑风暴想法 | `erics-ability-office-hours` | YC 六问 |
| 模糊需求 → Spec | `erics-ability-spec` | 五阶段精确化 |
| 写文档 | `erics-process-doc-standards` | 文档放置 + corpus 纪律 |
| 优化 prose | `erics-process-prose-standard` | 完整性 + 编辑纪律 |
| 去除思维链泄漏 | `erics-process-trim-cot-leakage` | CoT 泄漏检测 |
| 发现简化候选项 | `erics-process-find-simplifications` | 死代码、过度建设 |
| 做回顾 | `erics-ability-retro` | 周迭代 + shipping streaks |
| 保存进度 | `erics-ability-context-save` | git 状态 + 决策 + 剩余工作 |
| 恢复进度 | `erics-ability-context-restore` | 跨 workspace 恢复 |
| 完整 APS 验收管道 | `erics-process-acceptance-pipeline` | 解析→DRY检查→生成→运行→变异测试 |
| Gherkin 验收测试 | `erics-ability-bdd` | 编写 .feature + 解析为 JSON IR |
| 源码变异测试 | `erics-process-mutation` | 验证测试真正有效（存活率 <5%） |
| 测试运行适配 | `erics-ability-test-runner` | 框架适配器（JUnit5/Pytest/Behave 等） |

### 2.3 路由例外规则

- **同时适用时：** 写作/审查类任务优先 `erics-process-*`，行动类优先 `erics-ability-*`
- **不确定时：** 使用 `/erics-loop-router` 获取推荐
- **跨类别时：** 选择最具体的（范围最窄的）技能

---

## 3. 纪律技能详解

### 3.1 `erics-process-code-review`

**用途：** 对 PR 做全面纪律审查，确保 coverage、prose、invariant 三个维度都达标。

**触发：** `/erics-process-code-review` 或在 PR review 时调用

**审查维度：**
- **Coverage（覆盖度）** — 测试是否覆盖了所有路径和边界情况
- **Prose（文风）** — 代码注释、PR 描述、文档是否清晰准确
- **Invariant（不变式）** — 关键断言和边界条件是否正确

**输出：** 结构化的 review 报告，列出每个维度的发现。

### 3.2 `erics-process-find-simplifications`

**用途：** 发现可以简化的地方——死代码、重复逻辑、过度建设的表面。

**触发：** `/erics-process-find-simplifications`

**找什么：**
- 没有生产 consumer 的 public 方法、event、config
- 测试或文档唯一依赖的行为（而非 load-bearing）
- 重复表示同一事实的两套 representation
- 手写代码而非使用已有依赖

**输出：** Agent Notes（证据支持的简化建议）

### 3.3 `erics-process-prose-standard`

**用途：** 确保所有文字输出（PR 描述、commit message、文档、注释）都清晰、完整、专业。

**触发：** `/erics-process-prose-standard`

**规则：**
- Lead with the point — 先说结论和影响
- Be concrete — 命名文件、行号、命令、真实数字
- Tie to outcomes — 连接用户实际看到的变化
- Avoid filler — 不说废话、不做过度乐观的预测

### 3.4 `erics-process-trim-cot-leakage`

**用途：** 检测并去除文档中的思维链（Chain-of-Thought）泄漏。

**触发：** `/erics-process-trim-cot-leakage`

**找什么：**
- 推理过程写在最终文档中
- "I think..." / "The model reasoned..." 等痕迹
- 中间步骤、未决定论据留在结论文档里

### 3.5 `erics-process-doc-standards`

**用途：** 文档写作标准与 corpus 审计。

**触发：** `/erics-process-doc-standards`

### 3.6 其他纪律技能

| 技能 | 用途 |
|---|---|
| `erics-process-doc-site-sync` | VitePress 文档站同步规则 |
| `erics-process-translate-docs` | 中英双语配对文档工作流 |
| `erics-process-archive-notes` | Agent Note 生命周期管理 |
| `erics-process-pre-push-checks` | 推前最小化检查 |
| `erics-process-merging-stacked-prs` | GitHub PR stack 落地流程 |
| `erics-process-record-browser-gif` | UI 演示 GIF 录制 |

---

## 4. 能力技能详解

### 4.1 `erics-ability-plan-eng-review`

**用途：** 工程计划审查，从架构、数据流、边界情况角度锁定计划。

**触发：** `/erics-ability-plan-eng-review`

**五阶段：**
1. 理解需求（用户想达成什么？）
2. 评估方案（架构选择、数据流）
3. 边界情况（错误处理、并发、边界输入）
4. 依赖关系（内部模块、外部服务）
5. 锁定计划（给出可执行的步骤）

**输出：** 结构化工程评审报告，可作为代码实现的依据。

### 4.2 `erics-ability-plan-ceo-review`

**用途：** CEO 级别的产品视角审查，找到 10-star 产品。

**触发：** `/erics-ability-plan-ceo-review`

**六问：**
1. 用户是谁？具体场景是什么？
2. 用户现在的痛点是什么？（不用你的方案时）
3. 什么是用户真正想完成的job-to-be-done？
4. 为什么现有方案不够好？
5. 什么是你的方案能做到而其他方案做不到的？
6. 什么是这个方案最危险的假设？

### 4.3 `erics-ability-investigate`

**用途：** 四阶段调试流程，系统化地定位和修复 bug。

**触发：** `/erics-ability-investigate` 或 `/debug this error`

**四阶段：**
1. **Investigate** — 收集证据，还原错误现场
2. **Analyze** — 分析证据，列出竞争假设
3. **Hypothesize** — 提出最可能的根因假设
4. **Implement** — 实施修复，验证根因

### 4.4 `erics-ability-cso`

**用途：** 安全审计。

**触发：** `/cso` 或 `/cso --infra` / `/cso --code`

**扫描维度：**
- Secrets in git history
- Missing auth boundaries
- SQL / command injection
- Dependency CVEs
- CI/CD security

### 4.5 `erics-ability-health`

**用途：** 代码质量仪表盘。

**触发：** `/health`

**评分维度：**
- Type checker（类型检查）
- Linter（代码风格）
- Tests（测试覆盖）
- Dead code（死代码）
- Shell scripts（脚本质量）

### 4.6 `erics-ability-autoplan`

**用途：** 一句话触发 CEO→设计→工程→DX 全链路审查。

**触发：** `/autoplan`

自动依次运行：
1. `plan-ceo-review`（CEO 视角）
2. `design-consultation`（设计系统）
3. `plan-eng-review`（工程视角）
4. `devex-review`（开发者体验）

### 4.7 `erics-ability-spec`

**用途：** 将模糊需求转化为可执行的 spec。

**触发：** `/spec` 或 `/spec this out`

**五阶段：**
1. Clarify intent — 明确用户真正想要的
2. Define scope — 确定边界和排除项
3. Specify behavior — 精确描述行为
4. Identify edge cases — 列出边界情况
5. Write acceptance criteria — 给出验收标准

### 4.8 `erics-ability-retro`

**用途：** 周迭代回顾。

**触发：** `/retro`

**包含：**
- Per-person breakdown（每人这周做了什么）
- Shipping streaks（连续发版天数）
- Wins & challenges（做得好 & 需要改进）
- Action items（下周改进项）

### 4.9 其他能力技能

| 技能 | 用途 |
|---|---|
| `erics-ability-benchmark` | 性能回归检测 |
| `erics-ability-benchmark-models` | 跨模型基准对比 |
| `erics-ability-office-hours` | YC Office Hours 六问 |
| `erics-ability-context-save` | 保存工作上下文 |
| `erics-ability-context-restore` | 从保存的上下文恢复 |
| `erics-ability-upgrade` | 检查更新 |
| `erics-ability-design-consultation` | 设计系统构建 |
| `erics-ability-devex-review` | 开发者体验审查 |
| `erics-ability-graft` | 代码结构图谱、调用链追踪（需要 Node.js） |

### 4.10 Graft 代码理解工具

Graft 是 EricStack 的可选依赖，用于快速理解代码结构。

**安装：**
```bash
npm install -g @nanonets/graft
graft init --agents claude
```

**与 EricStack 协同使用：**

| 场景 | 协同方式 |
|---|---|
| Review 大型 PR | `graft map` 了解项目结构 + code review |
| 调试 bug | `graft callers <func>` 找所有调用者，理解影响范围 |
| 理解新代码 | `graft skeleton <file>` 生成文件摘要 |
| 架构评审 | `graft viz` 查看依赖图谱 |

---

## 5. 知识库使用

### 5.1 在 llm_wiki App 中使用

1. 下载 [llm_wiki releases](https://github.com/nashsu/llm_wiki/releases)
2. `File → Open Project` → 选择 `EricStack` 目录
3. 在 Settings 中配置 LLM provider
4. 开始向 chat 提问

**Ingest（摄入）：** 当你向 chat 提供新内容时，LLM 会自动：
- 创建/更新对应的 entity 或 concept 页面
- 更新 `index.md`
- 追加到 `log.md`

**Query（查询）：** 当你向 chat 提问时：
- LLM 搜索 `.loopx/wiki/` 下的相关页面
- 合成带引用的回答
- 如果发现有知识空白，可将结果存入 `queries/`

### 5.2 手动管理知识库

```
.loopx/wiki/
├── index.md      # 总索引
├── overview.md   # 项目概览
├── log.md       # 操作日志（追加）
├── concepts/    # 概念页
├── entities/    # 决策记录
├── sources/     # 源文档
└── queries/     # Q&A
```

**命名规范：**
- Wiki 页面：`kebab-case.md`
- Agent Notes：`YYYY-MM-DD-topic.md`
- 内部链接：`[[page-name]]`

### 5.3 Lint（健康检查）

定期检查（手动或让 LLM 做）：

1. 孤立页面（无入链）→ 是否还需要？
2. 失效的 wikilink → 更新引用
3. 过期内容（>90 天未更新）→ 是否还准确？
4. 重复主题 → 合并

---

## 6. 自动更新与版本管理

### 6.1 版本策略

EricStack 采用 **SemVer**：`v<MAJOR>.<MINOR>.<PATCH>`

每个 tag 对应一个 release commit。

### 6.2 更新检查

**方式 A（推荐）：自动检查**
`erics-loop-router` 每次路由决策前自动检查，有新版本才提示。

**方式 B：手动检查**

```bash
# 检查 EricStack 版本
cat .loopx/VERSION

# 检查上游技能源更新
bash .loopx/bin/sync-skills.sh --check

# 同步上游（当有更新时）
bash .loopx/bin/sync-skills.sh --execute
```

### 6.3 发布新版本

```bash
# 1. 更新技能或内容
git commit -m "feat: add new skill"

# 2. 打版本 tag
git tag -a v0.2.0 -m "Release v0.2.0: new skill"
git push origin v0.2.0

# 3. VERSION 文件也更新（随 commit）
```

### 6.4 升级已安装的 EricStack

```bash
# 1. 检查更新
bash .loopx/bin/sync-skills.sh --check

# 2. 拉取最新
git pull origin main

# 3. 如有上游技能更新
bash .loopx/bin/sync-skills.sh --execute
```

---

## 7. 自定义与贡献

### 7.1 添加新技能

1. 在 `.loopx/skills/erics-ability/` 或 `.loopx/skills/erics-process/` 下创建目录
2. 创建 `SKILL.md`，包含 frontmatter：
   ```yaml
   ---
   name: erics-ability-my-skill
   description: What this skill does.
   triggers:
     - my skill
     - trigger phrase
   ---
   ```
3. 添加技能逻辑
4. 更新 `.loopx/erics-skills-index.md`
5. Commit 并 push

### 7.2 修改现有技能

技能定义在 `.loopx/skills/` 下，直接编辑对应的 `SKILL.md`。

**建议：** 修改前先运行 `/erics-ability-health` 确认项目状态健康。

### 7.3 路由表更新

如果新增了技能，需要在 `erics-loop-router/SKILL.md` 的路由表中添加条目。

---

## 8. 故障排查

### 技能不触发？

检查 frontmatter 的 `triggers` 字段是否包含你的触发词。

### 路由到错误的技能？

在 `/erics-loop-router` 的路由表中找到对应规则，直接调用目标技能。

### 更新检查失败？

```bash
# 检查网络
git ls-remote --tags https://github.com/gyc567/EricStack.git

# 查看本地 VERSION
cat .loopx/VERSION
```

### llm_wiki 找不到知识库？

确保打开的是 `EricStack` 根目录，而不是 `.loopx/`。

### 技能运行报错？

每个技能只使用 Read、Write、Bash、Grep 工具。如果报错，检查是否有特殊工具依赖。

---

## 附录

### A. 完整技能列表

见 [`.loopx/erics-skills-index.md`](../.loopx/erics-skills-index.md)

### B. 相关文档

| 文档 | 说明 |
|---|---|
| `INTEGRATION.md` | 双库整合方案完整说明 |
| `docs/APS_INTEGRATION.md` | APS 整合方案（Acceptance Pipeline Specification） |
| `.loopx/llm-wiki-integration.md` | LLM Wiki 整合说明 |
| `.loopx/erics-mapping.md` | 路径锚点映射 |

### C. 外部资源

- [LLM Wiki (Karpathy)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [llm_wiki App](https://github.com/nashsu/llm_wiki)
- [LoopX 文档](https://github.com/LoopX)

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
