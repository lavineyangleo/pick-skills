# Windows 安装指南

## 依赖关系

- Node.js 24.12 或更新版本：运行脚本，自带 npm 和 SQLite。
- Google Chrome：真实浏览器，用户在其中登录闲鱼。
- puppeteer-core：由 npm ci 安装，通过 Chrome DevTools Protocol 连接浏览器。

**无需安装 ChromeDriver**：本项目不使用 Selenium/WebDriver，也不下载另一份 Chromium。请勿为了运行本项目额外安装所谓“驱动包”。

## 手动安装前置程序

1. [Node.js 官方下载](https://nodejs.org/en/download)：安装时保留 npm 和 PATH 选项。
2. [Google Chrome 官方下载](https://www.google.com/chrome/)：完成安装。
3. 重新打开 PowerShell，进入项目根目录，运行 `node --version`，确认至少 24.12。
4. 执行 `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-Windows安装-v1.ps1`。

`-ExecutionPolicy Bypass` 仅作用于本次脚本进程，不修改全局执行策略。安装脚本不要求管理员运行；winget 安装程序时系统可能请求权限。`-InstallPrerequisites` 明确启用 winget 安装，不带此参数只检查并提示。`-CheckOnly` 只检查已有环境，不安装或更新依赖。

## 代理与镜像

代理仅应用于本次 npm 安装，不写入全局 npm 配置。先启动你自己的代理程序，并使用它实际提供的监听端口。

```powershell
# HTTP 或 mixed 代理端口；把端口替换为你实际使用的端口
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-Windows安装-v1.ps1 -ProxyUrl 'http://127.0.0.1:7890'

# SOCKS5：把端口替换为实际 SOCKS5 监听端口
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-Windows安装-v1.ps1 -ProxyUrl 'socks5h://127.0.0.1:1080'

# 可选 npm 镜像
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-Windows安装-v1.ps1 -Registry 'https://registry.npmmirror.com'
```

示例端口只是配置写法，脚本不会自动创建代理。SOCKS 支持取决于所安装 npm 的代理实现；若提示协议不支持，请使用代理软件提供的 HTTP/mixed 端口。`ProxyUrl` 不控制 winget 或 Chrome 的网络访问。锁文件可能含官方 registry 下载 URL，仅切换 Registry 不保证绕过所有访问限制。

出现 `ECONNREFUSED 127.0.0.1:端口` 表示代理未监听或端口不正确。检查 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 及 npm 代理配置；不要把含密码的配置或日志上传。已知不需要代理时，可在新的 PowerShell 中临时清除环境变量后安装：

```powershell
$env:HTTP_PROXY = ''
$env:HTTPS_PROXY = ''
$env:ALL_PROXY = ''
$env:NO_PROXY = '*'
npm.cmd ci --proxy=null --https-proxy=null --registry=https://registry.npmjs.org
```

## Chrome 检查

自定义安装路径时，先设置：

```powershell
$env:XIANYU_CHROME_PATH = 'D:\Apps\Chrome\chrome.exe'
npm.cmd run doctor
npm.cmd run browser:start
```

浏览器资料使用本项目下的 `data/chrome-profile`，与日常 Chrome 分离。调试端口绑定本机地址，不要开放给公网。浏览器未启动时 doctor 显示 INFO，不算安装失败。

如果端口已被其他实例占用，换一个端口并在同一终端运行启动和扫描命令：

```powershell
$env:XIANYU_CDP_PORT = '18804'
npm.cmd run browser:start
node scripts/xianyu.js scan
```

## 常见问题

- `npm.ps1 无法加载`：使用 `npm.cmd`，不必修改系统执行策略。
- `Cannot find module`：在项目根目录重新运行安装脚本；不要把旧 node_modules 拷贝过来。
- SQLite 实验性提示：当前 Node 版本的提示，不等同于执行失败。
- Chrome 已打开，但连接失败：确认是此项目启动的专用 Chrome，并核对端口。
- 页面要求登录、验证码或找不到搜索框：在专用 Chrome 手动处理，随后重试；网站 DOM 改动可能需要更新脚本。
- 安装完成但没有结果：先通过 list 确认已有真实任务；已保存的商品会去重，不重复输出。
