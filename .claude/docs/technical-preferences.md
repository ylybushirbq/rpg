# Technical Preferences

本文件给 Claude Code Game Studios skill 读。编码细则以仓库 `docs/编码风格.md` 为准。

## Engine & Language

- **Engine**: Godot 4.7
- **Language**: GDScript（静态类型）
- **Rendering**: Forward Plus；Windows 可用 D3D12
- **Physics**: Jolt（`project.godot` 已选）。1.0 回合制几乎不用物理

## Input & Platform

- **Target Platforms**: PC
- **Input Methods**: Keyboard/Mouse
- **Primary Input**: Keyboard/Mouse
- **Gamepad Support**: None（1.0）
- **Touch Support**: None
- **Platform Notes**: 简体中文 UI；不按手机主操作设计

## Naming Conventions

- **Classes**: PascalCase（`class_name BattleResolver`）
- **Variables**: snake_case；私有前缀 `_`；智力属性字段 `intl`
- **Signals/Events**: snake_case 过去式（`battle_won`）
- **Files**: snake_case `.gd` / `.tscn` / `.tres`
- **Scenes/Prefabs**: snake_case `.tscn`；节点 PascalCase + `%` 唯一名
- **Constants**: CONSTANT_CASE

## Performance Budgets

- **Target Framerate**: 60
- **Frame Budget**: 回合制，逻辑不走 `_process`；`_process` 默认关掉，只给飘字/条动画
- **Draw Calls**: 1.0 占位 UI，不卡预算
- **Memory Ceiling**: 未设
- **Object pools**: 只池化高频演出节点（飘字 12–16、火花 8、命中音 2–4）。屏幕、角色、Resource、Autoload、`RefCounted` 结算对象禁止入池。1.0 无飘字则不要先做全局池。细则 `docs/编码风格.md` 第 15 节

## Godot MCP

- 场景图 / 跑游戏用 Cursor 的 `godot` MCP（`@coding-solo/godot-mcp`）
- `projectPath` = `新建游戏项目/`；改完 `save_scene`；验证后 `stop_project`
- 不要手改 `.uid`；不要擅自开编辑器；脚本仍手写并遵守 `docs/编码风格.md`

## Testing

- **Framework**: 1.0 以规格验收表为准（V1-01～V1-11）；尚未上 GUT
- **Minimum Coverage**: 核心伤害 / 经验公式可单测后再补
- **Required Tests**: 伤害公式、升级曲线、失败回据点

## Forbidden Patterns

- C# / GDExtension 当主语言
- 在按钮回调里结算伤害
- 实现 1.1 及以后（商店、暴击、状态、队友、ATB、词缀）
- 无类型 GDScript 主代码
- 给整屏 / 角色 / `.tres` / `GameState` 做对象池；池元素 `queue_free` 或 `call("reset")`
- 在 `_process` 里 `$` 找节点

## Allowed Libraries / Addons

- 仅 Godot 4.7 标准库，未批准第三方插件

## Architecture Decisions Log

- 语言：GDScript 静态类型 — `docs/开发技术选型.md`
- 字段映射与目录 — `docs/编码风格.md`

## Engine Specialists

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist
- **Shader Specialist**: godot-shader-specialist（1.0 不用）
- **UI Specialist**: godot-gdscript-specialist
- **Additional Specialists**: 不使用 godot-csharp-specialist / godot-gdextension-specialist
- **Routing Notes**: 所有 `.gd` / `.tscn` 走 GDScript 专家 + `docs/编码风格.md`

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (`.gd`) | godot-gdscript-specialist |
| Shader / material files | godot-shader-specialist |
| UI / screen files | godot-gdscript-specialist |
| Scene / prefab / level files (`.tscn`) | godot-gdscript-specialist |
| Native extension / plugin files | 禁止（1.0） |
| General architecture review | godot-specialist |
