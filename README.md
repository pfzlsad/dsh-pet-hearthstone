# dsh-pet 炉石模式 + 出牌教练（个人备份）

> 基于 [dsh-pet](https://github.com/PC2005-cloud/dsh-pet) **v0.3.8** 的个人修改版备份。
> 上游 MIT License © 2026 PC2005-cloud；本仓库只是加了两块功能的补丁，非官方版本。

- 备份日期：2026-10-24
- 上游版本：`dsh-pet@0.3.8`
- 运行环境：DSH（DeepSeek Harness）桌面版，Web GUI 内嵌桌宠

## 功能

| 功能 | 行为 |
| --- | --- |
| **炉石模式** | 碎碎念不再用「人设」，改用炉石梗（卡牌台词 / 主播名场面 / 天梯吐槽），20 字以内一句 |
| **随炉石自动切换** | 每 8 秒检测一次炉石进程：游戏启动自动开、退出自动关，并写回用户配置 |
| **出牌教练** | 后台盯日志：轮到我方出牌阶段自动给**一句** 30 字以内建议；对手回合自动解说/预测；也可随时按快捷键再问 |

作用范围：炉石模式只影响碎碎念；教练每 2 秒看一眼日志（文件没更新就跳过），每个「回合 × 阵营」只播一次；对局结束 / 没日志会在气泡里说明。

## 出牌教练怎么工作

```
每 2 秒（文件有更新时）或按快捷键 Ctrl+Alt+H
   → 找最新的 Power.log（D:\Battle.net\Hearthstone\Logs、LocalAppData、Saved Games 都扫）
   → 截出最后一局，解析 CREATE_GAME / FULL_ENTITY / TAG_CHANGE / BLOCK_START
   → 还原：回合、双方英雄血甲、法力、手牌（含卡面文字）、双方场面随从与关键词、奥秘、牌库、最近动作
   → 卡名用 HDT 的 CardDefs.base.xml 补中文（并缓存成 hs-carddb.json）
   → 轮到我方出牌阶段：给一句出牌建议；对手回合：给一句解说/预测
   → 写进桌宠气泡
```

边界：只读日志，不读内存、不注入、不自动操作游戏；只支持构筑（酒馆战棋/竞技场不支持）；结论不保证正确，自己判断。
手动按快捷键时：我方回合给建议，对手回合给解说（可在设置里关掉解说）。

## 配置项（`~/.dsh/dsh-pet/main-config.jsonc`）

| 键 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `hearthstoneMode` | boolean | `false` | 手动开关：碎碎念走炉石语料 |
| `hearthstoneAuto` | boolean | `false` | 按炉石进程自动改 `hearthstoneMode` |
| `hsCoachEnabled` | boolean | `false` | 出牌教练开关（关闭时也会停掉快捷键小助手） |
| `hsCoachHotkey` | string | `"Ctrl+Alt+H"` | 全局快捷键；改了 30 秒内自动重启小助手 |
| `hsLogPath` | string | `""` | 可选：自定义 Power.log 文件/目录；留空自动探测 |
| `hsCoachAutoTurn` | boolean | `true` | 轮到我方出牌阶段自动给建议（每回合一次） |
| `hsCoachOpponentTalk` | boolean | `true` | 对手回合自动解说/预测（每回合一次） |

设置页：设置 → 桌宠 →「炉石模式」卡片里有全部开关 + 快捷键/日志路径输入框（快捷键一般用不到，自动建议已经默认开）。

## 目录结构

```
plugin/                          # 打完补丁的完整 dsh-pet 包（可直接覆盖安装）
patches/hearthstone-mode.patch   # 相对 v0.3.8 的 lib/*.js + config.jsonc 补丁
install.ps1 / install.sh         # 把 plugin/ 装回 DSH profile（含 runtime/coach-hotkey）
```

## 恢复 / 安装

```powershell
# 关掉 DSH 后执行；默认 desktop profile
.\install.ps1
```

```bash
./install.sh
```

装完重启 DSH。注意 `runtime/coach-hotkey/main.cjs` 是教练快捷键要用的小助手，安装脚本会一起拷过去。

## 依赖

- **Electron**：快捷键小助手复用桌宠已经下载好的 `~/.dsh/electron/electron.exe`；没下载过就先在桌宠里开一次桌面模式，或跑 `node scripts/ensure-electron.mjs`。小助手常驻约 150–200MB 内存，教练关闭时会被停掉。
- **HDT 卡牌库（可选）**：`%APPDATA%\HearthstoneDeckTracker\CardDefs\CardDefs.base.xml` 提供中文卡名和卡面文字，首次使用会缓存成 `~/.dsh/dsh-pet/hs-carddb.json`。没有 HDT 也能用，只是卡名回落到日志里的实体名。
- **炉石日志**：客户端自己写，`log.config` 需要 `[Power] Verbose=True`（HDT 会自动配好；本机路径 `D:\Battle.net\Hearthstone\Logs\Hearthstone_<时间戳>\Power.log`）。

## 改了哪些文件

| 文件 | 改动 |
| --- | --- |
| `lib/index.js` | 炉石语料与自动检测；教练核心（日志解析 / 场面快照 / 卡牌库 / 提示词 / `/coach` 路由 / 快捷键小助手管理）；配置字段 |
| `lib/client.js` | 设置页「炉石模式」卡：三个开关 + 快捷键 + 日志路径；页面内快捷键兜底；中英文案 |
| `assets/config.jsonc` | 新增 5 个默认值 + 注释 |
| `runtime/coach-hotkey/main.cjs` | 新增：Electron 无窗口快捷键助手（globalShortcut → POST /coach） |

## 解析修复记录（2026-10-24）

针对「推荐了头上挂着的牌」「对面费用说错」这类问题，定位并修了 4 个解析 bug + 1 个防幻觉机制：

1. `SHOW_ENTITY - Updating Entity=30` 这类**数字引用**以前解析成 id 0，所有揭示/变身都堆到一个幽灵实体上（会把「永恒真爱」这种光环当成手牌）。
2. `FULL_ENTITY - Updating [entityName=UNKNOWN ENTITY [cardType=INVALID] id=71 ...]` 的**嵌套方括号**以前被正则截断，实体更新整条丢失。
3. 炉石会**回收实体 id**：同一个 id 重新 `FULL_ENTITY - Creating` 时现在会清空旧标签，避免已死亡随从「复活」。
4. `TAG_CHANGE` 引用里的 `zone=/player=` 是**改之前的快照**，以前会覆盖真实状态（`ZONE=GRAVEYARD` 之后紧跟的 `HEALTH` 又把随从拉回场上）；现在只用来补空字段。
5. **本地玩家判定**只看换牌阶段（原先整局计分：对手每打一张牌也会先挂 cardId，分高时会把双方认反，费用和手牌就整个对调）。
6. 对手手牌数之前被「只显示有 cardId 的牌」的过滤误伤，永远显示 0；现在按真实张数，只有我方列表过滤看不到的牌。
7. 法力只给**一个**数字：「本回合还能用 X 费」。之前同时给「可用」和「水晶上限」，模型会把两个数**加起来**（2 费说成 4、3 费说成 6、5 费说成 10，正好翻倍）；而只给上限时它又会拿回合数当费用。现在只说还能用多少。

8. 英雄血量 ≤0 也判和对局结束（`PLAYSTATE` 有时只写在 PowerTaskList 里，GameState 会漏）。
9. 建议输出加了**合法性门禁**：提到的牌若不在手牌/场面清单里，带清单重试一次，仍不合格就退回规则兜底；同时要求费用/血量数字照抄局面。

## 已知限制

- 上游升级会覆盖 `lib/*.js` 与 `assets/config.jsonc`，补丁和教练功能都会消失，按上面方式重装。
- 直接改的是发布产物（`lib/*.js`），不是上游 TS 源码；源码在 `plugin/src/` 可对照，但构建链未随包发布。
- 教练只解析 GameState 事件；游戏结束后日志尾部可能只有 PowerTaskList，因此「已结束」判断可能滞后一两条事件。
- 不解析英雄技能冷却、任务进度、对手手牌明细（本来也看不到）。
- 自动播报每回合两次模型调用（我方建议 + 对手解说），想省 token 可以在设置里关掉对手解说。
- 建议仅用于自己练习复盘，正式比赛请遵守赛事规则。

## 免责声明

个人备份用途，与上游项目及暴雪娱乐无关。功能只读取本机日志、不修改游戏、不自动化操作。
