# Claude 配置切换工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

快速切换 Claude Code 配置的命令行工具，支持多套API配置一键切换。

## ⚡ 30秒快速安装

```bash
# 1. 安装依赖（选择你的系统）
# Ubuntu/Debian: sudo apt-get install jq
# macOS: brew install jq
# CentOS/RHEL: sudo yum install jq

# 2. 下载脚本
curl -O https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh
# 或者使用 wget -O switch-claude.sh https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh

# 3. 添加执行权限
chmod +x switch-claude.sh
```

## 🚀 三步开始使用

### 1️⃣ 创建配置文件 `config.json`：

```json
[
  {
    "name": "work",
    "description": "工作配置",
    "ANTHROPIC_BASE_URL": "https://api.anthropic.com",
    "ANTHROPIC_AUTH_TOKEN": "你的工作API密钥"
  },
  {
    "name": "personal",
    "description": "个人配置",
    "ANTHROPIC_BASE_URL": "https://ccr-dev.lfree.org/api/",
    "ANTHROPIC_AUTH_TOKEN": "你的个人API密钥"
  }
]
```

### 2️⃣ 查看配置：
```bash
./switch-claude.sh -l
```

### 3️⃣ 切换配置：
```bash
./switch-claude.sh work      # 切换到工作配置
./switch-claude.sh personal  # 切换到个人配置
```

## 💡 常用命令

```bash
./switch-claude.sh -l        # 列出所有配置
./switch-claude.sh work      # 切换到work配置
./switch-claude.sh -c        # 查看当前配置
```

---

## 📋 进阶功能

### 高级命令
```bash
./switch-claude.sh -f my-config.json work  # 使用指定配置文件
./switch-claude.sh -h                      # 显示帮助
```

### 配置文件格式说明
配置文件必须是JSON数组格式，每个配置包含：
- `name`: 配置名称（必需）  
- `description`: 配置描述（可选）
- `ANTHROPIC_BASE_URL`: API地址（必需）
- `ANTHROPIC_AUTH_TOKEN`: API密钥（必需）

## 🔐 安全特性

- **自动备份**: 切换前自动备份当前配置
- **隐私保护**: Token显示时自动隐藏敏感信息  
- **安全建议**: 设置配置文件权限 `chmod 600 config.json`

## ❓ 常见问题

**Q: 提示 `command not found: jq`**  
A: 安装jq依赖：`sudo apt-get install jq` 或 `brew install jq`

**Q: 配置切换不生效**  
A: 检查当前配置 `./switch-claude.sh -c`，或重启Claude Code

**Q: JSON格式错误**  
A: 验证配置文件语法：`jq . config.json`

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

---

💡 **提示**: 建议将脚本添加到 `PATH` 环境变量，全局使用 `switch-claude` 命令

⭐ 觉得有用请给个 Star！