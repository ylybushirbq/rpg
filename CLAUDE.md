# 烬火旅团 — Studio 配置（Cursor + CCGS）

本仓库用 Godot 4.7 做《烬火旅团》1.0。Claude Code Game Studios 的 73 个 skill **不复制进来**，从本机源仓库读取：

`I:/cursorworkspace/Claude-Code-Game-Studios`

Cursor 入口 skill：`$ccgs-studio`。用法：`docs/CCGS使用说明.md`。路径对照：`.claude/docs/ember-brigade-path-map.md`。

## Technology Stack

- **Engine**: Godot 4.7
- **Language**: GDScript（静态类型）
- **Version Control**: Git
- **Game project**: `新建游戏项目/`
- **Playable spec**: `docs/v1.0/最小可玩需求.md`
- **Version map**: `docs/版本地图.md`（OPT-001；1.1 及以后未开工）
- **Coding style**: `docs/编码风格.md`（v1.2：对象池、Godot MCP）
- **Godot MCP**: Cursor `godot` server（`.cursor/mcp.json`）；改 `新建游戏项目/` 场景与跑游戏用它，脚本仍手写

## Engine Version Reference

源仓库 `docs/engine-reference/godot/` 按 4.6 标注；本项目钉 **4.7**。API 以 https://docs.godotengine.org/en/4.7/ 为准，不要用训练数据里的旧 Godot 3 / 4.2 签名。

## Technical Preferences

@.claude/docs/technical-preferences.md

## First session

已有规格和引擎。不要当作空白项目跑 `/brainstorm`。下一步：`$ccgs-studio` → `/adopt` 或 `/create-epics`（按 1.0 系统拆），然后 `/create-stories`、`/dev-story`。

## Collaboration

用户明确要求实现时，Cursor Agent 可以直接改 `新建游戏项目/`。设计文档仍先提案再让用户确认。不替用户 commit。
