# EricStack LoopX 双库整合方案

> 状态：已审计优化 v2 | 日期：2026-08-15
>
> 目标：将 DeepSeek Harness 流程纪律规范（`erics-process-*`）与 EricStack 工程生产力技能（`erics-ability-*`）整合进 EricStack LoopX，形成覆盖"写对"到"做对"的完整 engineering loop。

---

## 一、源库分析

### 1.1 DeepSeek Harness（来源：`deepseek-ai/deepseek-harness`）

11 个 skill，定位为**流程纪律规范**——管"写什么"、"怎么验证"。

| 本地名称 | 原始名称 | 纪律职责 | CLI 依赖 |
|---|---|---|---|
| `erics-process-archive-notes` | dsh-archive-agent-notes | Agent Note 生命周期管理 | 无 |
| `erics-process-code-review` | dsh-code-review | PR 纪律审查（coverage、prose、invariant） | 无 |
| `erics-process-doc-standards` | dsh-doc-standards | 文档写作标准与 corpus 审计 | 无 |
| `erics-process-find-simplifications` | dsh-find-simplifications | 简化候选项发现与 Agent Note 合并 | 无 |
| `erics-process-merging-stacked-prs` | dsh-merging-stacked-prs | GitHub 官方 PR stack 落地流程 | `gh` |
| `erics-process-pre-push-checks` | dsh-pre-push-checks | 推前最小化检查选择策略 | `pnpm`（如项目使用） |
| `erics-process-prose-standard` | dsh-prose-standard | prose 完整性与编辑纪律 | 无 |
| `erics-process-trim-cot-leakage` | dsh-trim-cot-leakage | CoT 泄漏检测与修剪 | 无 |
| `erics-process-doc-site-sync` | dsh-doc-site-sync | VitePress 文档站同步规则 | ⚠️ 仅 VitePress 项目 |
| `erics-process-translate-docs` | dsh-translate-docs | 中英双语配对文档工作流 | ⚠️ 仅 pnpm 项目 |
| `erics-process-record-browser-gif` | record-browser-gif | UI 演示 GIF 录制与发布 | ⚠️ 需浏览器环境 |

### 1.2 EricStack Ability（来源：`garrytan/gstack`，49 个 skill）

定位为**工程生产力动作**——管"做什么"、"怎么做"。

**关键前提：本机未安装 gstack CLI，所有 `$B` 前置命令全部失效。** 导入时必须提取 skill body 并去掉 gstack-specific preamble。

#### 可导入性分级

| 级别 | 标准 | Skills |
|---|---|---|
| **A级（body 干净）** | body 只有 Read/Write/Grep/Bash，preamble 不含 `$B` 调用 | `plan-ceo-review`、`plan-eng-review`、`plan-design-review`、`plan-devex-review`、`autoplan`、`design-consultation`、`devex-review`、`cso`、`retro`、`health`、`benchmark`、`benchmark-models`、`investigate` |
| **B级（需剥离 preamble）** | body 可用，但 preamble 有 gstack CLI 调用 | `office-hours`、`spec`、`context-save`、`context-restore`、`learn`、`ship`、`canary`、`document-generate`、`document-release`、`setup-deploy`、`gstack-upgrade`、`plan-tune` |
| **C级（暂跳过）** | body 或 preamble 强依赖 gstack daemon、`$B` 交互、browse client、iOS 工具 | `browse`、`qa`、`qa-only`、`skillify`、`open-gstack-browser`、`setup-browser-cookies`、`pair-agent`、`ios-*`、`land-and-deploy`、`scrape`、`design-review`、`design-shotgun`、`design-html`、`review`、`investigate`（有 freeze hook）、`freeze`、`guard`、`careful`、`codex`、`diagram`、`make-pdf`、`sync-gbrain`、`setup-gbrain`、`supabase`、`office-hours`、`spec`、`context-save` |

> **说明**：`investigate` 在 A 级是因为它的 body 逻辑（4阶段调试流程）本身很干净，PreToolUse freeze hook 在导入时会删除。

---

## 二、品牌命名规范

### 2.1 统一命名规则

