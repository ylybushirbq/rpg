# 《烬火旅团》路径映射（CCGS）

Claude Code Game Studios 的 skill 写死了一些目录。本项目对照如下，**不要在仓库根再造一套 `src/` 游戏代码**。

| CCGS 默认 | 本仓库实际 |
| --- | --- |
| `src/` | `新建游戏项目/`（Godot 4.7 工程） |
| `design/gdd/game-concept.md` | 本文件旁的概念摘要；玩法权威仍是 `docs/v1.0/最小可玩需求.md` |
| `docs/engine-reference/` | 源仓库 `I:/cursorworkspace/Claude-Code-Game-Studios/docs/engine-reference/godot/`；版本以 4.7 为准 |
| `docs/architecture/` | 需要 ADR 时再建；编码规范用 `docs/编码风格.md` |
| `production/stage.txt` | `production/stage.txt`（已建） |
| `production/epics/` | 跑 `/create-epics` 后再建 |
| `tests/` | 以后再建；1.0 可用手工验收表 V1-01～V1-11 |
| `.claude/skills/` | `I:/cursorworkspace/Claude-Code-Game-Studios/.claude/skills/` |
| `.claude/agents/` | 同上源仓库 |
| `CLAUDE.md` | 仓库根 `CLAUDE.md` |

## 和 GameDesignOS 的分工

| | GameDesignOS | CCGS |
| --- | --- | --- |
| 目录 | `designos/` | `production/`、`design/gdd/`、`.claude/` |
| Skill | `.cursor/skills/game-*` | `$ccgs-studio` → 源仓库 73 个 skill |
| 解决什么 | 这条设计有没有证据、能不能拍板 | 怎么拆 epic、写 story、实现、过 gate、做 QA |

1.0 规格冲突时：`docs/v1.0` > CCGS 模板里的 GDD 八段式扩写。
