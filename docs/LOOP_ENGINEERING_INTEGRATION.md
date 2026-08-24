# Loop Engineering 整合方案

> 整合日期：2026-08-21 | 方案版本：v1.0
> 参考：`.loopx/wiki/concepts/loop-engineering.md` + `.loopx/wiki/concepts/acceptance-pipeline.md`
> 文档目标：阐述 Loop Engineering 的完整理论、EricStack 的技能映射、以及实际工作流整合方案

---

## 一、背景与目标

### 1.1 什么是 Loop Engineering

**Loop Engineering** 是结构化 AI Agent 工作流的核心实践——将工程任务组织为一系列**闭合反馈循环**。每个循环有明确的入口、过程、输出和验证步骤。与临时性 prompt 不同，Loop Engineering 产生的循环是**持久的、可组合的、随时间改进的**。

```
一次性的 prompt → LLM 生成内容 → Session 结束 → 知识丢失
Loop Engineering  → 闭合循环 → 每次输出沉淀为 wiki → 知识积累
```

### 1.2 为什么 Loop Engineering 对 AI 工程至关重要

| 问题 | 无 Loop Engineering | 有 Loop Engineering |
|---|---|---|
| 决策追溯 | 聊天记录中找 | wiki page 有完整上下文 |
| 代码审查 | 每次重新设定标准 | `erics-process-code-review` 强制执行 |
| 测试有效性 | 靠人工判断 | `erics-process-mutation` 量化证明 |
| 上下文丢失 | 每次 session 重新开始 | `erics-ability-context-save/restore` 持久化 |
| 需求漂移 | 口头讨论不落地 | `erics-ability-spec` → `.feature` → wiki |

### 1.3 EricStack 是 Loop Engineering 的具体实现

EricStack 将 Loop Engineering 理论落地为 **38 个可执行的技能**，分为两个层级：

- **纪律技能（Process）** — `erics-process-*`：执行标准，确保闭环，无论开发者意愿如何都应该运行
- **能力技能（Ability）** — `erics-ability-*`：在需要时提供工具支撑，执行具体工作流

---

## 二、Loop Engineering 核心概念

### 2.1 循环结构

每个 Skill 都是一个闭合循环，有三层结构：

```
输入（Input）→ 过程（Process）→ 输出（Output）→ 验证（Validation）
                  ↑                              ↓
                  └────── 反馈（Feedback）────────┘
```

**EricStack Skill 的循环约定：**
- **输入**：用户意图（触发词）或显式调用
- **过程**：读取项目上下文 → 执行检查/生成/审查 → 写入产物
- **输出**：Wiki 页面、PR 描述、诊断报告等持久化产物
- **验证**：质量门禁（退出码、分级警告）

### 2.2 知识闭环

```
工程决策 / 审查 / 讨论
    ↓ 写入
.loopx/wiki/
    ↓ 被读取
下一个 Skill 的上下文
    ↓ 产生新决策
.loopx/wiki/ (更新)
```

**闭环依赖的 Skills：**
- `erics-ability-context-save` — 保存当前 git 状态 + 决策 + 剩余工作
- `erics-ability-context-restore` — 从保存的上下文恢复
- `erics-ability-retro` — 周期性回顾，将成果沉淀为 wiki

### 2.3 反馈层级

```
immediate feedback（即时反馈）
  └─ Skill 执行结果、退出码、警告

session feedback（Session 反馈）
  └─ Context save/restore、Agent Notes

project feedback（项目反馈）
  └─ Wiki page 更新、ADR 记录

cross-project feedback（跨项目反馈）
  └─ EricStack 版本更新、skill 同步
```

---

## 三、Skill 分类与 Loop Engineering 对应

### 3.1 纪律技能（Process Skills）与循环阶段

| Skill | 循环阶段 | 验证方式 | 对应 Loop 环节 |
|---|---|---|---|
| `erics-process-code-review` | Review | PR 评论 + 质量门禁 | `→ Review` |
| `erics-process-prose-standard` | Review | Prose lint 结果 | `→ Review` |
| `erics-process-mutation` | Validation | 存活率分级门禁 | `→ Validation` |
| `erics-process-acceptance-pipeline` | Validation | 7 阶段退出码 | `→ Validation` |
| `erics-process-pre-push-checks` | Pre-ship | 选定检查集 | `→ Pre-ship` |
| `erics-process-find-simplifications` | Simplification | 简化候选项列表 | `→ Simplify` |
| `erics-process-trim-cot-leakage` | Documentation | 泄漏率指标 | `→ Documentation` |
| `erics-process-doc-standards` | Documentation | Doc lint | `→ Documentation` |
| `erics-process-archive-agent-notes` | Knowledge | 归档完整性 | `→ Knowledge` |
| `erics-process-doc-site-sync` | Knowledge | 站点同步报告 | `→ Knowledge` |
| `erics-process-merging-stacked-prs` | Ship | Stack merge 状态 | `→ Ship` |
| `erics-process-record-browser-gif` | Ship | GIF 交付物 | `→ Ship` |
| `erics-process-translate-docs` | Documentation | Bilingual 对照检查 | `→ Documentation` |

