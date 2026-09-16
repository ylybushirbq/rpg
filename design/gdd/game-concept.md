# Game Concept — 烬火旅团

正式玩法规格是 [docs/v1.0/最小可玩需求.md](../../docs/v1.0/最小可玩需求.md)。本文只给 CCGS `/start` `/help` `/adopt` 当索引，不要在这里另写一套规则。

## Overview

单人、PC、键鼠、简体中文。玩家创建卫士或咒术师，在据点换装加点，沿一条 4 战路线打 1v1 回合战斗，升级到 10 级，击败 Boss 烬狼即通关。

## Player Fantasy

自己养成一个角色，三条资源（HP / MP / RG）打得明白，装备和加点能立刻在战斗里看出来。

## Scope

- **Now (1.0)**：无队友、无暴击、无冷却、无商店、无异常状态
- **Later**：见 `docs/版本地图.md`，本阶段不实现

## Engine

Godot 4.7 + 静态类型 GDScript。工程目录：`新建游戏项目/`。
