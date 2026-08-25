# Third-Party Licenses

This document lists third-party software incorporated into EricStack, with
their respective licenses and copyright notices.

---

## mindmux-brain-md

- **Upstream**: https://github.com/mindmuxai/brain.md
- **Version vendored**: pinned at commit `dafdde9d9981895b149d6285ef19fa2ea9092747`
  (recorded in `.loopx/sync-state.json#sources.mindmux-brain-md.commit`)
- **License**: Apache License, Version 2.0
- **License URL**: https://www.apache.org/licenses/LICENSE-2.0
- **Stewardship**: MindMux — `https://mindmux.ai`

### Files vendored into EricStack

| Upstream path | EricStack path | SHA-256 |
|---|---|---|
| `skills/brain-page/bin/brain.mjs` | `.loopx/skills/erics-ability/erics-ability-brain-page/bin/brain.mjs` | `224f97fe88b82f4e6c598c336038a0ad306188ed50828bc0c42d88fb7a4a84fe` |
| `skills/brain-page/lib/brain.mjs` | `.loopx/skills/erics-ability/erics-ability-brain-page/lib/brain.mjs` | `b2a739e96c929eb703287f7c52caeca7d3702d67b2e2d447c69ceb4d451fcd33` |
| `skills/brain-setup/assets/BRAIN.md` | `.loopx/skills/erics-ability-brain-setup/assets/BRAIN.md` | `4802eb806582d2a339016aa89d2cb7bd9cd734095f9b1262382bf22d59232112` |
| `skills/brain-setup/hooks/pre-commit` | `.loopx/skills/erics-ability-brain-setup/hooks/pre-commit` | `6e8e9fc7b494f825f7650be51f4a61b49ebb4e0dee5ea0421283cb42a9affe3b` |
| `skills/brain-setup/hooks/session-start` | `.loopx/skills/erics-ability-brain-setup/hooks/session-start` | `c06a880c3e02fc045f666e50dec9482f98b9b30aeeb5b09838337b242c62105a` |

### Runtime layout constraint

The upstream CLI resolves scaffold assets at `<brain-page>/bin/../../brain-setup/assets`.
After install, the following must exist as siblings:

- `~/.claude/skills/erics-ability-brain-page/`
- `~/.claude/skills/erics-ability-brain-setup/`

PR-3 of the integration plan (`install-ericsstack.sh`) is responsible for
materializing this constraint; PR-1 only vendors the source files.

### License text

The full Apache License 2.0 text applies. Per the Apache-2.0 boilerplate
shipped upstream (no `Copyright` line in the LICENSE file itself), the
following notice is reproduced:

> Licensed under the Apache License, Version 2.0 (the "License"); you may not
> use this file except in compliance with the License. You may obtain a copy
> of the License at http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
> WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
> License for the specific language governing permissions and limitations
> under the License.

The full license text (201 lines) is identical to the upstream file at the
pinned commit and may be retrieved directly from
`https://raw.githubusercontent.com/mindmuxai/brain.md/<commit>/LICENSE`.

### Modifications

None. The vendored files are byte-identical to upstream; SHA-256 hashes above
match the upstream copies at the pinned commit. EricStack wraps the CLI via
`erics-ability-brain-init`, `erics-ability-brain-page`,
`erics-ability-brain-bootstrap`, and `erics-ability-brain-ingest` skills but
does not modify the CLI source.

### Bump policy

Vendor bumps are **manual** and triggered by GitHub releases on the upstream
repository. Maintainers follow the six-step procedure documented in
`docs/brain-integration.md` (PR-5). The pinned commit in
`.loopx/sync-state.json` is the source of truth for what is currently vendored.