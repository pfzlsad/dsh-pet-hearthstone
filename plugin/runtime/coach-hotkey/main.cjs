/**
 * dsh-pet 炉石教练：全局快捷键小助手（Electron 主进程，无窗口）。
 *
 * 为什么单独起一个 Electron：DSH 的插件宿主是纯 Node 进程，拿不到 globalShortcut；
 * 而桌宠本来就依赖 Electron，这里复用它，注册一个系统级快捷键，按下时 POST 给宿主。
 *
 * 用法：electron main.cjs <快捷键> <回调 URL>
 * 输出：注册成功打印 READY，失败打印 FAILED；宿主据此更新状态。
 */
const { app, globalShortcut } = require("electron");

const combo = process.argv[2] || "Ctrl+Alt+H";
const url = process.argv[3] || "";

app.disableHardwareAcceleration?.();
app.commandLine.appendSwitch("disable-gpu");

function quitSoon(code) {
  setTimeout(() => app.quit(), 50);
  process.exitCode = code;
}

app.whenReady().then(() => {
  let ok = false;
  try {
    ok = globalShortcut.register(combo, () => {
      if (!url) return;
      fetch(url, { method: "POST" }).catch(() => {});
    });
  } catch {
    ok = false;
  }
  if (ok) {
    console.log("READY " + combo);
  } else {
    console.log("FAILED " + combo);
    quitSoon(1);
  }
});

app.on("will-quit", () => {
  try {
    globalShortcut.unregisterAll();
  } catch {}
});

// 没有窗口也要常驻
app.on("window-all-closed", () => {});
process.on("SIGTERM", () => app.quit());
process.on("SIGINT", () => app.quit());
