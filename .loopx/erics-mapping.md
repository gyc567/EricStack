# EricStack 路径锚点映射

> 记录 `erics-process-*` skills 中从 DeepSeek Harness 原始路径到本地 EricStack 路径的重写映射。
> Changelog 在最下方。

---

## 一、Agent Note 路径映射

| 原始 deepseek-harness 路径 | 重写为 | 含义 | 备注 |
|---|---|---|---|
| `../../notes/README.md` | `.loopx/notes/README.md` | Agent Note 写作规则 | EricStack 本地版本；原始规范见 deepseek-harness 原文 |
| `../../notes/archived/AGENTS.md` | `.loopx/notes/archived-AGENTS.md` | 归档 Agent Note 规则 | 同上 |
| `../../notes/implemented/<kind>/<date>-<topic>.md` | `../../notes/implemented/<kind>/<date>-<topic>.md` | 具体 Agent Note | 保持相对路径，原样保留 |

---

## 二、文档路径映射

| 原始 deepseek-harness 路径 | 重写为 | 含义 | 备注 |
|---|---|---|---|
| `../../../docs/AGENTS.md` | `../../docs/AGENTS.md` | EricStack 文档规范 | 若 `docs/AGENTS.md` 不存在，此引用失效 |
| `../../../docs/defensive-patterns.md` | `../../docs/defensive-patterns.md` | 防御编程模式 | 同上 |
| `../../../docs/testing.md` | `../../docs/testing.md` | 测试规范 | 同上 |
| `../../../docs/architecture.md` | `../../docs/architecture.md` | 架构文档 | 同上 |
| `../../../docs/subsystems/README.md` | `../../docs/subsystems/README.md` | 子系统文档 | 同上 |
| `../../../docs/i18n/README.md` | `../../docs/i18n/README.md` | 国际化规则 | 同上 |
| `../../../docs/i18n/translation-rules.md` | `../../docs/i18n/translation-rules.md` | 翻译规则 | 同上 |
| `../../../docs/i18n/terminology.md` | `../../docs/i18n/terminology.md` | 术语表 | 同上 |
| `../../../docs/i18n/translation-prompt.md` | `../../docs/i18n/translation-prompt.md` | 翻译模板 | 同上 |
| `../../../docs/i18n/style-samples.md` | `../../docs/i18n/style-samples.md` | 风格样例 | 同上 |
| `../../../docs/cookbook/adding-a-package.md` | `../../docs/cookbook/adding-a-package.md` | 包添加指南 | 同上 |
| `../../../docs/cookbook/responding-to-pr-review-on-a-stack.md` | `../../docs/cookbook/responding-to-pr-review-on-a-stack.md` | PR stack 响应指南 | 同上 |
| `../../../docs/postmortem/README.md` | `../../docs/postmortem/README.md` | 复盘文档规则 | 同上 |

---

## 三、根目录文档路径映射

| 原始路径 | 重写为 | 含义 | 备注 |
|---|---|---|---|
| `../../../AGENTS.md` | `../../AGENTS.md` | 工程规范 | 若不存在则链接失效 |
| `../../AGENTS.md` | `../AGENTS.md` | 同上（相对路径修正） | 同上 |
| `../../../packages/AGENTS.md` | `../../packages/AGENTS.md` | 包级规范 | 若不存在则链接失效 |

---

## 四、VitePress 文档站路径映射（erics-process-doc-site-sync 专用）

| 原始 deepseek-harness 路径 | 重写为 | 含义 | 备注 |
|---|---|---|---|
| `../../../website/docs.ts` | `../../website/docs.ts` | 文档站 manifest | EricStack 需有 VitePress 站点才有意义 |
| `../../../scripts/project-doc-site.ts` | `../../scripts/project-doc-site.ts` | 文档站 projector | 同上 |
| `../../../website/.vitepress/config.ts` | `../../website/.vitepress/config.ts` | VitePress 配置 | 同上 |

---

## 五、gstack 路径映射（erics-ability 专用）

> gstack skill 的 preamble 已被剥离，以下路径来自 body 内容的引用。
> 这些路径在 gstack 原生环境中指向 `~/.claude/skills/gstack/`。

