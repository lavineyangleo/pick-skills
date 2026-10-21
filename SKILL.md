---
name: pick-skills
description: 捡垃圾-skills，支持 Windows 的闲鱼商品关键词搜索、价格和地区筛选、本地去重与历史查询。用户需要找二手商品、查询挂牌价或配置闲鱼监控时使用。
metadata:
  author: lavineleo
---

# pick-skills · 捡垃圾-skills

作者：lavineleo。完整安装和使用说明见 README.md，Windows 安装细节见 docs/INSTALL-WINDOWS.md。

## 环境

Windows 10/11、Node.js 24.12+、Google Chrome。运行 `npm.cmd run doctor` 检查。缺依赖时使用 `scripts/setup-Windows安装-v1.ps1`。不需要 ChromeDriver、Selenium、Python 或独立 SQLite。

浏览器功能由 infra/browser-浏览器-v1.cjs 提供，命令行入口位于 scripts/。不要修改用户日常 Chrome 的资料目录。

## 使用流程

1. 在本项目根目录执行 `npm.cmd run browser:start`。
2. 由用户在专用 Chrome 中手动登录闲鱼并处理验证，不索要密码或验证码。
3. 按用户真实需求执行 `node scripts/xianyu.js add --keyword "关键词" --max-price 预算`。缺关键词时询问，不创建演示任务。用户只问一次价格时，不擅自建立长期监控或定时任务。
4. 执行 `node scripts/xianyu.js scan --hours 24`，或用 `--id 编号` 指定已有任务。价格比较不应随意限制到最近24小时而漏掉已有挂牌，按需求选择时间范围。
5. `node scripts/xianyu.js list` 查看任务；`history` 查看历史；`remove --id 编号` 停用任务。

## 结果解释

只报告真实商品。区分完整商品、空盒、配件、维修服务、回收广告和故障件，精确匹配型号与版本。挂牌价不是成交价；卖家声明不是已核验事实。不要把无匹配、加载失败和商品去重后的空结果混为一谈。

新增商品 JSON 位于 NEW_ITEMS_JSON 与 END_NEW_ITEMS_JSON 标记之间。COOKIE_EXPIRED 为启发式提示，不能单凭该标记证明账号状态。页面结构和验证机制可能变化，遇到验证需用户处理。

## 数据与配置

- `XIANYU_CDP_PORT`：默认18803，仅本机连接。
- `XIANYU_CHROME_PATH`：可选，指定 Chrome 可执行文件。
- `XIANYU_DB_PATH`：默认项目 data/xianyu-monitor.db；旧数据可显式指定路径。
- `data/chrome-profile`：用户登录资料；不得打包、上传或暴露。

保持兼容数据库名与环境变量。外部通知、定时运行、联系卖家、下单需对应用户授权；本工具本身不自动执行这些动作。