### 3.2 能力技能（Ability Skills）与工作流

| Skill | 触发场景 | 产物 |
|---|---|---|
| `erics-ability-spec` | 模糊需求 → 精确 spec | `.loopx/wiki/entities/` + issue |
| `erics-ability-bdd` | Spec → Gherkin .feature | `acceptance-pipeline/features/` |
| `erics-ability-test-runner` | 运行 APS 验收测试 | JUnit XML 报告 |
| `erics-ability-plan-eng-review` | Plan → 架构审查 | Review 评论 |
| `erics-ability-plan-ceo-review` | Plan → 产品价值审查 | Review 评论 |
| `erics-ability-investigate` | Debug 问题调查 | 诊断报告 |
| `erics-ability-cso` | 安全审计 | 威胁模型报告 |
| `erics-ability-health` | 代码质量检查 | 质量仪表盘 |
| `erics-ability-benchmark` | 性能测量 | 基准报告 |
| `erics-ability-graft` | 代码结构理解 | Call chain 图 |
| `erics-ability-pr-describe` | PR 完成后描述 | PR 描述 + Labels |
| `erics-ability-pr-changelog` | Release 准备 | CHANGELOG.md |
| `erics-ability-pr-improve` | PR 改进建议 | 优先化建议列表 |
| `erics-ability-pr-ask` | PR 问题回答 | 自由文本答案 |
| `erics-ability-context-save` | Session 切换 | 上下文快照 |
| `erics-ability-context-restore` | Session 恢复 | 恢复确认 |
| `erics-ability-retro` | 周迭代回顾 | 回顾报告 + wiki |
| `erics-ability-office-hours` | 产品头脑风暴 | 六问答案 |
| `erics-ability-design-consultation` | 设计系统咨询 | 设计系统文档 |
| `erics-ability-devex-review` | 开发者体验审计 | DX 报告 |
| `erics-ability-autoplan` | 全链路评审链 | 多视角评审 |
| `erics-ability-upgrade` | 版本检查 | 升级报告 |
| `erics-ability-estack` | 进入 EricStack | Banner + 路由 |

---

## 四、核心工程循环

### 4.1 完整工程循环（Idea → Ship → Knowledge）

```
想法
  ↓
[1] erics-ability-office-hours
    YC 六问，压力测试想法
  ↓
[2] erics-ability-spec
    模糊意图 → 精确 spec
  ↓
[3] erics-ability-plan-ceo-review
    产品价值 + 市场定位
  ↓
[4] erics-ability-plan-eng-review
    架构 + 数据流 + 边缘情况
  ↓
[5] erics-ability-design-consultation
    完整设计系统
  ↓
[6] erics-ability-bdd
    Spec → Gherkin .feature
  ↓
[7] erics-process-acceptance-pipeline
    Spec Lint → Parse → DRY → Generate → Run → Mutate → Diagnose
  ↓
[8] erics-process-code-review
    PR 审查
  ↓
[9] erics-process-pre-push-checks
    Pre-ship 检查
  ↓
[10] erics-process-mutation
    源码级变异测试
  ↓
代码实现
  ↓
[11] erics-ability-pr-describe
    生成 PR 描述
  ↓
[12] erics-process-pre-push-checks
    最终门禁
  ↓
[13] Ship (Merge)
  ↓
[14] erics-ability-retro
    回顾沉淀
  ↓
知识更新 (.loopx/wiki/)
```

### 4.2 Bug 修复循环（Investigate → Fix → Validate）

```
Bug 报告
  ↓
[1] erics-ability-investigate
    四阶段调试：调查 → 分析 → 假设 → 实施
  ↓
[2] erics-process-code-review
    修复方案审查
  ↓
[3] erics-process-pre-push-checks
    回归检查
  ↓
[4] erics-ability-pr-describe
    Bug fix PR 描述
  ↓
[5] Ship (Merge)
```

### 4.3 日常开发循环（Context Loop）

