const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const port = Number(process.env.XIANYU_CDP_PORT || 18803);
if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('无效的 XIANYU_CDP_PORT');
const profile = path.resolve(__dirname, '..', 'data', 'chrome-profile');
async function status() {
  try {
    const response = await fetch(`http://127.0.0.1:${port}/json/version`, { signal: AbortSignal.timeout(1500) });
    if (!response.ok) return null;
    const info = await response.json();
    return info.webSocketDebuggerUrl ? info : null;
  } catch { return null; }
}
function executable() {
  const candidates = [process.env.XIANYU_CHROME_PATH,
    ...['PROGRAMFILES', 'PROGRAMFILES(X86)', 'LOCALAPPDATA'].map(key => process.env[key] && path.join(process.env[key], 'Google', 'Chrome', 'Application', 'chrome.exe')),
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', '/usr/bin/google-chrome', '/usr/bin/chromium'];
  const found = candidates.find(candidate => candidate && fs.existsSync(candidate));
  if (!found) throw new Error('找不到 Chrome，请安装 Chrome 或设置 XIANYU_CHROME_PATH 为 chrome.exe 的完整路径');
  return found;
}
async function start() {
  const existing = await status();
  if (existing) { console.log(`浏览器已在端口 ${port} 运行：${existing.Browser}`); return; }
  const chrome = executable();
  fs.mkdirSync(profile, { recursive: true });
  const child = spawn(chrome, [`--remote-debugging-port=${port}`, '--remote-debugging-address=127.0.0.1', `--user-data-dir=${profile}`, '--no-first-run', '--no-default-browser-check', '--new-window', 'https://www.goofish.com/'], { detached: true, stdio: 'ignore', windowsHide: true });
  await new Promise((resolve, reject) => { child.once('spawn', resolve); child.once('error', reject); });
  child.unref();
  for (let i = 0; i < 30; i++) {
    await new Promise(resolve => setTimeout(resolve, 500));
    const info = await status();
    if (info) { console.log(`Chrome 已启动，端口 ${port}。请在闲鱼页面完成登录。`); return; }
  }
  throw new Error('Chrome 调试端口未就绪，请检查浏览器窗口或端口占用');
}
module.exports = { start, status, executable };