| gstack 原始路径 | 处理方式 | EricStack 等价 |
|---|---|---|
| `~/.claude/skills/gstack/bin/gstack-update-check` | 删除（gstack CLI 不存在） | 无等价 |
| `~/.claude/skills/gstack/bin/gstack-config` | 删除（gstack CLI 不存在） | 无等价 |
| `~/.claude/skills/gstack/bin/gstack-session-kind` | 删除（gstack CLI 不存在） | 无等价 |
| `~/.claude/skills/gstack/freeze/bin/check-freeze.sh` | 删除（freeze hook 不需要） | 无等价 |
| `~/.gstack/sessions/` | 删除（session 追踪不需要） | 无等价 |
| `~/.gstack/projects/{slug}/learnings.jsonl` | 保留但不执行 | gbrain 跨会话记忆；静默降级 |
| `~/.gstack/analytics/eureka.jsonl` | 保留但不执行 | 同上 |

---

## 六、替换记录

### erics-process-archive-notes
- `../../notes/README.md` → `.loopx/notes/README.md`
- `../../notes/archived/AGENTS.md` → `.loopx/notes/archived-AGENTS.md`

### erics-process-code-review
- `../../../AGENTS.md` → `../../AGENTS.md`
- `../../../packages/AGENTS.md` → `../../packages/AGENTS.md`
- `../../../docs/defensive-patterns.md` → `../../docs/defensive-patterns.md`
- `../../../docs/AGENTS.md` → `../../docs/AGENTS.md`
- `../../notes/README.md` → `.loopx/notes/README.md`

### erics-process-doc-standards
- `../../../docs/AGENTS.md` → `../../docs/AGENTS.md`
- `../../notes/README.md` → `.loopx/notes/README.md`
- `../../../docs/i18n/README.md` → `../../docs/i18n/README.md`
- `../../../AGENTS.md` → `../../AGENTS.md`
- `../../notes/archived/AGENTS.md` → `.loopx/notes/archived-AGENTS.md`

### erics-process-find-simplifications
- `AGENTS.md` → `../../AGENTS.md`
- `../../../docs/defensive-patterns.md` → `../../docs/defensive-patterns.md`
- `../../../docs/testing.md` → `../../docs/testing.md`
- `../../../docs/architecture.md` → `../../docs/architecture.md`
- `../../notes/README.md` → `.loopx/notes/README.md`
- `../../notes/implemented/simplification/` → `../../notes/implemented/simplification/`
- `../../notes/implemented/architecture/` → `../../notes/implemented/architecture/`
- `../../notes/implemented/process/` → `../../notes/implemented/process/`

### erics-process-doc-site-sync
- `../../../website/docs.ts` → `../../website/docs.ts`
- `../../../scripts/project-doc-site.ts` → `../../scripts/project-doc-site.ts`
- `../../../website/.vitepress/config.ts` → `../../website/.vitepress/config.ts`
- `../../../docs/AGENTS.md` → `../../docs/AGENTS.md`

### erics-process-trim-cot-leakage
- `../../notes/implemented/process/2026-08-09-committed-artifact-citations.md` → `../../notes/implemented/process/2026-08-09-committed-artifact-citations.md`
- `../../../docs/AGENTS.md` → `../../docs/AGENTS.md`

### erics-process-translate-docs
- `../../../docs/i18n/README.md` → `../../docs/i18n/README.md`
- `../../../docs/i18n/translation-rules.md` → `../../docs/i18n/translation-rules.md`
- `../../../docs/i18n/terminology.md` → `../../docs/i18n/terminology.md`
- `../../../docs/i18n/translation-prompt.md` → `../../docs/i18n/translation-prompt.md`
- `../../../docs/AGENTS.md` → `../../docs/AGENTS.md`
- `../../notes/implemented/process/2026-07-26-briefed-minimal-translation-updates.md` → `../../notes/implemented/process/2026-07-26-briefed-minimal-translation-updates.md`

---

## 七、Changelog

| 日期 | 操作 | 操作用户 |
|---|---|---|
| 2026-08-15 | 初始映射表创建，版本快照取自 deepseek-harness master + gstack main | ericstack-goal |
