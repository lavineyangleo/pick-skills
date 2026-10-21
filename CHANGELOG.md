# 更新记录

## 1.2.0

- 统一名称：pick-skills / 捡垃圾-skills，作者 lavineleo。
- Windows 安装引导：检查 Node.js、Chrome，支持可选 winget 安装、npm 代理和环境诊断。
- 使用 Node.js 内置 SQLite，不依赖 Python、C++ 编译工具或 ChromeDriver。
- Puppeteer Core 更新至 25.15.0。
- 连接 Chrome 时排除 chrome:// 内部页面，避免内部页面初始化阻塞。
- 增加源码打包与 SHA256 校验。
- 发布包仅包含源码、文档和项目资源。

此前的 Windows 适配包括独立 Chrome 资料目录、项目内数据库、扫描异常退出码及项目 Logo。