| 维度 | 规则 |
|---|---|
| **EricStack LoopX 自身** | `LoopX`（首字母大写），`loopx`（CLI 命令） |
| **流程纪律 skill** | `erics-process-<function>`（如 `erics-process-code-review`） |
| **工程能力 skill** | `erics-ability-<function>`（如 `erics-ability-plan-eng-review`） |
| **顶级路由 skill** | `erics-loop-router` |
| **Skill 索引文件** | `erics-skills-index.md` |
| **整合文档** | `INTEGRATION.md`（根目录）、`.loopx/erics-mapping.md`（路径映射） |
| **禁用词** | `dsh`、`gstack`、`harness`、`GStack` 禁止作为目录名或文件名出现 |

### 2.2 目录结构

```
EricStack/
├── .loopx/
│   ├── registry.json
│   ├── goals/ericstack-goal/
│   ├── skills/
│   │   ├── erics-loop-router/         # 顶级路由 skill
│   │   │   └── SKILL.md
│   │   │
│   │   ├── erics-process/             # 流程纪律规范（来源 DeepSeek Harness）
│   │   │   ├── erics-process-archive-notes/
│   │   │   ├── erics-process-code-review/
│   │   │   ├── erics-process-doc-standards/
│   │   │   ├── erics-process-find-simplifications/
│   │   │   ├── erics-process-merging-stacked-prs/
│   │   │   ├── erics-process-pre-push-checks/
│   │   │   ├── erics-process-prose-standard/
│   │   │   ├── erics-process-trim-cot-leakage/
│   │   │   ├── erics-process-doc-site-sync/   ⚠️ [requires: vitepress]
│   │   │   ├── erics-process-translate-docs/  ⚠️ [requires: pnpm project]
│   │   │   └── erics-process-record-browser-gif/ ⚠️ [requires: browser]
│   │   │
│   │   └── erics-ability/             # 工程能力（来源 gstack）
│   │       ├── erics-ability-plan-ceo-review/
│   │       ├── erics-ability-plan-eng-review/
│   │       ├── erics-ability-plan-design-review/
│   │       ├── erics-ability-plan-devex-review/
│   │       ├── erics-ability-cso/
│   │       ├── erics-ability-devex-review/
│   │       ├── erics-ability-retro/
│   │       ├── erics-ability-benchmark/
│   │       ├── erics-ability-benchmark-models/
│   │       ├── erics-ability-investigate/
│   │       ├── erics-ability-office-hours/    [剥离 preamble]
│   │       ├── erics-ability-spec/            [剥离 preamble]
│   │       ├── erics-ability-context-save/    [剥离 preamble]
│   │       ├── erics-ability-context-restore/ [剥离 preamble]
│   │       ├── erics-ability-learn/           [剥离 preamble]
│   │       ├── erics-ability-ship/            [剥离 preamble]
│   │       ├── erics-ability-canary/          [剥离 preamble]
│   │       ├── erics-ability-document-generate/ [剥离 preamble]
│   │       ├── erics-ability-document-release/ [剥离 preamble]
│   │       ├── erics-ability-setup-deploy/    [剥离 preamble]
│   │       ├── erics-ability-gstack-upgrade/  [剥离 preamble + 改名为 erics-upgrade]
│   │       ├── erics-ability-plan-tune/
│   │       ├── erics-ability-autoplan/
│   │       ├── erics-ability-design-consultation/
│   │       └── erics-ability-health/
│   │
│   ├── erics-skills-index.md          # 所有 skill 的触发词索引
│   └── erics-mapping.md               # 路径锚点映射（dsh 原始路径 → 本地路径）
│
└── INTEGRATION.md                     # 本文件
```

---

## 三、导入技术规范

### 3.1 erics-process（来源 DeepSeek Harness）

#### 路径锚点重写规则

原始 deepseek-harness 路径引用分三类，改写如下：

| 原始路径 | 含义 | 改写方案 |
|---|---|---|
| `../../../AGENTS.md` | 根目录工程规范 | `../../AGENTS.md`（若存在）或 `INTEGRATION.md#conventions` |
| `../../notes/README.md` | Agent Note 规则 | `.loopx/erics-mapping.md#agent-notes` |
| `../../../docs/AGENTS.md` | 文档规范 | `.loopx/erics-mapping.md#doc-standards` |

**操作：** 用 sed 批量替换 skill 正文中的相对路径引用，同时在 `.loopx/erics-mapping.md` 记录原始路径对照表。

### 3.2 erics-ability（来源 gstack）

#### Preamble 剥离规则

