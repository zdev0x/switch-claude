# Claude 配置切换工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

一个用于快速切换 Claude Code 配置的命令行工具，支持管理多个不同的 API 端点和密钥配置。

## ✨ 功能特性

- 🔧 **YAML配置格式** - 简单易读的配置文件格式
- 🔄 **多配置管理** - 支持多个 API URL 和密钥的配置切换
- 💾 **自动备份** - 切换前自动备份当前配置
- 🎨 **彩色输出** - 友好的用户界面体验
- 🔒 **安全处理** - Token 显示时自动隐藏敏感信息
- ✅ **完整验证** - 完整的依赖检查和错误处理
- 📁 **当前目录操作** - 直接从当前目录读取配置文件

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/zdev0x/switch-claude.git
cd switch-claude
```

### 2. 安装依赖

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install jq python3 python3-pip
pip3 install PyYAML
```

#### CentOS/RHEL
```bash
sudo yum install epel-release
sudo yum install jq python3 python3-pip
pip3 install PyYAML
```

#### macOS
```bash
brew install jq python3
pip3 install PyYAML
```

### 3. 配置文件设置

在项目目录下创建或编辑 `configs.yaml` 配置文件：

```yaml
configs:
  - name: "work"
    description: "挺稳定的-适合长期使用-不需要频繁切换"
    ANTHROPIC_BASE_URL: "https://api.anthropic.com"
    ANTHROPIC_AUTH_TOKEN: "sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
  - name: "personal"
    description: "个人使用配置"
    ANTHROPIC_BASE_URL: "https://ccr-dev.lfree.org/api/"
    ANTHROPIC_AUTH_TOKEN: "cr_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
  - name: "dev"
    description: "开发测试配置"
    ANTHROPIC_BASE_URL: "https://dev-api.example.com/v1/"
    ANTHROPIC_AUTH_TOKEN: "dev_token_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
  - name: "backup"
    description: "备用配置"
    ANTHROPIC_BASE_URL: "https://backup-api.example.com/"
    ANTHROPIC_AUTH_TOKEN: "backup_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 4. 基本使用

```bash
# 给脚本添加执行权限
chmod +x switch-claude.sh

# 查看所有可用配置
./switch-claude.sh -l

# 切换到指定配置
./switch-claude.sh work

# 查看当前配置
./switch-claude.sh -c
```

## 📖 详细使用说明

### 基本命令

```bash
# 切换到指定配置
./switch-claude.sh work
./switch-claude.sh personal

# 列出所有可用配置
./switch-claude.sh -l
./switch-claude.sh --list

# 显示当前配置信息
./switch-claude.sh -c
./switch-claude.sh --current

# 显示帮助信息
./switch-claude.sh -h
./switch-claude.sh --help
```

### 高级用法

```bash
# 使用指定的配置文件
./switch-claude.sh -f my-configs.yaml work
./switch-claude.sh --file team-configs.yml dev

# 列出指定文件中的配置
./switch-claude.sh -l -f my-configs.yaml

# 组合使用
./switch-claude.sh --file prod-configs.yml --list
```

## ⚙️ 配置文件格式

### YAML配置结构

配置文件必须包含一个名为 `configs` 的数组，每个配置项包含以下字段：

```yaml
configs:
  - name: "配置名称"           # 必需：配置的唯一标识符
    description: "配置描述"     # 可选：配置的说明文字
    ANTHROPIC_BASE_URL: "API地址"        # 必需：API端点URL
    ANTHROPIC_AUTH_TOKEN: "认证令牌"     # 必需：API密钥
```

### 完整配置示例

```yaml
configs:
  # 官方API配置
  - name: "official"
    description: "Anthropic官方API"
    ANTHROPIC_BASE_URL: "https://api.anthropic.com"
    ANTHROPIC_AUTH_TOKEN: "sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
  # 代理服务配置
  - name: "proxy"
    description: "国内代理服务"
    ANTHROPIC_BASE_URL: "https://ccr-dev.lfree.org/api/"
    ANTHROPIC_AUTH_TOKEN: "cr_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
  # 开发环境配置
  - name: "dev"
    description: "开发测试环境"
    ANTHROPIC_BASE_URL: "https://dev-api.company.com/v1/"
    ANTHROPIC_AUTH_TOKEN: "dev_token_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## 📋 依赖环境

