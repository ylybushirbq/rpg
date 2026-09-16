# Claude Code Game Studios 使用说明（Cursor）

[Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)（CCGS）把一次 AI 会话收成「小型游戏工作室」：73 个流程 skill、49 个角色 agent、阶段门禁。它解决的是**怎么把已定规格做成可拆的任务并实现、评审、过 gate**，不是另写一份玩法。

本仓库采用**指针集成**：skill 正文留在

`I:\cursorworkspace\Claude-Code-Game-Studios`

不往 git 里抄 73 份。Cursor 通过 `$ccgs-studio` 去读它们。

原项目是为 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 的 `/slash` 设计的。在 Cursor 里把 `/dev-story` 说成：

```text
Use $ccgs-studio /dev-story 实现当前冲刺里下一条 1.0 战斗故事。
```

## 和本仓库其它层的关系

| 层 | 管什么 | 不要拿它做 |
| --- | --- | --- |
| `docs/v1.0/` | 游戏做成什么样 | 被 CCGS 模板扩成 2.0 |
| GameDesignOS | 假设 / 证据 / 实验 / 人拍板 | 写 Godot 代码、拆 sprint |
| CCGS | epic、story、实现顺序、QA、架构评审 | 推翻 1.0 范围 |
| `docs/编码风格.md` | GDScript 怎么写 | 被 CCGS 通用 coding-standards 盖掉 |

## 装了什么

| 位置 | 内容 |
| --- | --- |
| `.cursor/skills/ccgs-studio/` | Cursor 路由 skill |
| `.claude/docs/technical-preferences.md` | 已填：Godot 4.7 + GDScript |
| `.claude/docs/ember-brigade-path-map.md` | `src/` → `新建游戏项目/` |
| `design/gdd/` | 概念索引（权威仍在 docs/v1.0） |
| `production/stage.txt` | 当前阶段：Technical Setup |
| `CLAUDE.md` | 给 CCGS skill 读的项目配置 |
| 源仓库 | 73 skills、49 agents、hooks、模板 |

## 工作室在干什么

三层角色（在源仓库 `.claude/agents/`）：

1. **导演**：creative-director / technical-director / producer — 守范围和品质门
2. **部门负责人**：game-designer、lead-programmer、qa-lead 等
3. **专家**：含 **Godot** 一组（`godot-specialist`、`godot-gdscript-specialist`）。本项目不用 Unity / Unreal / C# / GDExtension 专家

73 个 skill 按制作阶段分，完整目录见源仓库 [README Slash Commands](https://github.com/Donchitos/Claude-Code-Game-Studios#slash-commands)。1.0 现阶段真正常用的只有下面这些。

## 1.0 建议怎么喊

当前阶段写在 `production/stage.txt`：**Technical Setup**（规格已有、引擎已定、Hello World 已在、玩法代码未开始）。

用 **Agent** 对话：

```text
Use $ccgs-studio /help
```

按 1.0 系统拆任务（不要重新 brainstorm 世界观）：

```text
Use $ccgs-studio /create-epics 只根据 docs/v1.0 和 design/gdd/systems-index.md 拆 epic。不要加商店、暴击、队友。
```

```text
Use $ccgs-studio /create-stories 把第一个 epic 拆成可实现 story，验收对照 V1-01～V1-11。
```

```text
Use $ccgs-studio /dev-story 实现下一条 story。代码写在 新建游戏项目/，遵守 docs/编码风格.md。
```

```text
Use $ccgs-studio /story-done
```

```text
Use $ccgs-studio /gate-check 检查能否从 Technical Setup 进入 Pre-Production / Production。
```

已有文档要对齐模板时：

```text
Use $ccgs-studio /adopt
```

不要对这个项目跑 `/setup-engine` 去改引擎；已经钉死 Godot 4.7。不要跑 `/brainstorm open` 除非你想另开脑洞（产出应进 `designos/00-inbox/`，不能改 1.0）。

## 路径对照（skill 里写 src/ 时）

| Skill 里写的 | 实际写到 |
| --- | --- |
| `src/` | `新建游戏项目/` |
| `design/gdd/*.md` | 可写摘要；规则以 `docs/v1.0` 为准 |
| `production/epics/` | 跑 create-epics 后创建 |
| `.claude/skills/foo` | `I:\cursorworkspace\Claude-Code-Game-Studios\.claude\skills\foo` |

## Cursor 和 Claude Code 的差别

- Cursor **没有** CCGS 那 12 个 git hook；提交前靠你自己和编码风格检查清单。
- Cursor **不会**自动弹出 Claude Code 的 `/` 菜单；要写 `Use $ccgs-studio /命令`。
- 源仓库若更新 skill，本项目不用再复制，刷新即可（前提是仍放在 `I:\cursorworkspace\Claude-Code-Game-Studios`）。

## 原仓库完整流程

七阶段（Concept → … → Release）和 gate 说明见源仓库 `docs/WORKFLOW-GUIDE.md`。本项目已经走过 Concept / Systems Design（文档在 `docs/`），从 Technical Setup 接着做实现即可。
