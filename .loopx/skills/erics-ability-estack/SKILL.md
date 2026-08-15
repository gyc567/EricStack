---
name: erics-ability-estack
description: EricStack main entry point — displays interactive banner and routes to the correct skill. Start here for anything in EricStack.
allowed-tools:
  - Read
  - Bash
triggers:
  - estack
  - ericstack
  - activate ericstack
  - activate loopx
  - loopx
  - 主入口
  - 工程助手
  - 帮我看看这个项目
  - /estack
---

# EricStack — AI-Native Engineering Loop

```
╔══════════════════════════════════════════════════════╗
║  EricStack  v0.1.0  |  26 skills  |  AI-Native Loop  ║
╚══════════════════════════════════════════════════════╝
```

## 常用技能（直接调用）

| 命令 | 功能 |
|---|---|
| `/erics-process-code-review` | PR 全方位审查（coverage + prose + invariant） |
| `/erics-ability-investigate` | 四阶段调试（调查→分析→假设→实施） |
| `/erics-ability-spec` | 模糊需求 → 可执行 spec |
| `/erics-ability-health` | 代码质量仪表盘 |
| `/erics-ability-retro` | 周迭代回顾 |
| `/erics-ability-office-hours` | YC 六问（判断想法是否值得做） |
| `/erics-ability-cso` | 安全审计（OWASP + STRIDE） |
| `/erics-ability-benchmark` | 性能回归检测 |

## 不确定用哪个？告诉我要做什么

直接描述你的需求，我帮你路由到正确的技能。例如：

- "帮我 review 这个 PR" → `erics-process-code-review`
- "帮我 plan 这个功能" → `erics-ability-plan-eng-review`
- "帮我 debug 这个 error" → `erics-ability-investigate`
- "我有个想法想讨论" → `erics-ability-office-hours`
- "帮我做安全审计" → `erics-ability-cso`
- "帮我保存当前进度" → `erics-ability-context-save`
- "帮我 benchmark 性能" → `erics-ability-benchmark`

运行 `/erics-loop-router` 查看全部 26 个技能的完整路由表。

## 快速命令

| 命令 | 功能 |
|---|---|
| `/erics-ability-upgrade` | 检查 EricStack 更新 |
| `/erics-loop-router` | 查看全部技能和路由规则 |
| `bash .loopx/bin/sync-skills.sh --check` | 检查上游 skill 更新 |

## Skill 命名规范

| 前缀 | 含义 | 使用场景 |
|---|---|---|
| `erics-process-*` | 纪律 / 标准 | 无论你想不想做，都应该做 |
| `erics-ability-*` | 行动 / 能力 | 你选择做的时候，有工具支撑 |

两者都适用时，写作/审查类优先 `erics-process-*`，行动执行类优先 `erics-ability-*`。
