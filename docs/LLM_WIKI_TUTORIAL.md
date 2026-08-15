# LLM Wiki 整合教程 — EricStack 知识库使用指南

> 本教程说明如何将 llm_wiki 作为 EricStack 的知识库使用。
> 整合日期：2026-08-15 | EricStack v0.1.0

---

## 目录

1. [什么是 llm_wiki](#1-什么是-llm_wiki)
2. [为什么需要知识库](#2-为什么需要知识库)
3. [快速开始](#3-快速开始)
4. [目录结构](#4-目录结构)
5. [核心概念](#5-核心概念)
6. [日常使用流程](#6-日常使用流程)
7. [在 llm_wiki App 中使用](#7-在-llm_wiki-app-中使用)
8. [在 Claude Code 中使用](#8-在-claude-code-中使用)
9. [知识管理规范](#9-知识管理规范)
10. [常见问题](#10-常见问题)

---

## 1. 什么是 llm_wiki

[llm_wiki](https://github.com/nashsu/llm_wiki) 是基于 [Karpathy's LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的桌面应用。

**核心理念：** 知识不是每次 query 重新检索的（RAG），而是**持久化、持续维护**的 wiki 页面。

```
传统 RAG：
  query → 检索 → 生成回答 → 每次重新来过

LLM Wiki：
  Ingest（摄入） → 持久 wiki 页面 → Query 时直接读 wiki → 知识持续积累
```

---

## 2. 为什么需要知识库

EricStack 有 27 个 skills，每个 skill 都是一个工程流程的最佳实践。如果没有知识库：

- 每次 session 结束后决策消失
- 团队成员无法复用之前的工程判断
- review 发现的问题没有持久记录

有了知识库：

```
EricStack session → 决策沉淀到 wiki → 下次 session 可查询 → 知识 compounding
```

---

## 3. 快速开始

### 3.1 下载安装 llm_wiki

```bash
# macOS
brew install --cask llm-wiki

# 或从 releases 下载
https://github.com/nashsu/llm_wiki/releases
```

### 3.2 打开 EricStack 项目

1. 启动 llm_wiki
2. `File → Open Project`
3. 选择 `EricStack` 根目录（不是 `.loopx/wiki/`）

llm_wiki 会自动识别 `.loopx/wiki/` 作为知识库目录。

### 3.3 配置 LLM Provider

1. 打开 `Settings`
2. 选择 LLM provider（OpenAI / Anthropic / DeepSeek 等）
3. 填入 API key

### 3.4 开始使用

在 chat 中直接提问：

```
你：EricStack 有哪些纪律技能？
→ LLM 读取 .loopx/wiki/ 相关页面，合成回答

你：这个 PR 的架构选择合理吗？
→ LLM 结合 skills 和 wiki 中的工程原则作答
```

---

## 4. 目录结构

```
.loopx/wiki/
├── index.md          # 知识库总索引（skills、决策、概念目录）
├── overview.md       # 项目概览（LLM 自动维护）
├── purpose.md        # EricStack 目标声明
├── schema.md         # wiki 写作规范
├── log.md            # 操作历史（每次 ingest/query 追加）
│
├── concepts/         # 概念页：流程、设计模式、工程原则
│   ├── loop-engineering.md
│   ├── boil-the-ocean.md
│   ├── agent-notes.md
│   ├── code-review.md
│   └── ...
│
├── entities/         # 实体页：决策记录、人物、特性
│   ├── decision/
│   │   ├── loopx-architecture.md
│   │   └── skill-naming.md
│   └── ...
│
├── sources/          # 知识源：架构文档、会议纪要
│   ├── INTEGRATION.md
│   └── ...
│
├── queries/          # Q&A 对：常见问题与经验证答案
│   ├── when-to-use-process-vs-ability.md
│   └── how-to-add-new-skill.md
│
└── comparisons/      # 技术选型对比
```

---

## 5. 核心概念

### 5.1 Ingest（摄入）

当向 chat 提供新内容时，LLM 会自动：

1. 读取源文件（PR 描述、Agent Note、架构文档）
2. 创建/更新对应的 entity 或 concept 页面
3. 更新 `index.md`
4. 追加到 `log.md`

**触发方式：** 向 chat 提供内容并说"把这个记入 wiki"

### 5.2 Query（查询）

当向 chat 提问时：

1. LLM 搜索 `.loopx/wiki/` 下的相关页面
2. 合成带引用的回答
3. 如果发现知识空白，将结果存入 `queries/`

### 5.3 Lint（健康检查）

定期检查 wiki 健康度：

```
1. 孤立页面（无入链）→ 是否还需要？
2. 失效的 wikilink → 更新引用
3. 过期内容（>90 天未更新）→ 是否还准确？
4. 重复主题 → 合并
```

---

## 6. 日常使用流程

### 场景 A：Review 后记录决策

```
你：把这次 code review 的关键发现记入 wiki
→ LLM 创建 entities/decision/YYYY-MM-DD-review-*.md
→ 更新 index.md 的 Key Decisions
→ 追加到 log.md
```

### 场景 B：遇到问题后沉淀

```
你：debug 这个 bug 时发现了什么？把它记入 wiki
→ LLM 创建 entities/decision/YYYY-MM-dd-bug-*.md
→ 记录根因和解决方案
```

### 场景 C：查询历史决策

```
你：这个项目之前是怎么处理 auth 的？
→ LLM 搜索 entities/decision/ 中的 auth 相关记录
→ 合成回答并引用来源
```

---

## 7. 在 llm_wiki App 中使用

### 7.1 Chat 界面

```
┌─────────────────────────────────────────────┐
│  EricStack Knowledge Base                   │
├─────────────────────────────────────────────┤
│  你：EricStack 的 skill 路由规则是什么？     │
│                                             │
│  AI：根据 erics-loop-router/SKILL.md，      │
│     路由规则如下...                          │
│                                             │
│  你：帮我把这次 retro 的 action items 记入wiki│
│  → AI 执行 ingest，更新相关页面              │
└─────────────────────────────────────────────┘
```

### 7.2 知识图谱界面

在右侧面板可以看到：
- 所有页面的关系图
- 入链/出链统计
- 孤立页面标记

### 7.3 手动编辑

也可以直接编辑 `.loopx/wiki/*.md` 文件，llm_wiki 会自动重新索引。

---

## 8. 在 Claude Code 中使用

### 8.1 直接读取 wiki 内容

```bash
cat .loopx/wiki/concepts/code-review.md
cat .loopx/wiki/entities/decision/loopx-architecture.md
```

### 8.2 调用 skill 时自然沉淀

```
你：帮我 review 这个 PR，然后把关键发现记入 wiki
→ 运行 erics-process-code-review
→ 结果自然沉淀到 entities/decision/
```

### 8.3 定期知识整理

每隔一周，运行一次 wiki lint：

```bash
# 检查孤立页面
for f in .loopx/wiki/**/*.md; do
  links=$(rg '\[\[|\]\(' "$f" | wc -l)
  inlinks=$(rg -l "\[\[$f\]\]" .loopx/wiki/ | wc -l)
  if [ "$links" -gt 0 ] && [ "$inlinks" -eq 0 ]; then
    echo "Orphan: $f"
  fi
done
```

---

## 9. 知识管理规范

### 9.1 页面命名

| 类型 | 格式 | 示例 |
|---|---|---|
| Concept | `kebab-case.md` | `loop-engineering.md` |
| Decision | `decision/YYYY-MM-DD-topic.md` | `decision/2026-08-15-pr-describe.md` |
| Query | `queries/question-topic.md` | `queries/when-to-use-process-vs-ability.md` |
| Entity | `entities/person-or-feature.md` | `entities/autoplan-skill.md` |

### 9.2 Wikilink 格式

```markdown
# 同一目录
[[another-page]]

# 不同目录
[[concepts/loop-engineering]]
[[entities/decision/2026-08-15-pr-review]]

# 带显示文本
[[loop-engineering|Loop Engineering 概念]]
```

### 9.3 Frontmatter

所有页面应有 frontmatter：

```yaml
---
name: page-name
created: 2026-08-15
updated: 2026-08-15
tags: [review, architecture]
---
```

### 9.4 日志追加

每次 ingest 或 significant query 后，在 `log.md` 追加：

```markdown
[2026-08-15] ingest | decision/2026-08-15-pr-review.md | Code review key findings
```

---

## 10. 常见问题

### Q: llm_wiki 找不到知识库？

确保打开的是 `EricStack` 根目录，而不是 `.loopx/` 或 `.loopx/wiki/`。

### Q: wiki 内容与实际不符？

手动编辑 `.loopx/wiki/` 下的文件，或让 LLM 在 chat 中更新。

### Q: 如何导出 wiki 数据？

直接复制 `.loopx/wiki/` 目录即可。纯 markdown，无依赖。

### Q: 多人协作时 wiki 如何同步？

`.loopx/wiki/` 目录在 git 中，可以随项目一起 push/pull。多人协作时：每个成员的 llm_wiki 对同一个 git 仓库操作，log.md 记录每次变更。

### Q: wiki 与 skill 的区别是什么？

| | Skill | Wiki |
|---|---|---|
| 本质 | 可执行的工作流 | 知识沉淀 |
| 更新 | 编辑 SKILL.md | 通过 chat ingest 或直接编辑 |
| 用途 | 执行任务 | 查询历史、积累知识 |
| 关系 | wiki 记录 skill 的使用经验和决策 | — |

---

## 相关文档

- [LLM Wiki 整合说明](../.loopx/llm-wiki-integration.md)
- [完整使用教程](./TUTORIAL.md)
- [技能索引](../.loopx/erics-skills-index.md)
- [Karpathy's LLM Wiki 原始设计](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