gstack SKILL.md 结构：
```markdown
---
[name: xxx, triggers, allowed-tools]
---
<!-- AUTO-GENERATED ... -->

## Preamble (run first)     ← 删除此段（约 80-120 行 Bash）
...gstack CLI 调用...

## Skill Invocation / When to invoke this skill  ← 保留此行之后
[Skill body 保留]
```

**提取算法：**
1. 找到第一个 `## ` 二级标题（`## Preamble` 或 `## Skill Invocation` 或 `## When to invoke`）
2. 找到第二个 `## ` 二级标题（下一个 section）
3. 删除两个标记之间的所有内容（第一个 `## ` 标题行也删除）
4. 保留从第二个 `## ` 标题开始到文件末尾的内容

**`$B` 命令替换表：**

| gstack `$B` 命令 | 等价实现 |
|---|---|
| `$B goto <url>` | `Bash curl` 或 WebFetch |
| `$B html` | WebFetch |
| `$B click` | 跳过（需要 daemon） |
| `$B skill run <name>` | 跳过（需要 gstack skill runner） |

**PreToolUse Hook 删除：** 所有 `hooks: PreToolUse` 块整体删除，不替换。

**gbrain context_queries 保留但不执行：** `gbrain:` 块在无 gbrain 服务时静默降级，skill 仍可用本地信息运行。

---

## 四、冲突与重叠解决

### 4.1 功能定位区分

| 场景 | 路由到 | 理由 |
|---|---|---|
| "帮我 review 这个 PR" | `erics-process-code-review` | 纪律优先：coverage、prose、invariant |
| "帮我检查 diff" | `erics-ability-review`（如有） | 生产力视角：diff 分析、安全检查 |
| "帮我 debug 这个 error" | `erics-ability-investigate` | 流程纪律：四阶段（investigate/analyze/hypothesize/implement） |
| "帮我 plan 这个 feature" | `erics-ability-plan-eng-review` | 工程规划锁定：架构、数据流、边界 |
| "帮我写文档" | `erics-process-doc-standards` | 写作纪律优先 |
| "帮我优化这段 prose" | `erics-process-prose-standard` | 文风编辑纪律 |
| "帮我 trim 一下这段文字" | `erics-process-trim-cot-leakage` | CoT 泄漏检测 |

### 4.2 同类 skill 并存规则

当两个 skill 功能近似但视角不同时，两者并存，不合并：

- `erics-process-code-review`（纪律视角）≠ `erics-ability-review`（生产力视角）
- `erics-process-doc-standards`（结构/放置）≠ `erics-process-prose-standard`（文风/内容）
- `erics-ability-cso`（OWASP/STRIDE 威胁建模）完全独立于其他所有 skill

---

## 五、实施路线图

### 阶段 1：erics-process 基础（7 个可直接导入）

```
1.1 复制 erics-process-archive-notes ~ erics-process-trim-cot-leakage（7个）
1.2 路径锚点重写（sed 批量替换 + erics-mapping.md）
1.3 验证：每个 skill 的 SKILL.md 可被 Skill 工具索引
```

### 阶段 2：erics-process 扩展（3 个条件 skill）

```
2.1 erics-process-doc-site-sync → 标记 [requires: vitepress]
2.2 erics-process-translate-docs → 标记 [requires: pnpm]
2.3 erics-process-record-browser-gif → 标记 [requires: browser + ffmpeg]
```

### 阶段 3：erics-ability A 级（13 个 body 干净 skill）

```
3.1 下载所有 A 级 skill SKILL.md
3.2 提取 body（去掉 preamble）
3.3 $B 调用替换
3.4 重命名（加 erics-ability- 前缀）
3.5 写入 .loopx/skills/erics-ability/
```

### 阶段 4：erics-ability B 级（12 个需 preamble 剥离）

```
4.1 下载所有 B 级 skill SKILL.md
4.2 自动剥离 preamble
4.3 替换不可用命令
4.4 health / retro / benchmark 等完整保留 body
```

### 阶段 5：路由层 + 索引

```
5.1 写入 erics-loop-router skill
5.2 写入 erics-skills-index.md
5.3 更新 .loopx/registry.json 的 skill 索引
```

### 阶段 6：验证

