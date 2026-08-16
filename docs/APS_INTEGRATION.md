# EricStack + Acceptance Pipeline Specification (APS) 整合方案

> 整合日期：2026-08-16 | 整合目标：P0
> 参考：[unclebob/Acceptance-Pipeline-Specification](https://github.com/unclebob/Acceptance-Pipeline-Specification) + [topdigg/acceptance-pipeline-specification](https://www.topdigg.com/blog/acceptance-pipeline-specification)

---

## 一、背景与目标

**Uncle Bob 的 Acceptance Pipeline Specification (APS)** 是一套与框架无关的验收测试管道，核心流程：

```
Feature File (.feature)
  → gherkin-parser      → JSON IR
  → gherkin-ir-dry-checker → duplicate report
  → acceptance-generator → 生成的测试入口
  → project runner      → 测试结果
  → gherkin-mutator     → 变异测试
```

**EricStack 现状：**
- `erics-ability-bdd` — Gherkin 场景生成能力（已有）
- `erics-process-mutation` — 源码级变异测试（已有）
- 缺少：完整 APS 管道编排 + Gherkin 变异测试 + 测试运行适配层

**整合目标：** 将 APS 的完整管道整合为 EricStack 的内置 discipline，形成从需求到可验证代码的完整 AI-Era TDD 闭环。

---

## 二、整合架构

### 2.1 新增 / 修改的 Skills

| Skill | 类型 | 用途 |
|---|---|---|
| `erics-process-acceptance-pipeline` | process (discipline) | 主管道：协调 APS 全流程 |
| `erics-ability-bdd` (已有，重写) | ability | Gherkin 场景编写 + 解析为 JSON IR + DRY 检查 |
| `erics-ability-test-runner` (新增) | ability | 项目级测试运行器适配器 |
| `erics-process-mutation` (已有) | process | 对接 APS gherkin-mutator |

### 2.2 目录结构

```
.loopx/
├── acceptance-pipeline/                   # NEW: APS 工具集
│   ├── bin/
│   │   ├── gherkin-parser                 # Go 二进制 (BB 备用)
│   │   ├── gherkin-ir-dry-checker         # Go 二进制 (BB 备用)
│   │   ├── gherkin-mutator                # Go 二进制 (BB 备用)
│   │   └── acceptance-entrypoint-generator # 项目自定义
│   ├── features/                          # 用户编写的 .feature 文件
│   │   ├── auth/
│   │   ├── api/
│   │   └── ui/
│   ├── ir/                                # 解析后的 JSON IR
│   │   └── *.ir.json
│   ├── generated/                         # 生成的测试入口代码
│   │   ├── metadata/
│   │   │   └── *.json
│   │   └── test_*.java / test_*.py 等
│   ├── reports/
│   │   ├── dry-check/                     # DRY 检查报告
│   │   └── mutation/                      # 变异测试报告
│   └── acceptance.env                     # 项目配置
├── skills/
│   ├── erics-process-acceptance-pipeline/ # NEW: 主编排 skill
│   ├── erics-ability-bdd/                 # REWRITE: 扩展为 APS 前半段
│   ├── erics-ability-test-runner/         # NEW: 测试运行适配器
│   └── erics-process-mutation/            # EXISTING: 对接 APS mutator
└── wiki/
    └── concepts/
        └── acceptance-pipeline.md         # NEW: APS 概念 wiki 页
```

---

## 三、Skills 详细设计

### 3.1 `erics-process-acceptance-pipeline` (主编排)

**触发词：** `acceptance pipeline`, `验收管道`, `APS`, `gherkin 流程`, `acceptance test pipeline`

**职责：** 端到端编排 APS 全流程，协调各子工具的执行顺序。

**工作流（5阶段）：**

```
Stage 1: 解析 (Parse)
  bb gherkin-parser <feature-file> <output.ir.json>
  或: ./bin/gherkin-parser <feature-file> <output.ir.json>

Stage 2: DRY 检查 (可选但推荐)
  bb gherkin-ir-dry-checker [--include-exact] <ir.json> <report-output>
  检查类别:
    - duplicate-in-scenario        # 场景内完全重复的 step
    - placeholder-variant          # 可参数化的 placeholder 变体
    - near-duplicate               # 近似重复 (相似度 > 0.85)
    - possible-synonym             # 可能同义词
  人工确认后继续

Stage 3: 生成测试入口 (Generate)
  acceptance-entrypoint-generator <ir.json> <generated-output/>
  生成: 测试框架特定的入口代码 (JUnit5 / Pytest / Behave 等)
  写入: metadata/<feature-name>.json (含 implementation_hash)

Stage 4: 运行验收测试 (Run)
  运行生成的测试入口
  项目 step handlers 执行真实行为验证
  报告: passed / failed / error

Stage 5: 变异测试 (Mutate) — P0 质量门禁
  bb gherkin-mutator [options]
  目标: 存活率 < 5%
  报告: killed / survived / error 分类
```

**退出码约定：**
- `0` — 全部通过
- `1` — 解析 / 生成 / 运行错误
- `2` — 变异测试存活率超标（质量门禁失败）

**CI/CD 模式：** `acceptance-pipeline run --ci` 输出 JUnit XML 报告格式。

---

### 3.2 `erics-ability-bdd` (重写扩展)

**已有功能（保留）：** Gherkin 场景生成、Given-When-Then 编写规范。

**新增功能：**

1. **Feature 文件创建辅助**
   - 根据需求描述生成初始 `.feature` 文件
   - 使用 Scenario Outline 进行数据参数化
   - 正确的 Tag 组织 (`@auth`, `@smoke`, `@regression`)

2. **JSON IR 解析执行**
   - 调用 `gherkin-parser` 解析 `.feature` → JSON IR
   - 验证 IR 结构正确性

3. **DRY 检查执行 + 修复建议**
   - 调用 `gherkin-ir-dry-checker`
   - 解释报告中的 4 类问题并给出修复建议
   - 自动合并明显的 placeholder-variant

---

### 3.3 `erics-ability-test-runner` (新增)

**触发词：** `test runner`, `run acceptance tests`, `运行验收测试`

**职责：** 抽象层，对接项目实际使用的测试框架。

**Step Handler 核心契约（来自 APS 规范）：**
- Step handlers 接收 `world/state` 对象 + 当前 example 值
- 每个 scenario execution 获得独立的 world 对象
- Background steps prepend 到每个 scenario execution
- 不支持的 step text → 测试失败
- 缺失 / 格式错误的 example 值 → 测试失败
- 正则匹配时，捕获的 placeholder 名作为 example key

**支持的框架适配器：**

| 框架 | 适配器输出 | 说明 |
|---|---|---|
| JUnit 5 (Java) | `*Test.java` | 生成标准 JUnit 5 测试入口 |
| Pytest (Python) | `test_*.py` | 生成 pytest 格式入口 |
| Behave (Python BDD) | 直接运行 `.feature` | 无需生成，直接用 Behave |
| Go testing | `*_test.go` | 生成 Go test 格式入口 |
| Jest (JS/TS) | `*.test.ts` | 生成 Jest 格式入口 |
| RSpec (Ruby) | `*_spec.rb` | 生成 RSpec 格式入口 |

---

### 3.4 `erics-process-mutation` (已有，对接 APS)

**已有功能：** 变异测试原理、工具选择（mutmut / stryker-js / pitest）、存活率分析。

**新增 APS gherkin-mutator 对接：**

```bash
# APS Gherkin 变异测试运行方式
bb gherkin-mutator \
  --manifest <ir.json> \
  --runner ./bin/runner-adapter \
  --output build/acceptance-mutation/

# 输出: mutation-report.json
# 格式: { killed: N, survived: M, error: E, survival_rate: X% }
```

**质量门禁规则：**
- `survival_rate > 5%` → 退出码 2，block merge
- `survival_rate > 15%` → 退出码 2，block merge + alert

---

## 四、APS 工具集安装方案

### 4.1 安装策略

优先使用 **Babashka**（Clojure 脚本），无 BB 时用 **Go 二进制** fallback。

**安装脚本：** `.loopx/bin/install-acceptance-pipeline.sh`

```bash
#!/bin/bash
set -e

APS_VERSION="latest"
APS_DIR="$PWD/.loopx/acceptance-pipeline"
BIN_DIR="$APS_DIR/bin"

# 检测 Babashka
if command -v bb &> /dev/null; then
  echo "Using Babashka"
  mkdir -p "$BIN_DIR/bb"
  # ln -sf APS_REPO/bb/* "$BIN_DIR/bb/"
else
  echo "Using Go binaries"
  curl -fsSL "https://github.com/unclebob/Acceptance-Pipeline-Specification/releases/$APS_VERSION/download/aps-$(uname -s)-$(uname -m).tar.gz" | tar xz -C "$BIN_DIR"
fi

mkdir -p "$APS_DIR"/features ir generated reports
echo "APS installed at $APS_DIR"
```

### 4.2 工具清单

| 工具 | 来源 | 用途 |
|---|---|---|
| `gherkin-parser` | APS repo | `.feature` → JSON IR |
| `gherkin-ir-dry-checker` | APS repo | JSON IR → DRY 报告 |
| `acceptance-entrypoint-generator` | 项目自定义 | JSON IR → 测试入口代码 |
| `gherkin-mutator` | APS repo | JSON IR → 变异测试 |

---

## 五、工作流集成

### 5.1 完整 AI-Era TDD 流程（整合 Uncle Bob 三件套）

```
需求输入
    ↓
[1] erics-ability-spec
    模糊需求 → 精确 spec
    ↓
[2] erics-ability-bdd
    spec → Gherkin .feature 文件
    ↓
[3] erics-process-acceptance-pipeline
    ├── Stage 1: gherkin-parser        → JSON IR
    ├── Stage 2: gherkin-ir-dry-checker → DRY 报告 (可选)
    ├── Stage 3: 生成测试入口          → 框架特定代码
    ├── Stage 4: 运行验收测试          → passed / failed
    └── Stage 5: gherkin-mutator       → 变异报告
    ↓
[4] erics-process-mutation
    源码级变异测试（补充 APS 变异）
    ↓
代码实现
    ↓
[5] erics-process-code-review
    ↓
[6] erics-process-pre-push-checks
```

### 5.2 开发者日常工作流

```bash
# 快速运行单个 feature
/acceptance-pipeline run features/auth/login.feature

# 运行全部 acceptance tests
/acceptance-pipeline run --all

# 只做 DRY 检查（不生成不运行）
/acceptance-pipeline check features/**/*.feature

# CI 模式：生成报告 + 质量门禁
/acceptance-pipeline run --ci
```

### 5.3 CI/CD 集成示例

```yaml
# .github/workflows/acceptance.yml
name: Acceptance Pipeline

on: [push, pull_request]

jobs:
  acceptance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install APS
        run: bash .loopx/bin/install-acceptance-pipeline.sh

      - name: Run acceptance pipeline
        run: |
          for f in features/**/*.feature; do
            loopx acceptance-pipeline run --ci "$f"
          done

      - name: Upload reports
        uses: actions/upload-artifact@v4
        with:
          name: acceptance-reports
          path: |
            build/acceptance/reports/*.xml
            build/acceptance-mutation/*.json
```

---

## 六、与 EricStack 现有 Skills 的关系

### 6.1 能力矩阵

| 能力 | erics-ability-bdd | erics-process-acceptance-pipeline | erics-process-mutation |
|---|---|---|---|
| Gherkin 编写 | ✅ | — | — |
| .feature → JSON IR | ✅ | — | — |
| DRY 检查 | ✅ | — | — |
| 端到端管道编排 | — | ✅ | — |
| 测试生成 | — | ✅ | — |
| 测试运行 | — | ✅ | — |
| APS Gherkin 变异测试 | — | ✅ | — |
| 源码变异测试 | — | — | ✅ |
| 存活率质量门禁 | — | ✅ (Stage 5) | ✅ |

### 6.2 路由规则更新（erics-loop-router）

```yaml
# 新增路由条目
- task: "写 Gherkin 验收测试"
  skill: erics-ability-bdd

- task: "运行完整验收管道"
  skill: erics-process-acceptance-pipeline

- task: "变异测试验证测试质量"
  skill: erics-process-mutation

- task: "AI-Era TDD 全流程"
  skill: erics-process-acceptance-pipeline
```

---

## 七、Wiki 知识页

新建 `.loopx/wiki/concepts/acceptance-pipeline.md`：

```markdown
# Acceptance Pipeline Specification

APS 是 Uncle Bob 提出的与框架无关的验收测试管道...

## 核心工具
- gherkin-parser — .feature → JSON IR
- gherkin-ir-dry-checker — JSON IR → DRY 报告
- acceptance-entrypoint-generator — JSON IR → 测试入口
- gherkin-mutator — 变异测试

## 与 EricStack 集成
- erics-ability-bdd: Gherkin 编写
- erics-process-acceptance-pipeline: 管道编排
- erics-process-mutation: 变异测试

## AI-Era TDD 流程
需求 → spec → Gherkin → 解析 → DRY检查 → 生成 → 运行 → 变异测试
```

---

## 八、实施优先级

| 优先级 | 阶段 | 内容 | 产出 |
|---|---|---|---|
| **P0** | Phase 1 | 安装 APS 工具 + `erics-ability-bdd` 扩展 | 可运行的 parse + dry-check |
| **P0** | Phase 2 | `erics-process-acceptance-pipeline` skill | 完整 5 阶段管道 |
| **P1** | Phase 3 | `erics-ability-test-runner` 适配器（选 1-2 个框架） | 实际测试运行 |
| **P1** | Phase 4 | Wiki 页面 + 文档更新 | 用户上手指南 |
| **P2** | Phase 5 | CI/CD 集成 + 质量门禁规则 | 自动化质量关卡 |

---

## 九、风险与缓解

| 风险 | 级别 | 缓解 |
|---|---|---|
| APS 工具依赖 Babashka / Go 环境 | 中 | 提供 Docker 一键环境 + 纯脚本 fallback |
| 测试入口生成与项目框架不兼容 | 高 | Phase 3 先做 1-2 个主流框架适配器 |
| 变异测试运行慢（超时） | 低 | 提供 `--timeout` 配置 + 只在 CI 运行 |
| Gherkin 编写质量差导致生成的测试无意义 | 中 | `erics-ability-bdd` skill 中强化 Gherkin 规范教育 |
| APS 规范更新导致工具不兼容 | 低 | 锁定版本，升级前在 wiki 中发布 changelog |

---

## 十、与 EricStack 现有流程的对比

| 维度 | EricStack (现状) | + APS 整合后 |
|---|---|---|
| 需求到测试 | `erics-ability-spec` → 手工写测试 | `erics-ability-spec` → `erics-ability-bdd` 生成 `.feature` |
| 测试可读性 | 代码测试，非技术 stakeholder 难读 | Gherkin 自然语言，业务方可直接评审 |
| 测试有效性验证 | `erics-process-mutation`（源码级） | 额外 APS 变异测试（需求级） |
| 端到端管道 | 手工切换多个 skill | `erics-process-acceptance-pipeline` 一键完成 |
| CI/CD 集成 | 通用测试运行 | 结构化 acceptance 报告 + 质量门禁 |
