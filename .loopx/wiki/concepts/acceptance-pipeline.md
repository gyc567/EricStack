---
name: acceptance-pipeline
created: 2026-08-16
tags: [aps, bdd, gherkin, acceptance-testing, mutation-testing]
---

# Acceptance Pipeline Specification (APS)

**APS** 是 Uncle Bob 提出的与框架无关的验收测试管道，将 Gherkin 自然语言需求转化为可执行测试，并验证测试的有效性。

## 核心流程

```
.feature 文件 → gherkin-parser → JSON IR
  → gherkin-ir-dry-checker → DRY 报告
  → acceptance-generator → 测试入口代码
  → project runner → 测试结果
  → gherkin-mutator → 变异测试报告
```

## 关键工具

| 工具 | 用途 |
|---|---|
| `gherkin-parser` | 将 `.feature` 解析为 JSON IR |
| `gherkin-ir-dry-checker` | 检测重复/近似的 step 文本 |
| `acceptance-entrypoint-generator` | JSON IR → 框架特定的测试代码 |
| `gherkin-mutator` | 变异测试：验证测试真正约束需求 |

## 增量缓存策略

IR 和变异报告按 `content-hash` 缓存，实现已变时自动失效。

## EricStack 集成

- [[erics-ability-bdd]] — Gherkin 编写 + Stage 0-2
- [[erics-process-acceptance-pipeline]] — 端到端管道编排
- [[erics-process-mutation]] — 源码级变异测试（补充）

## 质量门禁

- DRY 检查：`duplicate-in-scenario > 0` → block
- 变异测试：`survival_rate > 5%` → block (exit 2)

## 相关资源

- [Uncle Bob APS Repo](https://github.com/unclebob/Acceptance-Pipeline-Specification)
- [topdigg: APS 解读](https://www.topdigg.com/blog/acceptance-pipeline-specification)
- [docs/APS_INTEGRATION.md](../../docs/APS_INTEGRATION.md)
