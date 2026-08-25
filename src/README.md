# `src/` — Rust Placeholder

## Why this exists | 为什么要保留这个目录

EricStack is a **skill metadata project + engineering toolkit**, not a Rust application.
This `src/` directory exists for two reasons:

1. **Cargo workspace root** — the `Cargo.toml` at the repo root requires a `src/` to be a valid Rust crate. The `fn main() { println!("Hello, world!") }` placeholder satisfies that.
2. **Convention anchor** — many tools (Graft, loopx, rust-analyzer) expect a `src/` layout to detect a Rust project.

EricStack 是**技能元项目 + 工具集**，不是 Rust 应用。`src/` 目录存在的两个原因：

1. **Cargo 工作区根** — 根目录的 `Cargo.toml` 需要 `src/` 才是合法的 Rust crate。`fn main() { println!("Hello, world!") }` 是满足该要求的占位符。
2. **约定锚点** — 许多工具（Graft、loopx、rust-analyzer）依赖 `src/` 布局检测 Rust 项目。

## What this is NOT | 这**不是**什么

- ❌ Not a runnable EricStack application
- ❌ Not the implementation of any EricStack skill
- ❌ Not where acceptance tests or examples live

- ❌ 不是可运行的 EricStack 应用
- ❌ 不是任何 EricStack skill 的实现
- ❌ 不是验收测试或示例代码的存放位置

## What you should do | 你应该做什么

For your own project that uses EricStack skills:

- Use **your own** `src/` with your application code.
- Run `cargo test` (or your framework's test command) so `erics-process-mutation` has something to mutate.
- Add `.feature` files at the project root or under `features/` for BDD workflows.

对于使用 EricStack skills 的你自己的项目：

- 使用**你自己的** `src/` 存放应用代码。
- 运行 `cargo test`（或所用框架的测试命令），让 `erics-process-mutation` 有可变异的目标。
- 在项目根或 `features/` 下添加 `.feature` 文件以使用 BDD 工作流。

## See also | 参见

- [`README.md`](../README.md) — Project Positioning
- [`docs/APS_INTEGRATION.md`](../docs/APS_INTEGRATION.md) — Acceptance pipeline requires *your* code
- [`docs/TUTORIAL.md`](../docs/TUTORIAL.md) — 5-minute walkthrough
