# Claude Desktop 简体中文语言包

把 **Claude Desktop 桌面版**（Windows / MSIX）界面变成简体中文的完整语言包，附带一键应用脚本。

> 非官方项目，与 Anthropic 无任何关联。词表由社区成果 + 本项目新译合并而成（见[致谢](#致谢)）。
>
> 适配版本：**Claude Desktop `2.9939.2`（应用内部版本 44.4.3）**，共 31,680 条 UI 文案。

---

## ⚠️ 先看这一条（本项目最关键的发现）

**Claude Desktop 在语言为英文时，根本不读取英文语言文件。**

它的代码里写着：`locale === "en-US"` → 判定为默认语言 → 直接使用**打包在 JS 里的英文原文**，`i18n/en-US.json` 形同虚设。所以「把中文写进 en-US.json」这个常规思路**完全无效**（实测：写满 100% 中文，界面依旧全英文）。

只有把语言切成**非英语**，它才会去读 `/i18n/<语言>.json`。

**因此本包的做法是：把中文写进 `fr-FR.json`（法语语言文件），再把应用语言切成「Français」——界面即全中文。**

---

## 快速开始

1. **完全退出** Claude Desktop（右下角托盘图标也要退出）
2. 以**管理员身份**运行 `apply.ps1`：
   ```powershell
   powershell -ExecutionPolicy Bypass -File apply.ps1
   ```
3. 打开 Claude Desktop → **左下角头像 → Language → 选择 `Français`**
4. 界面变中文 ✅

> 想恢复原样：把语言切回 `English` 即可（或从原版安装包还原 `fr-FR.json`）。

---

## 词条覆盖

| 项目 | 数量 |
|---|---|
| 应用当前版本全部 UI 文案 | 31,680 |
| 本包提供中文的词条 | **31,272** |
| 其余（产品名、路径、占位符等无需翻译） | 408 |
| 其中来自社区上游项目 | 15,458 |
| 其中本项目新译（AI 分批翻译 + 占位符校验） | 15,814 |

翻译质量校验：非 ICU 条目 14,809 条**占位符零丢失**；ICU 复数/选择结构 905 条逐一比对通过；术语统一（Project=项目、Skill=技能、Agent=智能体、Cowork / Artifacts 等产品名保留原文）。

---

## 文件说明

| 文件 | 说明 |
|---|---|
| `zh-CN.json` | 主词表：消息 ID → 简体中文，31,272 条 |
| `dynamic-zh-CN.json` | 动态加载词表（模型/思考模式等 47 条） |
| `apply.ps1` | 一键应用脚本（Windows，需管理员） |

词表是纯 JSON，也可以用于其它工具或自行做进一步处理。

---

## 已知限制

- **应用更新会覆盖安装目录内的语言文件**，中文会失效 → 重新运行 `apply.ps1` 即可。
- 语言设为法语会带来法语风格的日期/数字格式（轻微副作用）。
- `resources/en-US.json`（735 条，浏览器/连接器相关界面）与各语种小文件未包含在本包内。
- 首次在 Cowork/Code 标签页使用本应用仍需从 `downloads.claude.ai` 下载工作区（宿主程序 + Linux 虚拟机镜像，约 1.5 GB），这部分与本语言包无关。

---

## 致谢

词表由以下社区项目的成果合并而成，**主要功劳属于他们**：

| 项目 | 贡献词条 | 许可证 |
|---|---|---|
| [ldk-tokyo/claude-desktop-zh-cn](https://github.com/ldk-tokyo/claude-desktop-zh-cn) | 15,712 | 未声明 |
| [LifeActor/Claude_zh-CN_LanguagePack](https://github.com/LifeActor/Claude_zh-CN_LanguagePack) | 5 | 未声明 |
| [good9527/Claude-Desktop-Chinese](https://github.com/good9527/Claude-Desktop-Chinese) | 2 | MIT |
| [lijunyu726/ClaudeDesktop-SimplifiedChinese](https://github.com/lijunyu726/ClaudeDesktop-SimplifiedChinese) | 1 | MIT |

- 上游未声明许可证的部分，版权归各自作者所有；若原作者有异议，本项目将立即移除对应内容。
- 本项目**新增的译文**（15,814 条）与脚本可自由使用（MIT / CC0 任选）。

### 版权说明

界面文案的原始英文版权归 Anthropic 所有；本仓库仅提供面向个人使用的界面翻译，不包含任何官方代码或用户数据。
