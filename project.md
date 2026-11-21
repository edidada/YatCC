# 中山大学 YatCC 项目官方网址（2026 年 11 月查证）

> 查证日期：2026-11-21。以下链接均经联网访问验证，以官方主站 `yatcc-ai.com` 的「教学实践」页和 2026 课程主页列出的资源入口为准。
> 项目全称：YatCC (Yat Compiler Course) / YatCC-AI (Yat Compiler Construction with AI)，中山大学计算机学院与国家超算广州中心联合建设。

## 结论：当前主站

**https://yatcc-ai.com**

主站首页 Timeline/News 已更新到 2026 年 11 月（11/1 HPC Asia 2027 Tutorial 入选、11/27 高交会预告等），首页「编译实践」按钮直接指向 2026 学年课程页，确认为当前活跃版本。

## 当前有效网址

| 用途 | 网址 | 说明 |
|---|---|---|
| 项目 / 平台主站 | https://yatcc-ai.com | YatCC-AI 一体化智能服务平台首页 |
| 在线实验平台 OL LAB | https://ol.yatcc.arcsysu.cn | 主站「进入平台」入口，云端代码仓库与开发环境 |
| **2026 学年课程主页（最新）** | https://yatcc-ai.com/teach/s2026.html | SYSU-DCS290/292「编译原理与实验」Spring 2026，含课表、讲义、作业提交入口 |
| 实验文档（新站） | https://docs.yatcc-ai.com/ | YatCC 实验文档门户（MkDocs Material），含实验指引、Task0~5、AI 工具、QA |
| 源码仓库 | https://github.com/arcsysu/YatCC | 官方开源框架，默认分支 `main` |
| 视频教程 | https://space.bilibili.com/3546650047941291 | B 站「Yat-Compiler」课程讲解与实验演示 |
| 作业 / 项目提交 | https://easyhpc.net/course/253 | 2026 课程页的 HW/Proj Submission |
| 教学实践与历年课程 | https://yatcc-ai.com/teaching-practice | 汇总文档/视频/源码入口及 2021~2026 各年课程站 |
| 新闻动态 | https://yatcc-ai.com/zh/news | 主站 Timeline/News 全量 |
| AI Hub 门户 | https://portal.aihub.arcsysu.cn | docs「项目介绍」中的 AI 资源聚合平台 |
| AI Hub API Base URL | https://aihub.arcsysu.cn/v1 | 线上 README 当前给出的模型网关地址（Roo Code 等插件配置用） |
| RAMP 模型榜单 | https://ramp.nexa-lang.com/ | 主站首页入口 |
| arcSYSu 实验室 | https://arcsysu.tech | docs「项目介绍」列出 |
| 中山大学计算机学院 | https://cse.sysu.edu.cn/ | 学院官网 |
| 国家超算广州中心 | http://www.nscc-gz.cn/ | 联合建设单位 |
| 联系邮箱 | yatcc-team@outlook.com | 中大教务部推文公布 |

历年课程站：`s2025.html`、`s2024.html`、`s2023.html`、`s2022.html`、`s2021.html`（均为 `https://yatcc-ai.com/teach/` 下）。

## 2026 版相比本仓库的变化（旧链接对照）

| 项 | 本仓库在用的旧值 | 2026.11 最新值 |
|---|---|---|
| 课程主页 | `https://yatcc-ai.com/teach/s2025.html`（README.md:7） | **`https://yatcc-ai.com/teach/s2026.html`** |
| 实验文档 | `https://arcsysu.github.io/YatCC/`、`.../labs/`、`.../#/introduction/environment`（README.md:42,58,95；ai.md:10） | **`https://docs.yatcc-ai.com/`**（MkDocs，路径无 `#/`） |
| LLM Base URL | `https://llm.yatcc-ai.com/v1/`（README.md:46） | **`https://aihub.arcsysu.cn/v1`** |
| 自动评测 / 提交 | `https://arcsysu.terryinc.top`（2025 Lab0 幻灯片） | **`https://easyhpc.net/course/253`** |

补充：`arcsysu.github.io/YatCC` 域名抓取时仍可访问，且返回的是新的「YatCC 实验文档门户」首页；但官方资源入口（教学实践页、2026 课程页、线上 README）已统一改用 `docs.yatcc-ai.com`，建议以新域名为准。部分页面把新文档站写作 `https://docs.yatcc-ai.com/#/`，实际新站为无 hash 的 MkDocs 路径。

## 查证来源

- 逐一 WebFetch 验证：主站 `yatcc-ai.com`、`/teaching-practice`、`/teach/s2026.html`、新文档站首页与 `/home/project/`、`github.com/arcsysu/YatCC`、旧站 `arcsysu.github.io/YatCC/`
- WebSearch 命中：中大计算机学院教师页与学院新闻（YatCC-AI 上线、`yatcc-ai.com`）、2026 年赛事推文（明确写「YatCC 团队和平台网址：https://yatcc-ai.com」且 YatCC 获推荐为 2026 年编译系统设计赛备赛训练平台）、2025 Lab0 幻灯片（列出旧版资源入口）、`docs.yatcc-ai.com/introduction/howtouse` 与 `/introduction/environment`
- 本仓库 `README.md` / `ai.md` 用于旧链接对照