```
每日开始
  ↓
[1] erics-ability-context-restore
    恢复上次的 git 状态 + 决策 + 剩余工作
  ↓
[2] erics-ability-health
    快速质量检查（lint + type + tests）
  ↓
[3] 编码 / 实现
  ↓
[4] erics-process-code-review
    自测后提交审查
  ↓
[5] erics-process-pre-push-checks
    Pre-push 门禁
  ↓
每日结束
  ↓
[6] erics-ability-context-save
    保存上下文（git stash 等效）
```

---

## 五、Skill 组合模式

### 5.1 计划-审查链（Plan Review Chain）

```
erics-ability-spec
    ↓
erics-ability-plan-eng-review
    ↓
erics-ability-plan-ceo-review
    ↓
erics-process-code-review（Plan review 完成后）
```

**触发场景：** "我有一个想法，需要完整评审"

**产物链：** 模糊想法 → Spec → 架构审查 → 产品审查 → 代码审查

### 5.2 测试-验证链（Test Validation Chain）

```
erics-ability-bdd
    ↓
erics-process-acceptance-pipeline
    ↓
erics-process-mutation（补充源码级）
```

**触发场景：** "需要验证测试真正约束了需求"

**产物链：** .feature → JSON IR → 测试入口 → 运行结果 → 变异报告

### 5.3 上下文-回顾链（Context Retro Chain）

```
erics-ability-context-save
    ↓
[Session 切换]
    ↓
erics-ability-context-restore
    ↓
[工作完成后]
    ↓
erics-ability-retro
    ↓
.loopx/wiki/ 更新
```

**触发场景：** "需要跨 session 保持上下文" 或 "周迭代结束需要沉淀"

### 5.4 简化-清理链（Simplify Cleanup Chain）

```
erics-process-find-simplifications
    ↓
erics-process-code-review（候选方案）
    ↓
erics-process-pre-push-checks（最终清理）
```

**触发场景：** "代码库有技术债，需要系统性简化"

### 5.5 PR 生命链（PR Lifecycle Chain）

```
erics-ability-pr-describe（PR 创建）
    ↓
erics-process-code-review（审查）
    ↓
erics-ability-pr-improve（改进建议）
    ↓
erics-ability-pr-ask（有问题时）
    ↓
erics-ability-pr-changelog（合并后）
```

**触发场景：** "一个 PR 的完整生命周期管理"

---

## 六、与 LLM Wiki 的整合

### 6.1 Skill 产物 → Wiki 沉淀

每个 Skill 执行后，产物应优先写入 `.loopx/wiki/`，而非仅返回给用户：

| Skill | Wiki 产物 |
|---|---|
| `erics-ability-spec` | `.loopx/wiki/entities/<feature-name>.md` |
| `erics-ability-plan-eng-review` | `.loopx/wiki/entities/<plan>-eng-review.md` |
| `erics-ability-plan-ceo-review` | `.loopx/wiki/entities/<plan>-ceo-review.md` |
| `erics-ability-investigate` | `.loopx/wiki/queries/<bug>-diagnosis.md` |
| `erics-ability-retro` | `.loopx/wiki/entities/sprint-<n>-retro.md` |
| `erics-process-acceptance-pipeline` | `.loopx/wiki/concepts/acceptance-pipeline.md` (更新) |
| `erics-process-mutation` | `.loopx/wiki/entities/mutation-report-<date>.md` |
| `erics-ability-cso` | `.loopx/wiki/entities/<feature>-threat-model.md` |
| `erics-ability-design-consultation` | `.loopx/wiki/entities/<feature>-design-system.md` |

### 6.2 Wiki → Skill 上下文

当 Skill 运行时，应优先读取 wiki 中的相关上下文：

```
Skill 启动
  ↓
读取 .loopx/wiki/index.md（总索引）
  ↓
读取相关的 entity / concept page
  ↓
作为上下文注入 Skill 过程
  ↓
Skill 执行 → 新产物写入 wiki
```

**Wiki 读取优先级：**
1. `.loopx/wiki/entities/` — 特定功能/决策的上下文
2. `.loopx/wiki/concepts/` — 通用概念和规范
3. `.loopx/wiki/queries/` — 历史 Q&A（避免重复问同样问题）
4. `.loopx/wiki/sources/` — 原始架构文档

### 6.3 Wiki 健康检查

```bash
# 定期检查 wiki 健康度
# 孤立页面（无入链）→ 清理或补充链接
# 失效 wikilink → 修复
# 过期内容（>90 天未更新）→ 标记或删除
```

对应的 Skill：`erics-process-archive-agent-notes` 可扩展支持 wiki 页面清理。

