# EricStack 项目审计报告

> 审计日期：2026-08-15
> 审计范围：skills 代码、文档、教程、配置、CI/CD
> 审计工具：rg, bash, git

---

## 摘要

| 类别 | 状态 |
|---|---|
| 品牌纯净度（Brand Cleanliness） | ❌ 未通过 |
| 技能可发现性（Skill Discoverability） | ❌ 严重阻塞 |
| 文档完整性 | ⚠️ 部分问题 |
| 知识库完整性 | ⚠️ 部分问题 |
| 自动更新机制 | ✅ 通过 |
| Git 配置 | ✅ 通过 |

**严重问题：4 个阻塞级（Critical）| 高优先级：6 个**

---

## 一、阻塞级问题（Critical）

### C1：所有 process skills 缺少 `triggers:` 字段 — 技能无法被发现

**发现：**
11 个 `erics-process-*` skills 全部缺少 `triggers:` frontmatter 字段。

**影响：**
- `/erics-loop-router` 的路由规则依赖 `triggers:` 字段做匹配
- 用户输入 "帮我 code review"，router 找不到 `erics-process-code-review` 的触发词
- 所有 process skills 的路由依赖 router 里硬编码的路由表，但路由表是单向的——skill 本身不知道自己的触发词

**证据：**
```bash
# 以下 skills 全部没有 triggers: 字段
erics-process-archive-agent-notes/
erics-process-code-review/
erics-process-doc-site-sync/
erics-process-doc-standards/
erics-process-find-simplifications/
erics-process-merging-stacked-prs/
erics-process-pre-push-checks/
erics-process-prose-standard/
erics-process-record-browser-gif/
erics-process-translate-docs/
erics-process-trim-cot-leakage/
```

**修复建议：**
为每个 process skill 添加 `triggers:` frontmatter，从 router 的路由表中提取触发词：
```yaml
---
name: erics-process-code-review
description: Use when reviewing a pull request in the EricStack project...
triggers:
  - code review
  - review this pr
  - pr review
---
```

---

### C2：Ability skills 大量残留 gstack 品牌引用

**发现：** 多个 ability skills 的 body 内部仍有 gstack 残留引用，影响品牌纯净和用户体验。

**最严重的 skill：**

#### `autoplan`（13 处残留）
- `_gstack_codex_log_event` 函数调用（应为 `true`）
- `_gstack_codex_auth_probe` 函数调用（应为 `true`）
- `_gstack_codex_version_check` 函数调用（应为 `true`）
- `_gstack_codex_timeout_wrapper` 函数调用（应为 `true`）
- `skills/gstack` 路径检查（应移除）

#### `retro`（7 处残留）
- 第80行：`gstack can search learnings from your other projects...`
- 第93行：`gstack is getting smarter on their codebase`
- 第405行：Sample data 包含 `"Garry Tan"` 名字
- 第541行：`.claude/skills/gstack/bin/erics-global-discover` 残留路径
- 第629行：输出包含 `Powered by gstack`
- 第733行：`"name": "gstack"` JSON 数据
- 第751行：`tweetable` 内容包含 gstack 引用

#### `benchmark-models`（2 处残留）
- 第18行：`BIN=".claude/skills/gstack/bin/true"`（应为 `BIN="true"`）
- 第22行：`If not found, stop and tell the user to reinstall gstack.`（应为 `reinstall EricStack`）

#### `benchmark`（残留）
- `~/.claude/skills/gstack/browse/binary` 路径引用

#### `design-consultation`（多处残留）
- `~/.claude/skills/gstack/browse/binary` 路径引用
- `~/.claude/skills/gstack/design/dist/design` 路径引用
- `gstack can search learnings...` prose 残留

#### `devex-review`、`office-hours`（残留）
- `~/.claude/skills/gstack/browse/binary` 路径引用
- `gstack can search learnings...` prose 残留

#### `erics-ability-upgrade`
- Skill 描述中引用 `deepseek-harness` 和 `gstack` 作为上游名称（可接受，但需审查措辞）

#### `spec`、`erics-ability-cso`、`plan-ceo-review`、`erics-ability-plan-eng-review`、`erics-ability-investigate`
- `gstack can search learnings...` prose 残留

---

### C3：`erics-process-code-review` 引用失效的 deepseek-harness 路径

**发现：** process skills 的 body 仍包含 `../../../docs/...`、`../../../AGENTS.md` 等 deepseek-harness 路径引用。

**证据：**
```bash
# erics-process-code-review/SKILL.md
- [AGENTS.md](../../../AGENTS.md) ...
- [docs/defensive-patterns.md](../../../docs/defensive-patterns.md) ...
- [docs/AGENTS.md](../../../docs/AGENTS.md) ...
- [docs/testing.md](../../../docs/testing.md) ...
```

这些路径在 EricStack 中不存在。`erics-mapping.md` 记录了路径映射，但 skills body 中的引用未被正确重写。

**修复建议：**
将 `../../../AGENTS.md` → 对应本地存在的路径，或改为相对路径 `../../AGENTS.md`（如果 EricStack 根目录有）。

---

### C4：wiki 目录不完整，缺少必要页面

**发现：** `docs/TUTORIAL.md` 中引用了 `sources/INTEGRATION.md`，但 `.loopx/wiki/sources/` 目录为空。

