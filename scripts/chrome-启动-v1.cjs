const browser = require('../infra/browser-浏览器-v1.cjs');
const command = process.argv[2] || 'status';
(async () => {
  if (command === 'start') await browser.start();
  else if (command === 'status') {
    const info = await browser.status();
    console.log(info ? `Chrome 运行中：${info.Browser}` : 'Chrome 未运行，请执行 npm run browser:start');
    if (!info) process.exitCode = 1;
  } else throw new Error('用法：node scripts/chrome-启动-v1.cjs [start|status]；停止请关闭专用浏览器窗口。');
})().catch(error => { console.error(error.message); process.exitCode = 1; });
