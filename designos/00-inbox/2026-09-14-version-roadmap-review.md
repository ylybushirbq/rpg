# 《烬火旅团》既有规格审核 → 分阶段改写计划

| 项目 | 内容 |
| --- | --- |
| 日期 | 2026-09-14 |
| skill | `$game-design-proposal-writer`（经 `$ember-brigade-gamedesignos` 路由） |
| 模式 | `proposal_review_and_rewrite` + `milestone_gate_plan` |
| 状态 | **提案已接受**（OPT-001）。实现仍不覆盖 `docs/v1.0` 玩法正文 |
| 可读版 | [08-exports/ember-brigade-version-roadmap.md](../08-exports/ember-brigade-version-roadmap.md) |
| 决策对象 | [DEC-VERSION-ROADMAP-001](../01-decisions/DEC-VERSION-ROADMAP-001.json) |

本文先审核现有文档，再给出改写方向。正式阶段表、通过/失败标准、投入条件以导出稿为准。

---

## Case Visibility

| 字段 | 值 |
| --- | --- |
| case_visibility | `private_user_work` |
| output_destination | `internal_review` |
| redaction_required | `false` |

## Proposal Intake

| 字段 | 值 | 来源标签 | 备注 |
| --- | --- | --- | --- |
| project_name | 烬火旅团 | provided | |
| document_mode | proposal_review_and_rewrite | derived | 用户要求基于现有文档重做分阶段计划 |
| target_reader | team / self | assumption | 未指定对外发行读者 |
| document_goal | align_team + plan_slice | derived | 对齐 1.0→3.0 该做什么、何时停 |
| platform | PC，键鼠，简体中文 | provided | 2.0 D15；手柄为预留 |
| business_model | 买断单机，无内购 | provided | 2.0 D12 倾向，未标「已确认」 |
| project_stage | prototype | provided | `game.designos.yaml`；工程几乎仍是空场景 |
| team_profile | unknown | unknown | 按单人/极小团队写周期假设 |
| time_budget | unknown | unknown | 只用相对顺序，不写日历承诺 |
| available_materials | 1.0 / 1.5 / 2.0 规格 + 术语 + 待决策 | provided | 无试玩证据、无竞品证据账本 |
| redaction_required | false | provided | 工作区 visibility=private |

## Source Artifact Inventory

| artifact | status | usable_in_this_doc | notes |
| --- | --- | --- | --- |
| `docs/v1.0/最小可玩需求.md` | available | yes | 当前实现权威。闭环清晰，验收可测 |
| `docs/v1.5/过渡需求.md` | available | yes | 加厚单人。商店、路线、暴击、冷却、两种状态捆在同一版 |
| `docs/v2.0/需求规格说明书.md` | available | yes | 完整小队 RPG。把自身称为「第一期」，与仓库 1.0 撞名 |
| `docs/v2.0/待决策清单.md` | available | yes | D1–D15 仍为倾向，不是已确认 |
| concept brief / player-promise-contract | partial | yes | 散落在 1.0 一句话与 2.0 §2.2，未单独成契约 |
| validation plan | partial | yes | 有验收表，无试玩样本、无 Go/No-Go 投入条件 |
| evidence index / issue cards | missing | no | `designos/03-evidence` 仍空 |
| playable build / gameplay video | missing | no | `新建游戏项目/` 仅有空 `main` 场景 |
| production profile（人力/周期/预算） | missing | no | 周期一律标 assumption |
| 市场/商店页证据 | missing | no | 参考作只作行为参照，不作市场事实 |

上游概念**不是**本轮由 `$game-concept-architect` 新生成；玩家承诺与核心循环从既有规格抽取，证据等级仍为 `provided` / `derived` / `assumption`。

---

## Review Target

| field | value |
| --- | --- |
| document type | GDD / 分期需求（1.0 + 1.5 + 2.0） |
| target reader | 原 2.0 写给产研全角色；1.0/1.5 写给实现 |
| requested outcome | rewrite：多阶段开发目标（1.0 / 1.1 … 3.0） |

