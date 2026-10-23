# dsh-pet 炉石模式（个人备份）

> 基于 [dsh-pet](https://github.com/PC2005-cloud/dsh-pet) **v0.3.8** 的个人修改版备份。
> 上游 MIT License © 2026 PC2005-cloud；本仓库只是加了「炉石模式」的补丁，非官方版本。

- 备份日期：2026-10-23
- 上游版本：`dsh-pet@0.3.8`
- 运行环境：DSH（DeepSeek Harness）桌面版，Web GUI 内嵌桌宠

## 这个补丁做了什么

给桌宠的「碎碎念」加了一套炉石梗语料，可以手动开关，也可以跟着炉石客户端自动切换。

| 功能 | 行为 |
| --- | --- |
| **炉石模式** | 开启后碎碎念不再用「人设」，改用炉石梗（卡牌台词 / 主播名场面 / 天梯吐槽 / 酒馆战棋黑话），20 字以内一句，每次引一句原梗或造一句同风格的新梗 |
| **随炉石自动切换** | 每 8 秒检测一次炉石客户端进程（Windows `tasklist`，macOS/Linux `pgrep`，进程名含 `Hearthstone`）：游戏启动 → 自动开启；游戏退出 → 自动关闭，并把状态写回用户配置 |
| 作用范围 | **只影响碎碎念**（周期自动、右键「碎碎念」、`pet` 命令留空）；普通对话人设不变 |

两个开关都在 设置 → 桌宠 → 「炉石模式」卡片里。

语料在 `plugin/lib/index.js` 的 `HEARTHSTONE_LINES` 数组里，一行一条，直接加即可。

## 目录结构

```
plugin/                         # 打完补丁的完整 dsh-pet 包（可直接覆盖安装）
patches/hearthstone-mode.patch  # 相对 v0.3.8 原版的 unified diff（git apply -p1）
install.ps1 / install.sh        # 把 plugin/ 里的文件装回 DSH profile
```

## 恢复 / 安装

### 方式一：直接拷贝（推荐）

```powershell
# 关掉 DSH 后执行；默认装到 desktop profile
.\install.ps1
# 自定义 profile 目录：
.\install.ps1 -ProfileDir "C:\Users\you\.dsh\profiles\desktop"
```

```bash
./install.sh                       # 默认 ~/.dsh/profiles/desktop
./install.sh /path/to/profile
```

装完重启 DSH（主机侧代码在启动时加载）。

### 方式二：在官方包上打补丁

```bash
# 先安装同版本官方包
pnpm add dsh-pet@0.3.8
# 进入 node_modules/dsh-pet，应用补丁
git apply -p1 /path/to/patches/hearthstone-mode.patch
```

## 配置项（用户配置文件 `~/.dsh/dsh-pet/main-config.jsonc`）

| 键 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `hearthstoneMode` | boolean | `false` | 手动开关。开启后碎碎念走炉石语料 |
| `hearthstoneAuto` | boolean | `false` | 自动开关。开启后按炉石进程自动改 `hearthstoneMode` |

自动模式开着时以进程检测为准；关掉自动后检测停止，`hearthstoneMode` 保持最后一次的值。

## 改了哪些文件

| 文件 | 改动 |
| --- | --- |
| `lib/index.js` | 新增 `HEARTHSTONE_LINES` / `HEARTHSTONE_USER_TEXT` / `hearthstonePersona()` / `hearthstoneSystemPrompt()` / `detectHearthstoneProcess()`；`publishWhisper` 按 `hearthstoneOn(conf)` 分支；新增自动检测定时器；配置白名单、校验、保存白名单加两个字段 |
| `lib/client.js` | 设置页新增「炉石模式」卡片（两个开关）；中英文案；读取/保存两个字段 |
| `assets/config.jsonc` | 内置默认值 `hearthstoneMode: false`、`hearthstoneAuto: false` + 注释 |

校验和（SHA-256）：

```
index.js         d6020bfc06721ac0208cc1bfdf831cbf7d31277f3e3e0d4a52511fc4399bcdae
client.js        97075c5ca5d8885f5431b2bc89a5882c4d2eebb1e2272d179bb01278aba07ade
config.jsonc     4433dcdac482c18573e92dee17489788fdecbeba85c29cb13e3d67e062d973db
```

## 已知限制

- **上游升级会覆盖补丁**：dsh-pet 从商城更新后，`lib/*.js` 被整体替换，补丁消失，需要按上面的方式重装。
- 补丁直接改的是**发布产物**（`lib/*.js`），不是上游 TS 源码；上游源码在 `plugin/src/` 里可对照，但没有构建链（tsdown / rolldown 不在发布包里）。
- 自动检测每 8 秒 spawn 一次 `tasklist`（Windows），属于轻量轮询；不需要时会立即停止。
- 计划中的「局势判断 + 出牌推荐」**尚未实现**，本备份只包含炉石语料与自动切换。

## 免责声明

个人备份用途，与上游项目及暴雪娱乐无关。自动检测只读取本机进程名，不改动游戏、不注入内存、不自动操作游戏。
