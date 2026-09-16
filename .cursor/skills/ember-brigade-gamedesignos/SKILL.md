---
name: ember-brigade-gamedesignos
description: Routes 《烬火旅团》 design work to GameDesignOS specialist skills and the designos workspace. Use when the user talks about concept, GDD, experience analysis, ED experiments, proposals, design sources, translation, VOI/Human Gate, or GameDesignOS.
---

# 烬火旅团 × GameDesignOS

先读 `docs/GameDesignOS使用说明.md`。完整 skill 正文在 `.cursor/skills/<name>/SKILL.md`。

## 权威边界

- 当前实现范围是 **1.0**：`docs/v1.0/最小可玩需求.md`
- 设计分期以 `docs/版本地图.md` 为准；GameDesignOS 产出写到 `designos/`，不要直接覆盖 1.0 规格
- 未经用户明确要求，不把商店、暴击、状态、队友、ATB、词缀写进实现
- 承诺级决策必须停在 Human Gate，agent 只提案

## 路由

| 用户在做什么 | 调用 |
| --- | --- |
| 一句话创意、核心循环、scope、验证计划 | `$game-concept-architect` |
| 截图 / 录屏 / PV / 竞品拆解 | `$game-experience-analyzer` |
| 首局节奏、留存、体验浓度、一周实验 | `$game-experience-density-optimizer` |
| 立项案、pitch、可评审策划案 | `$game-design-proposal-writer` |
| 英文设计书/章节翻译润色 | `$game-design-book-translator` |
| 文章/UP主/专栏入库 | `$game-design-source-curator` |
| 改 agent 流程、VOI、意图单、回滚 | `$paranoia-ai-system-evolver` |

一句话创意要成正式策划案时：先 architect，再 proposal-writer，不要跳过。

## 落盘

- 草稿：`designos/00-inbox/`
- 决策/假设/证据/实验：`designos/01-decisions/` 起对应目录
- 导出给外人看：`designos/08-exports/`
- 代码仍按 `docs/编码风格.md` 写在 `新建游戏项目/`
- 拆 epic / 实现 / QA 用 `$ccgs-studio`，不要和本 skill 的设计验证目录混用