---

## 七、日常使用指南

### 7.1 按场景选择 Skill

| 场景 | 技能链 |
|---|---|
| 接到新需求 | `/erics-ability-office-hours` → `/erics-ability-spec` → `/erics-ability-plan-eng-review` |
| 写完代码，准备提 PR | `/erics-process-code-review` → `/erics-process-pre-push-checks` |
| PR 完成后 | `/erics-ability-pr-describe` |
| 需要理解代码结构 | `/erics-ability-graft` |
| 发现 bug | `/erics-ability-investigate` |
| 性能问题 | `/erics-ability-benchmark` |
| 安全审计 | `/erics-ability-cso` |
| 跨 session 继续工作 | `/erics-ability-context-save`（离开前）→ `/erics-ability-context-restore`（回来后） |
| 写验收测试 | `/erics-ability-bdd` → `/erics-process-acceptance-pipeline` |
| 验证测试有效性 | `/erics-process-mutation` |
| 代码简化 | `/erics-process-find-simplifications` |
| 文档规范化 | `/erics-process-prose-standard` → `/erics-process-doc-standards` |
| 周迭代回顾 | `/erics-ability-retro` |
| 版本检查 | `/erics-ability-upgrade` |

### 7.2 路由入口

使用 `/erics-loop-router` 自动路由未知任务：

```
/erics-loop-router
  ↓
输入："我想为一个登录功能写验收测试"
  ↓
路由到：erics-ability-bdd
```

### 7.3 最小环（快速闭环）

对于不需要完整链的简单任务，使用最小环：

```
单一 Skill 执行 → 产物 → 结束
```

**最小环示例：**
- `/erics-ability-pr-ask "这个 PR 的测试覆盖如何？"` → 直接回答
- `/erics-ability-health` → 代码质量仪表盘
- `/erics-ability-context-save` → 保存上下文

---

## 八、反模式（避免的做法）

### 8.1 开环反模式

**问题：** Skill 执行后产物没有持久化，Session 结束知识丢失。

```
❌ 错误做法：
/erics-ability-spec "用户登录功能"
  ↓
Spec 生成在 Chat 中
  ↓
Session 结束
  ↓
Spec 丢失

✓ 正确做法：
/erics-ability-spec "用户登录功能"
  ↓
Spec 写入 .loopx/wiki/entities/login-feature.md
  ↓
下次可查
```

### 8.2 跳过验证反模式

**问题：** 实现后跳过 `erics-process-mutation` 直接 merge，认为"测试写了就够了"。

```
❌ 错误做法：
写测试 → 直接 merge → 测试可能无效（存活率高）

✓ 正确做法：
写测试 → erics-process-mutation → 存活率 < 阈值 → merge
```

### 8.3 环过长反模式

**问题：** 试图用一个 Skill 完成太多事情，导致输出质量下降。

```
❌ 错误做法：
/erics-ability-bdd "整个系统" → 生成 500 行 .feature

✓ 正确做法：
按功能模块拆分，每个模块单独调用 /erics-ability-bdd
```

### 8.4 环断裂反模式

**问题：** Skill 之间没有传递上下文，各自独立运行导致重复工作。

```
❌ 错误做法：
erics-ability-spec → spec 输出到 chat
erics-ability-bdd → 重新描述需求

✓ 正确做法：
erics-ability-spec → wiki entities
erics-ability-bdd → 读取 wiki entities 作为上下文
```

---

## 九、与 APS（Acceptance Pipeline Specification）的互补

### 9.1 职责划分

| 维度 | Loop Engineering | APS |
|---|---|---|
| 关注点 | AI Agent 工作流结构化 | 验收测试的完整管道 |
| 粒度 | 工程生命周期（Plan→Ship→Retro） | 需求到测试（Spec→Feature→Run） |
| 验证方式 | 质量门禁（代码审查、变异测试） | Gherkin 变异 + 分级存活率 |
| 产出 | Wiki 知识 + PR 描述 + 诊断报告 | .feature + JSON IR + 测试报告 |

### 9.2 互补关系

```
需求
  ↓
Loop Engineering: erics-ability-spec（模糊→精确）
  ↓
APS: erics-ability-bdd（精确 spec → Gherkin .feature）
  ↓
Loop Engineering: erics-process-acceptance-pipeline（运行 APS）
  ↓
APS: gherkin-mutator（验证测试有效性）
  ↓
Loop Engineering: erics-process-mutation（源码级补充）
  ↓
代码实现
  ↓
Loop Engineering: erics-process-code-review
  ↓
代码 → Ship → Retro → Wiki 沉淀
```

