# Inbox · 《烬火旅团》

本目录是 GameDesignOS 的收件箱。新想法、截图、竞品链接先丢这里，不要直接改 [docs/v1.0/最小可玩需求.md](../../docs/v1.0/最小可玩需求.md)。

## 收件箱草稿

| 日期 | 路径 | 状态 |
| --- | --- | --- |
| 2026-09-14 | [既有规格审核](./2026-09-14-version-roadmap-review.md) | 已接受 OPT-001。索引见 `docs/版本地图.md` |

## 已经落地的规格（只读入口）

| 层级 | 路径 | 状态 |
| --- | --- | --- |
| 当前开发 | `docs/v1.0/` | 1.0.2，实现以这份为准 |
| 分期索引 | `docs/版本地图.md` | OPT-001 已接受 |
| 随后设计 | `docs/v1.1/`、`docs/v1.2/`、`docs/v1.5/` | 未开发 |
| 2.0 开工范围 | `docs/v2.0/小队切片.md` | 1.5 通过后 |
| 远期愿景 | `docs/v2.0/需求规格说明书.md` | 归档，不按「第一期」开工 |
| 工程 | `docs/编码风格.md`、`docs/开发技术选型.md` | GDScript |

## 本仓库和 GameDesignOS 怎么分工

- **Godot 实现**写在 `新建游戏项目/`，遵守编码风格。
- **已拍板的玩法规则**写在 `docs/v1.0/`。agent 不得用 skill 输出偷偷扩成 1.1 及以后。
- **可验证的设计过程**（假设、证据、实验、Human Gate）写在 `designos/`。
- 七个专家 skill 在 `.cursor/skills/`。对话里用 `Use $skill-name ...` 调用。

用法见 [docs/GameDesignOS使用说明.md](../../docs/GameDesignOS使用说明.md)。