## Reader and Decision Fit

三份规格能指导「这一版做什么」，但不能回答「这一版过了之后值不值得开下一版」。

- 1.0 适合开发自己：砍项硬、验收硬。缺：品质阶段、试玩门、失败后是否停。
- 1.5 适合系统策划：规则完整。缺：把经济循环和战斗复杂度捆死，一次失败无法定位。
- 2.0 适合远期愿景。不适合当下排期：把小队、ATB、词缀、羁绊、弱点击破、教学长流程写成同一「第一期」。

读完现文档，读者无法决定：1.0 通关后做 1.5 还是直接上小队；也无法决定 2.0 的「第二期」算 2.x 还是 3.0。

## Structure Diagnosis

| section / claim | issue | severity | fix |
| --- | --- | --- | --- |
| 2.0 §2.4「第一期必须 4 人小队」 | 与仓库现行 1.0（单人）命名冲突 | high | 把「小队成立」改名为 2.0 大版本，不再叫第一期 |
| 2.0 §16.2「第二期」无版本号 | 转职、打造、多章节、召唤、NG+ 无处安放 | high | 升格为 3.0，并再切 Post-launch |
| 1.0 → 1.5 中间无小版本 | 1.0 明确「占位图即可」，直接加商店/暴击/状态 | medium | 插入 1.1 品质门；建议再拆 1.2 经济与 1.5 战斗 |
| 1.5 把商店+6 节点+暴击+CD+状态一次交付 | 验证对象混杂 | high | 提案拆 1.2 / 1.5；可在 Human Gate 拒绝拆分 |
| 2.0 把 ATB、站位、羁绊、词缀、击破并列 | 每个都能单独改战斗阅读方式 | high | 2.0 只证明「第二人改变战斗」；其余进 2.1/2.5/3.0 |
| 玩家承诺出现在 2.0 很后面的完整系统里 | 1.0 承诺是单人三条资源，2.0 承诺是小队 | medium | 按时代写承诺，禁止用 2.0 承诺验收 1.0 |
| 无 proof of play | 工程未形成可玩包 | high | 下一投入只能是 1.0，不能是 2.0 切片 |
| 参考作写成目标玩家 | 《最终幻想》《歧路旅人》《石中诗》无评论/试玩证据 | medium | 降为行为参照，删市场断言 |

## Evidence and Assumption Problems

| claim | current status | required evidence | rewrite action |
| --- | --- | --- | --- |
| 目标玩家喜欢可读规则的小队 RPG | assumption（2.0 §3.1） | 1.0/1.5 单人循环先成立 | 标明 assumption；2.0 开门条件改为「单人循环值得重复」 |
| 三条资源是战斗节奏差异点 | provided 为设计意图，untested | 1.0 试玩：能否解释怒技窗口 | 保持为 1.0 最危险假设 |
| 小队比个人更强 | provided 为 2.0 承诺，untested | 2.0 切片：第二人是否改变决策 | 禁止在 1.x 实现队友 |
| 买断 PC 单机 | provided 倾向 D12/D15 | 发行前再确认 | 保持；不据此加内购/手机主操作 |
| 2.0 内容下限（4 职、12 节点、12 饰品…） | assumption / 生产未知 | 团队产能 | 降为 3.0 内容预算，不当前期验收 |

## Scope and Production Risks

| item | risk | scope decision | validation |
| --- | --- | --- | --- |
| 直接按 2.0「第一期」开工 | 单人循环未证就上编制，项目会变成功能堆 | Park 2.0 直到 1.5 门通过 | 1.0/1.5 试玩 |
| 1.5 一次加五种系统 | 不好玩时不知道砍商店还是砍状态 | 建议拆 1.2 / 1.5 | 分别设通过标准 |
| ATB + 命中闪避 + 弱点击破同时做 | 战斗从「整数必中」变成另一款游戏 | ATB/击破进 3.0 或 Parked | 2.0 仍用速度先手、必中 |
| 词缀/套装/强化 | 数值膨胀，掩盖循环问题 | 3.0 再开 | 2.x 继续固定数值装备 |
| 人力/周期未知 | 任何「N 周做完 2.0」都是假精度 | 只写顺序与门，不写日历 | 每门过后再估下一门 |