**两者不是替代关系，而是不同层次的循环。**

---

## 十、扩展 Loop Engineering

### 10.1 新增 Skill 的检查清单

当需要新增一个 Skill 时，检查以下 Loop Engineering 要点：

- [ ] 输入是否明确（触发词 / 显式调用）
- [ ] 过程是否有明确步骤（而非一次性 prompt）
- [ ] 输出是否持久化（Wiki / 文件 / PR）
- [ ] 是否有验证步骤（质量门禁 / 退出码）
- [ ] 是否读取相关 wiki 上下文（而非孤立执行）
- [ ] 是否更新 wiki（产物沉淀）
- [ ] 是否可以组合到更大的循环中

### 10.2 循环监控

```bash
# 查看各 Skill 的使用频率（基于 Agent Notes）
erics-process-archive-agent-notes --audit

# 查看 wiki 更新的活跃度
ls -lt .loopx/wiki/entities/ | head -20

# 查看循环断裂点（无 wiki 产出的 Skill 调用）
grep -r "写入.*\.loopx/wiki" .claude/agent-notes/ || echo "无 wiki 产出记录"
```

---

## 十一、One-Click Install 集成与双 Runtime 选择

> 本节是对现有 v1.0 文档的补充——把 Loop Engineering 整合**嵌入** EricStack 安装脚本，并提供 `loopx` 与 `loop-engineering` 两种 runtime 供用户选择。

### 11.1 新版 One-Click Install（用户向）

```markdown
Install EricStack for me:
1. Install LoopX runtime (required for skill execution):
   curl -fsSL https://huangruiteng.github.io/loopx/install.sh | bash
2. Run: git clone https://github.com/gyc567/EricStack.git ~/EricStack
3. Run: bash ~/EricStack/.loopx/bin/install-ericsstack.sh [--mode loopx|loop-engineering|both]

可选参数：
  --mode loopx                # 默认，向后兼容 — 仅用 LoopX runtime
  --mode loop-engineering     # 仅用 cobusgreyling framework（需 Node.js）
  --mode both                 # 两个 runtime 都装（推荐）
  --with-loop-engineering-cli # 装 npm @cobusgreyling/loop-* 工具集
  --with-loop-docs            # 装 LOOP_ENGINEERING_INTEGRATION.md 到项目（默认 true）
  --skip-loop-engineering     # 显式跳过 loop-engineering

4. Set my project context to ~/EricStack
5. (可选) 安装 loop-engineering 工具链（--mode both / loop-engineering 时自动）：
   - npm install -g @cobusgreyling/loop-cli      # 统一 CLI 入口（init/doctor/status/audit/cost）
   - npm install -g @cobusgreyling/loop-audit    # Loop Ready Score 计算
   - npm install -g @cobusgreyling/loop-cost     # token 成本估算
   - npm install -g @cobusgreyling/loop-worktree # worktree 隔离
   - npm install -g @cobusgreyling/loop-gate     # gate.yaml 执行器
6. (可选) Run /loop-doctor 诊断就绪度
7. Run /estack 确认 skill 正常
8. Run /estack-upgrade 升级
```

### 11.2 三种模式的核心差异

| 维度 | `--mode loopx`（默认） | `--mode loop-engineering` | `--mode both` |
|---|---|---|---|
| 运行时 | LoopX CLI | cobusgreyling npm 工具集 | 两者并存 |
| Skill 装载 | LoopX runtime 直接读 `~/.claude/skills/` | npx 调用 loop-cli | 二选一自动 |
| Slash 命令 | `/erics-*` | `/loop-*` + `/erics-*` | 全套 |
| Loop patterns | 未启用（仅作概念） | 全套 7 个 pattern | 全套 |
| Loop Ready Score | 不可算 | `loop-audit` | `loop-audit` |
| Worktree 隔离 | 不可用 | `loop-worktree` | `loop-worktree` |
| Gate 强制 | 不可用 | `loop-gate` | `loop-gate` |
| Maker/Checker | 协议层概念 | 物理隔离（GH Actions 双 job） | 物理隔离 |
| 适用场景 | 已有 LoopX 环境的存量用户 | 想用 loop-engineering 全家桶 | 新用户、想要完整能力 |

### 11.3 install-ericsstack.sh 改造方案

**当前结构**（4 步）：连接 LoopX → 清旧 skills → 装新 skills → 写 entry points。

**v2 结构**（7 步）：

