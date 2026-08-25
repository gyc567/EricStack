# EricStack + LLM Wiki 整合说明

> 整合日期：2026-08-15 | llm_wiki 版本：见 releases

## 什么是 LLM Wiki

LLM Wiki 是基于 [Karpathy's LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的知识库应用。与传统 RAG（每次 query 重新检索）不同，LLM Wiki 是一个**持久化、增量更新**的 wiki 目录——知识被编译一次并持续维护，而不是每次查询重新派生。

EricStack 将 llm_wiki 的知识管理模式引入工程 loop，让每个决策、每次 review、每次讨论都沉淀为持久知识。

## 目录结构

```
EricStack/
├── .loopx/
│   ├── skills/          # 38 LoopX skills
│   ├── wiki/           # LLM Wiki 知识库（可被 llm_wiki app 打开）
│   │   ├── index.md    # 知识库总索引
│   │   ├── log.md      # 操作记录
│   │   ├── overview.md # 项目概览
│   │   ├── entities/   # 实体页：决策、人物、特性
│   │   ├── concepts/   # 概念页：流程、设计模式、工程判断
│   │   ├── sources/    # 知识源：架构文档、会议纪要
│   │   └── queries/    # Q&A：常见问题与答案
│   └── VERSION
└── ...
```

## 在 llm_wiki App 中打开 EricStack

1. 下载 [llm_wiki releases](https://github.com/nashsu/llm_wiki/releases)
2. 安装并启动 llm_wiki
3. `File → Open Project` → 选择 `EricStack` 根目录
4. llm_wiki 会自动识别 `.loopx/wiki/` 作为项目 wiki
5. 在 Settings 中配置 LLM provider（API key）
6. 开始向 chat 提问 — LLM 会自动更新 wiki 页面

## 知识管理模式

### Ingest（摄入）

当向 chat 提供新内容时，LLM 会：
1. 读取源文件
2. 创建/更新对应的 entity 或 concept 页面
3. 更新 `index.md`
4. 追加到 `log.md`

### Query（查询）

当向 chat 提问时：
1. LLM 搜索 `.loopx/wiki/` 下的相关页面
2. 合成带引用的回答
3. 如果发现有知识空白，可将结果存入 `queries/`

### Lint（健康检查）

定期检查：
1. 孤立页面（无入链）
2. 失效的 wikilink
3. 过期内容（>90 天未更新）
4. 重复主题

## 与 llm_wiki App 的 MCP 集成

llm_wiki 提供 MCP server，可以直接用 Claude Code 查询 llm_wiki 项目：

```bash
# 构建 MCP server
cd llm_wiki && npm run mcp:build

# 在 Claude Code 中配置 MCP
# 连接 http://127.0.0.1:19828
```

## LICENSE 说明

EricStack 采用 **MIT License**（见项目根目录 `LICENSE`）。
llm_wiki 本身是 **GPLv3**。两者独立运行，仅通过目录引用交互，不存在源码级别的整合。

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