## Missing Proof / Missing Decisions

- 没有可玩包、没有 5 人试玩、没有失败归因记录。
- D12/D13/D15 仍是倾向。
- 未决定：1.5 是否拆分；2.0 出战人数从 2 还是从 4 起；ATB 是否永远不做。
- 未决定：3.0 是「可发布的内容体量」还是「系统再开一档」。

## Revision Plan

| action | keep / rewrite / cut / research | reason |
| --- | --- | --- |
| 1.0 闭环、砍项表、验收 V1-01～V1-11 | keep | 已可实现、可测 |
| 1.5 规则本文 | keep as later spec | 不删规则，只改「何时做哪一段」 |
| 2.0 体验承诺三条 | keep，但按时代拆开 | 第 1 条属于 2.0，第 2–3 条 1.0 就要开始验 |
| 版本命名「2.0 第一期」 | rewrite | 改为 1.x 单人时代 / 2.x 小队时代 / 3.0 长线时代 |
| 插入 1.1 品质门 | rewrite | 1.0 自己写了占位图；需要可玩性门 |
| 建议拆 1.2 经济循环 vs 1.5 战斗加厚 | rewrite | 降低一次失败的定位成本 |
| 2.0 重切为「第二人改变战斗」 | rewrite | 这是新 design nucleus，必须单独证明 |
| 2.0 内容下限表 | cut from near-term | 挪到 3.0 内容预算 |
| ATB、击破、词缀、转职、打造、NG+ | cut from 2.0 | 进 3.0 或 Parked |
| 市场蓝海/愿望单 | cut | 无证据 |
| 1.0 是否好玩 | research | 最小试玩，见 EXP-LOOP-1.0-001 |

## Change Log

| original | changed to | reason |
| --- | --- | --- |
| 2.0 自称第一期 = 4 人小队完整 RPG | 2.0 = 小队成立切片（建议 2 人出战） | 消除与 1.0 冲突，缩小证明对象 |
| 2.0 第二期无版本 | 3.0 长线内容 + 3.x / Post-launch | 给转职、多章节、打造安家 |
| 1.0 之后直接 1.5 | 1.0 → 1.1 →（建议 1.2）→ 1.5 | 品质与系统分开验收 |
| 无 1.1 | 1.1 = 可读性/手感/存档品质，不加玩法 | 让人能玩完 1.0 再谈系统 |
| 商店+暴击+状态 = 同一版 | 提案：1.2 商店与路线，1.5 暴击/CD/状态 | 一次只验一个 nucleus |
| 实现范围含糊 | 代码范围仍锁 1.0，直到人接受本路线图并改规格 | 遵守项目约定 |

## Remaining Unknowns

| unknown | impact | needed_by | how_to_resolve |
| --- | --- | --- | --- |
| 团队规模与每周可投入时间 | 所有周期数字 | 接受路线图之后 | 人填写；在此之前禁止日历承诺 |
| 1.0 战斗是否被理解、是否想再打 | 是否开 1.1/1.5 | 1.0 验收后 | EXP-LOOP-1.0-001 |
| 是否接受拆 1.5 | 1.2 是否存在 | Human Gate | DEC-VERSION-ROADMAP-001 OPT-002 |
| 2.0 从 2 人还是 4 人起步 | 2.0 工期与风险 | 1.5 通过后 | 默认建议 2 人 |
| 美术管线（立绘/简模/像素） | 1.1 品质上限 | 1.1 前 | D13 仍为倾向 |
| 是否做 Steam 发行 | 3.0 内容与 demo 定义 | 2.5 前后 | needs_research，现在 VOI 不足 |

---

改写正文见导出稿。默认动作：**只实现 1.0**；本文件被接受前，1.1 也不进入 `新建游戏项目/`。