| 步骤 | 内容 | 触发条件 |
|---|---|---|
| 1 | 连接 LoopX | `--mode loopx` 或 `--mode both` |
| 2 | 装 loop-engineering CLI | `--mode loop-engineering` 或 `--mode both` 且 Node.js 可用 |
| 3 | 清旧 skills | 总是 |
| 4 | 装 40 erics-* skills + 4 个新 entry skill | 总是 |
| 5 | 拷 `docs/LOOP_ENGINEERING_INTEGRATION.md` 到项目 + runtime docs 目录 | `--with-loop-docs`（默认 true） |
| 6 | 写 runtime registry（`active_runtime` 字段） | 总是 |
| 7 | 写 loop/STATE.md 初始态（mode-aware） | 总是 |

**新增 entry skill**（装到 `~/.claude/skills/`）：

| Skill | 作用 | 模式依赖 |
|---|---|---|
| `loop-doctor` | 诊断并打印 Loop Ready Score | loop-engineering 或 both |
| `loop-status` | 显示当前 active loops | loop-engineering 或 both |
| `loop-mode` | 切换 loopx / loop-engineering | both |
| `loop-init` | 把 loop patterns 脚手架进用户当前项目 | loop-engineering 或 both |

### 11.4 用户选择与运行时切换机制

**三级覆盖（低优先级覆盖高）**：

| 级别 | 存储位置 | 作用 |
|---|---|---|
| **全局默认** | `~/.claude/skills/loop-mode/SKILL.md` 的 frontmatter | 跨项目默认 |
| **项目级** | `<project>/.loopx/registry.json` 的 `active_runtime` 字段 | 当前项目生效 |
| **会话级** | `loop/STATE.md` 的 `runtime_override` 字段 | 单次 run 临时切换 |

**冲突解决规则**：会话级 > 项目级 > 全局级；缺省值回退到 `loopx`。

**运行时检测**（`/estack` 入口）：
```bash
detect_runtime() {
  if command -v loop-cli >/dev/null 2>&1; then
    echo "loop-engineering"
  elif command -v loopx >/dev/null 2>&1; then
    echo "loopx"
  else
    echo "none"
  fi
}
```

### 11.5 文档分发方案

`docs/LOOP_ENGINEERING_INTEGRATION.md`（单一 source of truth）分发到 3 个位置：

| 目标路径 | 用途 | 模式依赖 |
|---|---|---|
| `~/EricStack/docs/LOOP_ENGINEERING_INTEGRATION.md` | 项目本地 canonical | 总是 |
| `~/EricStack/loop/README.md` | loop/ 目录自描述（Phase 1 LOOP.md 等价物） | 总是 |
| `~/.loop-engineering/docs/LOOP_ENGINEERING_INTEGRATION.md` | loop-engineering runtime 的 docs | `--mode loop-engineering` 或 `--mode both` |

**实现**：用 symlink 共享单一 source of truth，避免多份不同步。

```bash
# install 时
ln -sf ~/EricStack/docs/LOOP_ENGINEERING_INTEGRATION.md ~/EricStack/loop/README.md
ln -sf ~/EricStack/docs/LOOP_ENGINEERING_INTEGRATION.md ~/.loop-engineering/docs/ 2>/dev/null || true
```

### 11.6 uninstall-ericsstack.sh 改造

```bash
ask() { read -p "$1 [y/N] " -n 1 -r; echo; [[ $REPLY =~ ^[Yy]$ ]]; }

if ask "Remove loop-engineering runtime at ~/.loop-engineering/?"; then
  rm -rf ~/.loop-engineering
fi

if ask "Uninstall global npm @cobusgreyling/* packages?"; then
  npm uninstall -g @cobusgreyling/loop-cli @cobusgreyling/loop-audit \
                  @cobusgreyling/loop-cost @cobusgreyling/loop-worktree \
                  @cobusgreyling/loop-gate 2>/dev/null || true
fi

if ask "Remove ~/EricStack/loop/ directory?"; then
  rm -rf ~/EricStack/loop
fi

# 不删 LoopX（用户可能别处要用）
# 不删 ~/EricStack/（保留项目供重装）
```

### 11.7 决策树（完整 install 流程）