```
6.1 触发词路由验证
6.2 路径锚点验证（erics-mapping.md 完整性）
6.3 gstack preamble 剥离验证（无 gstack CLI 调用残留）
6.4 LoopX 状态一致性验证
```

### 阶段 7：文档

```
7.1 完成 INTEGRATION.md
7.2 写 erics-mapping.md
```

---

## 六、验证与测试规程

### 6.1 路由验证（每次 skill 写入后执行）

**目的：** 确认 Skill 工具能正确索引新 skill，且触发词能区分相似 skill。

```bash
# 验证 erics-process 系列被索引
ls .loopx/skills/erics-process/*/SKILL.md | wc -l
# 期望：10 或 11

# 验证 erics-ability 系列被索引
ls .loopx/skills/erics-ability/*/SKILL.md | wc -l
# 期望：25

# 验证无残留 gstack preamble
rg -l 'gstack-update-check|gstack-config|gstack-session-kind|gstack-slug' .loopx/skills/erics-ability/ || echo "clean"
# 期望输出："clean"

# 验证无禁用品牌名
rg -l 'dsh-|gstack-|GStack' .loopx/skills/ || echo "clean"
# 期望输出："clean"
```

### 6.2 路径锚点验证

```bash
# 验证 deepseek-harness 原始路径已清理
rg 'deepseek-harness|harness/' .loopx/skills/erics-process/ || echo "clean paths"

# 验证 erics-mapping.md 记录了所有重写的锚点
rg '^\|' .loopx/erics-mapping.md | wc -l
# 期望：≥ 10 行（每个被重写的路径占一行）
```

### 6.3 LoopX 状态验证

```bash
# 验证 LoopX 能发现新的 skills
loopx status --format json 2>&1 | python3 -c "import json,sys; d=json.load(sys.stdin); print('goals:', d.get('goal_count')); print('registry:', d.get('registry','')[:60])"

# 验证 quota 仍然 eligible
loopx --format json quota should-run --goal-id ericstack-goal --agent-id claude-code-ericstack-01 --runtime-profile codex_cli 2>&1 | python3 -c "import json,sys; d=json.load(sys.stdin); print('should_run:', d.get('should_run')); print('quota:', d.get('quota',{}).get('state'))"
```

### 6.4 功能抽样验证

每个冲突对挑一个真实任务验证路由正确：

| 测试用例 | 期望路由 | 验证方式 |
|---|---|---|
| "帮我 review 这个 PR" | `erics-process-code-review` | Skill 工具触发 `name: erics-process-code-review` |
| "帮我 debug 这个 error: connection refused" | `erics-ability-investigate` | Skill 工具触发四阶段调试流程 |
| "帮我 plan 这个 feature" | `erics-ability-plan-eng-review` | 触发架构/数据流锁定流程 |

### 6.5 上游同步验证

每 30 天检查一次上游更新：

```bash
# 检查 DeepSeek Harness skill 更新
gh api repos/deepseek-ai/deepseek-harness/contents/.agents/skills --jq '.[].name'

# 检查 gstack skill 更新
gh api repos/garrytan/gstack/contents --jq '.[].name' | grep -v '^\.'

# 对比本地已导入版本，记录到 erics-mapping.md 的 changelog 段
```

---

## 七、风险与缓解

| 风险 | 级别 | 缓解措施 |
|---|---|---|
| gstack preamble 剥离不干净，残留 `$B` 调用 | **高** | 阶段 3/4 必须执行 `rg -l 'gstack-'` 验证；任何命中立即修复 |
| erics-process 路径锚点重写遗漏 | **中** | erics-mapping.md 记录所有原始路径对照；定期 rg 扫描验证 |
| erics-ability skills 在无 gbrain 环境下功能降级 | **低** | `gbrain:` 块静默降级，不报错；文档说明预期降级行为 |
| C 级 skill 被用户错误触发（依赖不满足） | **中** | 所有 C 级 skill 目录创建但不写 SKILL.md（或写但标记 `[unavailable]`） |
| 上游 gstack 更新导致本地副本过时 | **中** | 30 天一次同步检查；erics-mapping.md 记录版本快照 |

---

## 八、上游版本记录

| 来源 | 版本快照日期 | 原始仓库 commit |
|---|---|---|
| DeepSeek Harness | 2026-08-15 | `master` branch, latest |
| Garry Tan gstack | 2026-08-15 | `main` branch, latest |

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
