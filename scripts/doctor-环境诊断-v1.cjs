// pick-skills / lavineleo — read-only environment diagnostics
const { executable, status } = require('../infra/browser-浏览器-v1.cjs');
let failed = false;
function check(label, action) {
  try { console.log(`[OK] ${label}: ${action()}`); }
  catch (error) { failed = true; console.error(`[FAIL] ${label}: ${error.message}`); }
}
(async () => {
  check('Node.js', () => {
    const [major, minor] = process.versions.node.split('.').map(Number);
    if (major < 24 || (major === 24 && minor < 12)) throw new Error('请安装 Node.js 24.12 或更新版本');
    return process.version;
  });
  check('SQLite', () => {
    const { DatabaseSync } = require('node:sqlite');
    const db = new DatabaseSync(':memory:');
    try { return db.prepare('select sqlite_version() as version').get().version; }
    finally { db.close(); }
  });
  check('Puppeteer', () => { require('puppeteer-core'); return '已安装；无需 ChromeDriver'; });
  check('Chrome', () => executable());
  const browser = await status();
  console.log(browser ? `[OK] 调试端口: ${browser.Browser}` : '[INFO] 浏览器未启动；需要搜索时执行 npm run browser:start');
  if (failed) process.exitCode = 1;
})().catch(error => { console.error(error.message); process.exitCode = 1; });