```
用户跑 install-ericsstack.sh
│
├─ 默认 / --mode loopx
│   ├─ 装 LoopX（如缺）
│   ├─ 跳过 loop-engineering CLI
│   ├─ 装 40 erics-* skills
│   ├─ 装 4 个 entry skill（loop-doctor/status/mode/init 不装）
│   ├─ 拷 LOOP_ENGINEERING_INTEGRATION.md 到 ~/EricStack/docs/（已存在）
│   ├─ 写 registry.json: active_runtime=loopx
│   └─ 写 loop/STATE.md（仅 loopx 上下文）
│
├─ --mode loop-engineering
│   ├─ 跳过 LoopX
│   ├─ 装 npm 全局 @cobusgreyling/* 工具（如 Node 可用，缺则 WARN）
│   ├─ 装 40 erics-* skills（适配 cobusgreyling runtime）
│   ├─ 装 4 个 entry skill（loop-doctor/status/mode/init 全装）
│   ├─ 拷 LOOP_ENGINEERING_INTEGRATION.md 到 3 个位置
│   ├─ 写 registry.json: active_runtime=loop-engineering
│   └─ 写 loop/STATE.md（loop-engineering 上下文）
│
└─ --mode both
    ├─ 装 LoopX（如缺）
    ├─ 装 npm 全局 @cobusgreyling/* 工具（如 Node 可用）
    ├─ 装 40 erics-* skills
    ├─ 装 4 个 entry skill（全装）
    ├─ 拷 LOOP_ENGINEERING_INTEGRATION.md 到 3 个位置
    ├─ 创建 runtime 切换脚本
    ├─ 写 registry.json: active_runtime=both
    └─ 写 loop/STATE.md（双 runtime 上下文）
```

### 11.8 新增 entry skill 的 frontmatter 草案

```yaml
---
name: loop-doctor
description: Diagnose EricStack + Loop Engineering readiness. Run after install or upgrade to print Loop Ready Score.
triggers:
  - loop doctor
  - /loop-doctor
  - 诊断
  - 就绪度
autonomy_level: L1
maker_checker_policy: none
loop_pattern: daily-triage
---
```

```yaml
---
name: loop-mode
description: Switch active runtime between loopx and loop-engineering for the current session.
triggers:
  - loop mode
  - /loop-mode
  - 切换 runtime
  - 切换 loopx
autonomy_level: L1
maker_checker_policy: none
loop_pattern: null
---
```

### 11.9 与 Phase 1-6 的衔接

| Phase | install 脚本演进 |
|---|---|
| Phase 1 | 默认 `--mode loopx` 出基线（确保不破坏现有用户）；为 `--mode loop-engineering` 准备 CLI 探针 |
| Phase 2 | 加 `--mode loop-engineering` 选项（仅 init，不跑 patterns） |
| Phase 3 | 加 `--mode both` 选项（loop-engineering patterns 启用） |
| Phase 4 | L2 强制需要 loop-engineering 的 worktree + gate；install 脚本会主动提示升级到 `both` |
| Phase 5 | 默认 `--mode both`；新增 `loop-engineering` 作 sync source |
| Phase 6 | install 脚本加 `--with-harness-foundry` 选装 harness-foundry |

### 11.10 风险与缓解

| 风险 | 缓解 |
|---|---|
| LoopX 与 loop-engineering 命名冲突 | skill 命名空间前缀分开：`erics-*` vs `loop-*` |
| Node.js 缺失导致 npm 装不上 | 优雅 skip + 提示用户单独装 |
| npm 包版本漂移 | 锁定版本到 `package.json` 的 devDependencies；sync-skills.sh 加 loop-cli 版本检查 |
| 既有 LoopX 用户被强装 loop-engineering | `--mode loopx` 默认值，向后兼容 |
| 用户两份 runtime 切换不一致 | `loop-mode` skill 强制写 STATE.md + audit 日志 |
| 文档多份不同步 | 用 symlink 共享单一 source of truth |
| 安装脚本跨平台差异 | 仅依赖 bash + curl + npm；不依赖 jq / python |
| 卸载时误删 LoopX | 显式 ask + 不在 uninstall 自动删 LoopX |

### 11.11 与既有 EricStack 文档的协调

- 本节（§十一）作为 v1.0 文档的扩展，**不重写** 前十节
- 旧 install 步骤（README.md 中的 7 步流程）保持有效，作为 `--mode loopx` 默认路径
- 本节提供新参数 `--mode` / `--with-*` / `--skip-*` 作为可选能力

---

## 附录 A：Skill 循环速查表