**wiki 根目录缺少的页面：**
- `.loopx/wiki/overview.md` — ❌ 缺失
- `.loopx/wiki/purpose.md` — ❌ 缺失
- `.loopx/wiki/schema.md` — ❌ 缺失
- `.loopx/wiki/log.md` — ❌ 缺失
- `.loopx/wiki/sources/INTEGRATION.md` — ❌ 缺失

但这些文件确实存在于仓库根目录：
- `INTEGRATION.md`
- `README.md`
- `README_CN.md`

**修复建议：**
在 wiki 的 `sources/` 下创建副本，或在 `index.md` 中使用相对链接指向根目录文件。

---

## 二、高优先级问题（High）

### H1：`erics-process-translate-docs` frontmatter 格式错误

**发现：**
```yaml
description: Manually run the extended DeepSeek Harness bilingual-document workflow...
disable-model-invocation: true
```
`disable-model-invocation: true` 不在标准 frontmatter schema 中，且没有 `triggers:` 字段。

### H2：部分 ability skills 触发词不完整

以下 skills 的 `triggers:` 缺少最直观的触发词：

| Skill | 缺少的触发词 |
|---|---|
| `benchmark-models` | `benchmark-models` 自身 |
| `devex-review` | `devex review`, `TTHW` |
| `health` | `health check`（有，但缺少 `quality dashboard`） |
| `spec` | `write spec`, `executable spec` |

### H3：`health` skill 残留 `gbrain` 相关路径

第165-186行：`gbrain doctor` 相关逻辑中包含 `projects/$SLUG/` 路径引用，可能在 gstack 用户机器上有路径问题。

### H4：`spec` skill 残留 `~/.gstack` 路径

第157行：`~/.gstack` 路径引用应在品牌清洗时被替换为 `~/.loopx/` 或移除。

---

## 三、中优先级问题（Medium）

### M1：Wiki 页面数量偏少

**现状：** wiki 只有 5 个概念页面（182 行内容），分散在 `concepts/`、`entities/`、`queries/` 目录下。
**建议：** 每个 process skill 应至少有一个对应的 concept page 在 wiki 中。

### M2：`README.md` 文档表格中无 Tutorial 链接

文档表格中 `docs/TUTORIAL.md` 有条目，但 README 中没有对应的快速跳转锚点。

### M3：`sync-skills.sh` 的 `--execute` 模式实现不完整

当前 `--execute` 只是 clone 了仓库但没有实际执行 skill 文件的 brand 重写和写入。实际同步需要完整的 re-import pipeline。

---

## 四、低优先级问题（Low）

### L1：`erics-ability-upgrade` skill 输出格式与 router 输出格式不一致

router 的 startup auto-check 输出 `EricStack update available: v$LOCAL_VERSION → v$REMOTE_TAG. Run /upgrade to see details.`，但 skill 的完整输出使用不同格式。

### L2：Wiki 的 `log.md` 只有一条初始化记录

`[2026-08-15] ingest | Initialize EricStack knowledge base...`

---

## 五、已验证通过的模块

| 模块 | 状态 |
|---|---|
| `.loopx/VERSION` | ✅ v0.1.0，格式正确 |
| `.loopx/sync-state.json` | ✅ schema 正确，commit hash 匹配 |
| `sync-skills.sh --check` | ✅ 正常输出两个 UP-TO-DATE |
| `.gitignore` | ✅ 正确排除 `.omc/`、`target/`、`.codex/` |
| `LICENSE` | ✅ MIT 许可证 |
| `README.md` / `README_CN.md` | ✅ 完整双语，结构良好 |
| `docs/TUTORIAL.md` | ✅ 13.7KB，内容完整 |
| `INTEGRATION.md` | ✅ 完整记录了整合方案 |
| `erics-loop-router` | ✅ 路由表完整，auto-check 已实现 |
| Ability skill frontmatter（全部 16 个） | ✅ 都有 name/description/triggers |

---

## 六、修复优先级排序

| 优先级 | 问题 | 预计工时 |
|---|---|---|
| P0 | C1 — 所有 process skills 加 `triggers:` | ~30 min |
| P0 | C2 — ability skills 清除 gstack 残留（autoplan/retro/benchmark 别名） | ~60 min |
| P1 | C3 — process skills 修正失效路径引用 | ~30 min |
| P1 | C4 — wiki 补充缺失的根目录文件 | ~15 min |
| P1 | H1 — translate-docs frontmatter 修正 | ~5 min |
| P2 | H2 — 补全触发词 | ~15 min |
| P2 | H3/H4 — health/spec 清理残留路径 | ~20 min |
| P3 | M1/M2 — wiki 扩充 + README 锚点 | ~30 min |
| P3 | M3 — sync-skills --execute 实现 | ~45 min |

---

## 七、验证命令

```bash
# 品牌纯净度检查（应为 0）
rg -l 'gstack-|GStack|garry|Garry' .loopx/skills/

# 技能发现性检查（process 应有 triggers，ability 也应完整）
rg '^triggers:' .loopx/skills/erics-process/*/SKILL.md | wc -l   # 期望: 11
rg '^triggers:' .loopx/skills/erics-ability/*/SKILL.md | wc -l  # 期望: 16

# 更新机制验证
bash .loopx/bin/sync-skills.sh --check

# Wiki 完整性
find .loopx/wiki -name '*.md' | wc -l  # 期望: ≥8
```
