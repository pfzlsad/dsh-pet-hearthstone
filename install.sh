#!/usr/bin/env bash
# 把 plugin/ 里打过补丁的 dsh-pet 文件装回 DSH profile。
# 用法：./install.sh [profile目录]  默认 ~/.dsh/profiles/desktop
set -euo pipefail

PROFILE_DIR="${1:-$HOME/.dsh/profiles/desktop}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$PROFILE_DIR/node_modules/dsh-pet"

if [ ! -d "$TARGET" ]; then
  echo "找不到 dsh-pet：$TARGET（先用 DSH 插件市场安装 dsh-pet@0.3.8）" >&2
  exit 1
fi

cp "$ROOT/plugin/lib/index.js"  "$TARGET/lib/index.js"
cp "$ROOT/plugin/lib/client.js" "$TARGET/lib/client.js"
echo "已覆盖 lib/index.js, lib/client.js"

mkdir -p "$TARGET/runtime/coach-hotkey"
cp "$ROOT/plugin/runtime/coach-hotkey/main.cjs" "$TARGET/runtime/coach-hotkey/main.cjs"
echo "已覆盖 runtime/coach-hotkey/main.cjs（教练快捷键小助手）"

if [ "${SKIP_CONFIG:-0}" != "1" ]; then
  cp "$ROOT/plugin/assets/config.jsonc" "$TARGET/assets/config.jsonc"
  echo "已覆盖 assets/config.jsonc（内置默认值；用户配置 main-config.jsonc 不受影响）"
fi

echo
echo "装好了。重启 DSH 后生效；配置在 ~/.dsh/dsh-pet/main-config.jsonc："
echo "  hearthstoneMode = true/false   手动开关"
echo "  hearthstoneAuto = true/false   随炉石游戏进程自动切换"
echo "  hsCoachEnabled  = true/false   出牌教练开关"
echo "  hsCoachHotkey   = Ctrl+Alt+H   教练全局快捷键"
echo "  hsLogPath       = ''           自定义 Power.log 路径（留空自动探测）"
echo "  hsCoachEmoteChance   = 65      加戏：动作概率（%）"
echo "  hsCoachWhisperChance = 30      加戏：碎碎念概率（%）"
echo "  hearthstoneLines     = [...]   炉石碎碎念语料（一行一条；设置页可改）"