| Skill | 类型 | 输入 | 过程 | 输出 | 验证 |
|---|---|---|---|---|---|
| `erics-process-code-review` | Process | PR diff | Coverage + Prose + Invariants | PR 评论 | 质量门禁 |
| `erics-process-mutation` | Process | 源码 + 测试 | 变异算子注入 | 存活率报告 | 分级阈值 |
| `erics-process-acceptance-pipeline` | Process | .feature | 7 阶段管道 | JSON IR + 报告 | 退出码 |
| `erics-process-pre-push-checks` | Process | Git state | 选定检查集 | 通过/失败 | 退出码 |
| `erics-process-find-simplifications` | Process | 源码 | 死代码/简化候选 | 候选项列表 | 数量统计 |
| `erics-process-prose-standard` | Process | 文档/注释 | Prose lint | Lint 报告 | 泄漏率 |
| `erics-process-trim-cot-leakage` | Process | 文档 | CoT 泄漏检测 | 清理后文档 | 泄漏率 |
| `erics-process-archive-agent-notes` | Process | Agent Notes | 归档/清理 | 归档记录 | 完整性 |
| `erics-process-doc-site-sync` | Process | Doc 变更 | VitePress 同步 | 同步报告 | 站点可用性 |
| `erics-process-doc-standards` | Process | 文档 | Standards 检查 | 改进建议 | 规范符合度 |
| `erics-process-merging-stacked-prs` | Process | PR Stack | 顺序合并 | Merge 状态 | CI 通过 |
| `erics-process-record-browser-gif` | Process | UI 场景 | 帧捕获 + 编码 | GIF 文件 | 播放可用 |
| `erics-process-translate-docs` | Process | 源文档 | 中英对照 | Bilingual 文档 | 对照完整性 |
| `erics-ability-spec` | Ability | 模糊需求 | 5 阶段 spec | Entity page + issue | 完整性 |
| `erics-ability-bdd` | Ability | Spec | Gherkin 生成 | .feature 文件 | DRY 检查 |
| `erics-ability-test-runner` | Ability | JSON IR | Framework 适配 | JUnit XML | 运行结果 |
| `erics-ability-plan-eng-review` | Ability | Plan | 架构审查 | Review 评论 | 覆盖率 |
| `erics-ability-plan-ceo-review` | Ability | Plan | 产品审查 | Review 评论 | 六问完成度 |
| `erics-ability-investigate` | Ability | Bug 描述 | 4 阶段调查 | 诊断报告 | 根因找到 |
| `erics-ability-cso` | Ability | 功能范围 | OWASP + STRIDE | 威胁模型 | 发现数量 |
| `erics-ability-health` | Ability | 项目状态 | 质量信号收集 | 仪表盘 | 指标阈值 |
| `erics-ability-benchmark` | Ability | 测量目标 | 性能测量 | 基准报告 | 回归检测 |
| `erics-ability-graft` | Ability | 查询 | Call chain 追踪 | 结构化答案 | 准确性 |
| `erics-ability-pr-describe` | Ability | PR diff | 描述生成 | PR 描述 | 完整性 |
| `erics-ability-pr-changelog` | Ability | PR 列表 | Changelog 生成 | CHANGELOG.md | 格式规范 |
| `erics-ability-pr-improve` | Ability | PR diff | 改进建议 | 建议列表 | 可执行数量 |
| `erics-ability-pr-ask` | Ability | PR 问题 | 自由回答 | 文本答案 | 准确性 |
| `erics-ability-context-save` | Ability | Git state | 快照保存 | 快照文件 | 完整性 |
| `erics-ability-context-restore` | Ability | 快照 ID | 状态恢复 | 恢复确认 | git state 一致 |
| `erics-ability-retro` | Ability | Sprint 数据 | 回顾分析 | Retro 报告 | 完成度 |
| `erics-ability-office-hours` | Ability | 产品问题 | 六问头脑风暴 | 答案列表 | 覆盖度 |
| `erics-ability-design-consultation` | Ability | 设计需求 | 设计系统构建 | 设计文档 | 完整性 |
| `erics-ability-devex-review` | Ability | 用户流程 | DX 审计 | 报告 | 痛点数量 |
| `erics-ability-autoplan` | Ability | 请求 | CEO+Eng+Dx 链 | 多视角评审 | 覆盖度 |
| `erics-ability-upgrade` | Ability | 当前版本 | 版本比较 | 升级报告 | 最新版本检测 |
| `erics-ability-estack` | Ability | 触发 | Banner 显示 | 路由服务 | 可用性 |

---

## 附录 B：相关资源

- [Loop Engineering 概念页](../.loopx/wiki/concepts/loop-engineering.md)
- [APS 概念页](../.loopx/wiki/concepts/acceptance-pipeline.md)
- [Skills Index](../.loopx/wiki/index.md)
- [APS 整合方案](./APS_INTEGRATION.md)
- [LLM Wiki 整合说明](../.loopx/llm-wiki-integration.md)
- [TUTORIAL.md](./TUTORIAL.md)
