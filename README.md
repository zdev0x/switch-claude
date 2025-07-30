# Claude 配置切换工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

快速切换 Claude Code 配置的命令行工具，支持多套API配置一键切换。**推荐全局配置，体验极佳！**

## ⚡ 极简安装（推荐全局配置）

```bash
# 1️⃣ 安装依赖（选择你的系统）
# Ubuntu/Debian: sudo apt-get install jq
# macOS: brew install jq  
# CentOS/RHEL: sudo yum install jq

# 2️⃣ 下载并设置全局命令（选择一种方式）
# 方式一：使用 curl
sudo curl -o /usr/local/bin/switch-claude https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh
sudo chmod +x /usr/local/bin/switch-claude

# 方式二：使用 wget  
sudo wget -O /usr/local/bin/switch-claude https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh
sudo chmod +x /usr/local/bin/switch-claude

# 3️⃣ 创建全局配置目录
mkdir -p ~/.config/switch-claude
```

## 🚀 三步开始使用

### 1️⃣ 创建全局配置文件：

```bash
# 在全局配置目录创建配置文件
cat > ~/.config/switch-claude/config.json << 'EOF'
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
EOF
```

### 2️⃣ 查看配置：
```bash
switch-claude -l
```

### 3️⃣ 一键切换：
```bash
switch-claude work      # 切换到工作配置
switch-claude personal  # 切换到个人配置
```

## 💡 常用命令

```bash
switch-claude -l        # 列出所有配置
switch-claude work      # 切换到work配置  
switch-claude -c        # 查看当前配置
```

## ✨ 全局配置优势

### 🌟 **体验极佳**
- **任意目录执行** - 在任何目录都能直接使用 `switch-claude` 命令
- **统一配置管理** - 所有项目共享同一套配置，无需重复创建
- **自动路径解析** - 智能查找配置文件，无需关心路径问题

### 🔧 **便捷管理**
- **一次配置** - 全局配置一次设置，永久生效
- **快速切换** - 3个字符即可切换：`switch-claude work`
- **配置共享** - 多个项目使用相同配置，管理更简单

### 📁 **智能查找**
脚本按以下优先级自动查找配置文件：
1. **~/.config/switch-claude/config.json** ⭐ *推荐全局配置*
2. **当前目录/config.json** - 项目特定配置
3. **~/.switch-claude.json** - 简化全局配置  
4. **当前目录/*.json** - 其他JSON配置文件

---

## 📋 进阶功能

### 高级命令
```bash
switch-claude -f my-config.json work  # 使用指定配置文件
switch-claude -h                      # 显示帮助
```

### 配置文件格式
配置文件必须是JSON数组格式，每个配置包含：
- `name`: 配置名称（必需）  
- `description`: 配置描述（可选）
- `ANTHROPIC_BASE_URL`: API地址（必需）
- `ANTHROPIC_AUTH_TOKEN`: API密钥（必需）

## 🔐 安全特性

- **自动备份**: 切换前自动备份当前配置
- **隐私保护**: Token显示时自动隐藏敏感信息  
- **安全建议**: 设置配置文件权限 `chmod 600 ~/.config/switch-claude/config.json`

## ❓ 常见问题

**Q: 提示 `command not found: jq`**  
A: 安装jq依赖：`sudo apt-get install jq` 或 `brew install jq`

**Q: 提示 `command not found: switch-claude`**  
A: 确保已正确下载到系统路径：
```bash
# 使用 curl
sudo curl -o /usr/local/bin/switch-claude https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh
sudo chmod +x /usr/local/bin/switch-claude

# 或使用 wget
sudo wget -O /usr/local/bin/switch-claude https://raw.githubusercontent.com/zdev0x/switch-claude/main/switch-claude.sh  
sudo chmod +x /usr/local/bin/switch-claude
```

**Q: 配置切换不生效**  
A: 检查当前配置 `switch-claude -c`，或重启Claude Code

**Q: JSON格式错误**  
A: 验证配置文件语法：`jq . ~/.config/switch-claude/config.json`

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

---

🌟 **推荐配置**: 使用全局配置，一次设置，终身受益！

⭐ 觉得有用请给个 Star！