### 必需依赖

- **jq** - 用于处理内部JSON数据转换
- **python3** - 用于解析YAML配置文件
- **PyYAML** - Python的YAML解析库

### 验证安装

```bash
jq --version
python3 --version
python3 -c "import yaml; print('PyYAML installed successfully')"
```

## 📚 使用示例场景

### 场景1：工作环境切换
```bash
# 上班时切换到公司配置
./switch-claude.sh work

# 下班后切换到个人配置
./switch-claude.sh personal
```

### 场景2：开发测试
```bash
# 开发时使用测试环境
./switch-claude.sh dev

# 部署前切换到生产环境
./switch-claude.sh prod
```

### 场景3：多团队配置
```bash
# 使用团队A的配置文件
./switch-claude.sh -f team-a-configs.yaml work

# 使用团队B的配置文件
./switch-claude.sh -f team-b-configs.yaml dev
```

## 🔐 安全特性

### 自动备份
- 每次切换前自动备份当前配置
- 备份文件带时间戳：`~/.claude/settings.json.backup.20250730_103334`
- 可用于配置恢复

### 隐私保护
- Token显示时只显示前20个字符
- 敏感信息用 `...` 代替
- 配置文件权限建议设置为 `600`

### 安全建议
```bash
# 设置配置文件权限
chmod 600 configs.yaml

# 避免将配置文件提交到版本控制
echo "configs.yaml" >> .gitignore
echo "*.yml" >> .gitignore
```

## 🛠️ 故障排除

### 常见问题

#### 1. 依赖缺失
```bash
# 错误：command not found: jq
sudo apt-get install jq

# 错误：command not found: python3
sudo apt-get install python3

# 错误：No module named 'yaml'
pip3 install PyYAML
```

#### 2. 配置文件格式错误
```bash
# 检查YAML语法
python3 -c "import yaml; yaml.safe_load(open('configs.yaml'))"

# 常见错误：缺少configs数组
# 确保配置文件以 configs: 开头
```

#### 3. 权限问题
```bash
# 脚本没有执行权限
chmod +x switch-claude.sh

# Claude配置文件权限问题
chmod 644 ~/.claude/settings.json
```

#### 4. 配置不生效
```bash
# 检查当前配置
./switch-claude.sh -c

# 重新加载Claude Code
# 重启终端或重新启动Claude Code进程
```

### 调试模式

如果遇到问题，可以手动执行脚本的某些部分：

```bash
# 检查配置文件解析
python3 -c "
import yaml, json
with open('configs.yaml') as f:
    data = yaml.safe_load(f)
print(json.dumps(data['configs'], indent=2))
"

# 检查jq是否正常工作
echo '{"test": "value"}' | jq .

# 检查Claude设置文件
cat ~/.claude/settings.json | jq .
```

## 📁 项目结构

```
switch-claude/
├── switch-claude.sh      # 主脚本文件
├── configs.yaml          # YAML配置文件
├── 配置切换说明.md       # 详细说明文档
├── README.md             # 项目说明文档
└── other-configs.yml     # 其他配置文件（可选）
```

## 🤝 贡献指南

欢迎贡献代码和建议！

1. Fork 这个项目
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

### 开发建议

- 遵循现有的代码风格
- 添加适当的注释
- 确保脚本在不同的shell环境中都能正常工作
- 添加必要的错误处理

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 相关链接

- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [YAML 语法参考](https://yaml.org/spec/)
- [jq 命令手册](https://jqlang.github.io/jq/)

## 📞 支持

如果您在使用过程中遇到问题或有改进建议，欢迎：

- 提交 [Issue](https://github.com/zdev0x/switch-claude/issues) 反馈问题
- 提供功能建议
- 贡献代码改进

## 📊 更新日志

- **v1.3** - 简化为只支持YAML格式，提升性能
- **v1.2** - 修复bash兼容性问题，支持更多shell环境  
- **v1.1** - 添加多配置文件支持，改进错误处理
- **v1.0** - 初始版本，支持JSON和YAML格式

---

💡 **提示**：建议将此脚本放入您的 `PATH` 环境变量中，这样就可以在任何地方使用 `switch-claude` 命令了。

⭐ 如果这个项目对您有帮助，请给我们一个 Star！