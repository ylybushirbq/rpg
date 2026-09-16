# Epic: 1.0 最小可玩闭环

> **Layer**: Foundation → Presentation
> **GDD**: `docs/v1.0/最小可玩需求.md`
> **Architecture Module**: `新建游戏项目/`（GameState + data/*.tres + logic + scenes）
> **Status**: In progress
> **Stories**: 见下表

## Overview

打通创建角色 → 据点 → 加点/换装 → 1v1 四节点战斗 → 经验/金币/固定掉落 → 存档。验收对照 V1-01～V1-11。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| N/A | 本仓库以 `docs/编码风格.md` 与 1.0 规格代替 ADR | LOW |

## Definition of Done

- V1-01～V1-11 可手工走通
- 数值来自 `.tres`，结算不在按钮回调里
- 1.1 及以后功能未实现

## Stories

| # | Story | Type | Status | 规格 |
|---|-------|------|--------|------|
| 001 | 创建角色与存档结构 | Integration | Implemented | 第 3、12、14.1 节 |
| 002 | 据点五入口、休息、自动存 | UI | Implemented | 第 10、11、14.2 节 |
| 003 | 加点与派生重算 | Logic | Implemented | 第 5、14.3 节 |
| 004 | 三槽装备穿脱 | Integration | Implemented | 第 7、14.4 节 |
| 005 | 1v1 战斗指令 | Logic | Implemented | 第 8、14.5 节 |
| 006 | 经验、四节点、掉落、金币 | Integration | Implemented | 第 9、14.6 节 |
| 007 | 验收 V1-01～V1-11 | UI | Ready for playtest | 第 15 节 |
