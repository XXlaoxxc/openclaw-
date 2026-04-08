# OpenClaw 环境备份与迁移指南

## 📋 需要备份的关键文件和目录

### 1. 核心配置文件
- `~/.openclaw/openclaw.json` - 主配置文件（包含模型、代理、通道、插件等所有设置）
- `~/.openclaw/openclaw.json.bak*` - 配置文件备份（可选，但建议保留最近的几个）

### 2. 工作区数据
- `~/.openclaw/workspace*/` - 所有工作区目录（每个智能体对应一个工作区）
  - 包含：AGENTS.md, SOUL.md, IDENTITY.md, USER.md, TOOLS.md, MEMORY.md 等个性化文件
  - 包含：长期记忆数据（MEMORY.md 和 memory/ 目录）

### 3. 技能系统
- `~/.openclaw/skills/` - 自定义技能目录
- `~/.agents/skills/` - 代理技能目录（如果存在）

### 4. 插件扩展
- `~/.openclaw/extensions/` - 所有已安装的插件
  - dingtalk-connector/
  - feishu-openclaw-plugin/
  - qqbot/
  - wecom-openclaw-plugin/

### 5. 设备和会话数据
- `~/.openclaw/devices/` - 已配对设备信息
- `~/.openclaw/media/` - 媒体文件缓存
- `~/.openclaw/logs/` - 日志文件（可选）

### 6. 环境变量和凭证
- **GitHub Token**: 已存储在 `openclaw.json` 的 `env.vars.GITHUB_TOKEN` 中
- **Feishu 应用凭证**: 已存储在 `openclaw.json` 的 `channels.feishu.accounts` 中
- **模型 API 密钥**: 已存储在 `openclaw.json` 的 `models.providers` 中

### 7. 代理定义
- `~/.openclaw/agents/` - 代理定义目录（包含每个代理的 agentDir 配置）

## 🚀 一键备份脚本

```bash
#!/bin/bash
# OpenClaw 备份脚本
BACKUP_DIR="$HOME/openclaw-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 创建备份目录: $BACKUP_DIR"

# 1. 备份核心配置
cp ~/.openclaw/openclaw.json "$BACKUP_DIR/"
cp ~/.openclaw/openclaw.json.bak* "$BACKUP_DIR/" 2>/dev/null || true

# 2. 备份所有工作区
mkdir -p "$BACKUP_DIR/workspace"
cp -r ~/.openclaw/workspace*/ "$BACKUP_DIR/workspace/" 2>/dev/null || true

# 3. 备份技能
if [ -d ~/.openclaw/skills ]; then
    cp -r ~/.openclaw/skills "$BACKUP_DIR/"
fi
if [ -d ~/.agents/skills ]; then
    cp -r ~/.agents/skills "$BACKUP_DIR/agents_skills"
fi

# 4. 备份插件
if [ -d ~/.openclaw/extensions ]; then
    cp -r ~/.openclaw/extensions "$BACKUP_DIR/"
fi

# 5. 备份设备数据
if [ -d ~/.openclaw/devices ]; then
    cp -r ~/.openclaw/devices "$BACKUP_DIR/"
fi

# 6. 备份代理定义
if [ -d ~/.openclaw/agents ]; then
    cp -r ~/.openclaw/agents "$BACKUP_DIR/"
fi

# 7. 创建恢复脚本
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# OpenClaw 恢复脚本
set -e

echo "🚀 开始恢复 OpenClaw 环境..."

# 停止当前 Gateway
if pgrep -f "openclaw gateway" > /dev/null; then
    echo "⏹️  停止当前 Gateway..."
    pkill -f "openclaw gateway"
    sleep 3
fi

# 恢复核心配置
cp openclaw.json ~/.openclaw/
cp openclaw.json.bak* ~/.openclaw/ 2>/dev/null || true

# 恢复工作区
if [ -d workspace ]; then
    cp -r workspace/* ~/.openclaw/
fi

# 恢复技能
if [ -d skills ]; then
    cp -r skills ~/.openclaw/
fi
if [ -d agents_skills ]; then
    mkdir -p ~/.agents/
    cp -r agents_skills ~/.agents/skills
fi

# 恢复插件
if [ -d extensions ]; then
    cp -r extensions ~/.openclaw/
fi

# 恢复设备数据
if [ -d devices ]; then
    cp -r devices ~/.openclaw/
fi

# 恢复代理定义
if [ -d agents ]; then
    cp -r agents ~/.openclaw/
fi

echo "✅ 恢复完成！请重启 OpenClaw Gateway:"
echo "   openclaw gateway start"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo "✅ 备份完成！"
echo "📦 备份位置: $BACKUP_DIR"
echo "🔧 恢复命令: cd $BACKUP_DIR && ./restore.sh"
```

## 🔧 迁移到新环境的步骤

### 1. 在新环境中安装最新版 OpenClaw
```bash
npm install -g openclaw@latest
```

### 2. 停止新环境的 Gateway（如果已运行）
```bash
openclaw gateway stop
```

### 3. 使用备份脚本恢复
```bash
# 解压备份文件到新环境
cd /path/to/backup
./restore.sh
```

### 4. 启动 Gateway
```bash
openclaw gateway start
```

### 5. 验证恢复
```bash
openclaw status
```

## ⚠️ 注意事项

### 安全考虑
- **敏感信息**: `openclaw.json` 包含所有 API 密钥和凭证，请妥善保管备份文件
- **权限设置**: 恢复后确保文件权限正确（配置文件应为 600 权限）
- **版本兼容性**: 跨大版本迁移时可能需要手动调整配置

### 特殊情况处理
- **插件兼容性**: 某些插件可能需要重新安装或更新
- **工作区冲突**: 如果新环境已有同名工作区，建议先备份再恢复
- **模型提供商变更**: 如果模型提供商 API 发生变化，可能需要更新密钥

## 📊 当前环境概览

**OpenClaw 版本**: 2026.3.23-2  
**代理数量**: 8 个（xiaoyan 系列）  
**已配置通道**: Feishu (3 个账号)  
**已安装插件**: 5 个（钉钉、飞书、QQ、企业微信）  
**自定义技能**: 3 个（agent-browser, find-skills, skill-creator）  
**环境变量**: GitHub Token 已配置  

## 💡 快速验证清单

恢复后请检查：
- [ ] `openclaw status` 显示正常
- [ ] 所有代理都能正常响应
- [ ] Feishu 通道能正常收发消息
- [ ] GitHub 私有仓库访问正常
- [ ] 自定义技能功能正常
- [ ] 工作区记忆数据完整

---
*备份时间: $(date)*  
*生成工具: OpenClaw 小焱智能专家*