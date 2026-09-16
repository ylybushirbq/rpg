---
name: ccgs-studio
description: Routes 《烬火旅团》 production work to Claude Code Game Studios skills (start, help, setup-engine, adopt, create-epics, create-stories, dev-story, story-done, design-system, prototype, gate-check, code-review, sprint-plan, ux-design, vertical-slice, smoke-check). Use when the user types /start, /dev-story, /help, mentions CCGS, Claude Code Game Studios, epics, stories, or studio workflow.
---

# 烬火旅团 × Claude Code Game Studios

完整 skill 正文**不要复制进本仓库**。用户点名 `/skill-name` 或 `Use $ccgs-studio <skill>` 时：

1. 先读 `docs/CCGS使用说明.md` 和 `.claude/docs/ember-brigade-path-map.md`
2. 再读 `I:/cursorworkspace/Claude-Code-Game-Studios/.claude/skills/<skill-name>/SKILL.md`
3. 按路径映射执行；冲突时以《烬火旅团》1.0 规格和 `docs/编码风格.md` 为准

源仓库：`I:/cursorworkspace/Claude-Code-Game-Studios`  
Agent 定义：`.claude/agents/`（相对源仓库）  
工作流目录：`.claude/docs/workflow-catalog.yaml`

## 权威边界

- 当前实现范围 **1.0**：`docs/v1.0/最小可玩需求.md`
- 游戏代码写在 `新建游戏项目/`，不是 CCGS 默认的 `src/`
- 设计验证用 GameDesignOS（`designos/`、`$game-concept-architect` 等）；CCGS 管制作流程（epic / story / sprint / 实现 / QA）
- 未经用户明确要求，不把 1.1 / 1.2 / 1.5 / 2.0 功能写进代码
- Cursor 里用户已明确要求实现时可以直接改代码；不要为每个小改动重复走 CCGS「先问再写」

## 斜杠命令 → skill 目录

把 `/start` 理解成 skill 名 `start`。常用：

| 用户说 | 读取 |
| --- | --- |
| `/start` 第一次开工作室流程 | `.../skills/start/SKILL.md` |
| `/help` 下一步做什么 | `.../skills/help/SKILL.md` |
| `/adopt` 把现有文档接上模板 | `.../skills/adopt/SKILL.md` |
| `/setup-engine` | 本项目已定为 Godot 4.7 + GDScript，只核对 `.claude/docs/technical-preferences.md` |
| `/create-epics` `/create-stories` `/dev-story` `/story-done` | 对应 skill；故事实现落在 `新建游戏项目/` |
| `/gate-check` `/code-review` `/smoke-check` `/prototype` | 对应 skill |
| `/design-system` | 新系统文档可写 `design/gdd/`，但玩法数字以 `docs/v1.0` 为准 |

Godot 代码请对照源仓库 `godot-gdscript-specialist` agent，并遵守 `docs/编码风格.md`。改场景 / 跑游戏用 Cursor 的 Godot MCP，不要把玩法堆进 `main.tscn`。
