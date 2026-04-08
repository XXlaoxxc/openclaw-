#!/bin/bash
# OpenClaw 备份脚本 - 一键备份所有关键数据

set -e

echo "🦞 OpenClaw 环境备份工具"
echo "========================"

# 创建备份目录
BACKUP_DIR="$HOME/openclaw-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 创建备份目录: $BACKUP_DIR"

# 1. 备份核心配置文件
echo "💾 备份核心配置..."
cp ~/.openclaw/openclaw.json "$BACKUP_DIR/"
# 备份最近的几个配置备份文件
cp ~/.openclaw/openclaw.json.bak* "$BACKUP_DIR/" 2>/dev/null || echo "  (无额外备份文件)"

# 2. 备份所有工作区
echo "💼 备份工作区..."
mkdir -p "$BACKUP_DIR/workspace"
for workspace in ~/.openclaw/workspace*/; do
    if [ -d "$workspace" ]; then
        ws_name=$(basename "$workspace")
        echo "  备份: $ws_name"
        cp -r "$workspace" "$BACKUP_DIR/workspace/"
    fi
done

# 3. 备份技能系统
echo "🔧 备份技能..."
if [ -d ~/.openclaw/skills ] && [ -n "$(ls -A ~/.openclaw/skills)" ]; then
    cp -r ~/.openclaw/skills "$BACKUP_DIR/"
    echo "  自定义技能已备份"
else
    echo "  (无自定义技能)"
fi

if [ -d ~/.agents/skills ] && [ -n "$(ls -A ~/.agents/skills)" ]; then
    mkdir -p "$BACKUP_DIR/agents"
    cp -r ~/.agents/skills "$BACKUP_DIR/agents/"
    echo "  代理技能已备份"
else
    echo "  (无代理技能)"
fi

# 4. 备份插件扩展
echo "🔌 备份插件..."
if [ -d ~/.openclaw/extensions ] && [ -n "$(ls -A ~/.openclaw/extensions)" ]; then
    # 排除临时目录
    mkdir -p "$BACKUP_DIR/extensions"
    for ext in ~/.openclaw/extensions/*; do
        if [ -d "$ext" ] && [[ ! "$(basename "$ext")" == .* ]]; then
            echo "  备份插件: $(basename "$ext")"
            cp -r "$ext" "$BACKUP_DIR/extensions/"
        fi
    done
else
    echo "  (无插件扩展)"
fi

# 5. 备份设备和会话数据
echo "📱 备份设备数据..."
if [ -d ~/.openclaw/devices ] && [ -n "$(ls -A ~/.openclaw/devices)" ]; then
    cp -r ~/.openclaw/devices "$BACKUP_DIR/"
    echo "  设备配对信息已备份"
else
    echo "  (无设备数据)"
fi

# 6. 备份代理定义
echo "🤖 备份代理定义..."
if [ -d ~/.openclaw/agents ] && [ -n "$(ls -A ~/.openclaw/agents)" ]; then
    cp -r ~/.openclaw/agents "$BACKUP_DIR/"
    echo "  代理配置已备份"
else
    echo "  (无代理定义)"
fi

# 7. 创建恢复脚本
echo "🔄 创建恢复脚本..."
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# OpenClaw 恢复脚本
set -e

echo "🦞 OpenClaw 环境恢复工具"
echo "========================"

# 确认操作
read -p "⚠️  此操作将覆盖当前 OpenClaw 配置，是否继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 恢复已取消"
    exit 1
fi

# 停止当前 Gateway
echo "⏹️  停止当前 Gateway..."
if pgrep -f "openclaw gateway" > /dev/null; then
    pkill -f "openclaw gateway"
    sleep 3
fi

# 恢复核心配置
echo "💾 恢复核心配置..."
cp openclaw.json ~/.openclaw/
chmod 600 ~/.openclaw/openclaw.json

# 恢复配置备份文件
if ls openclaw.json.bak* >/dev/null 2>&1; then
    cp openclaw.json.bak* ~/.openclaw/
    chmod 600 ~/.openclaw/openclaw.json.bak*
fi

# 恢复工作区
if [ -d workspace ]; then
    echo "💼 恢复工作区..."
    for ws in workspace/*; do
        if [ -d "$ws" ]; then
            ws_name=$(basename "$ws")
            echo "  恢复: $ws_name"
            cp -r "$ws" ~/.openclaw/
        fi
    done
fi

# 恢复技能
if [ -d skills ]; then
    echo "🔧 恢复自定义技能..."
    cp -r skills ~/.openclaw/
fi

if [ -d agents/skills ]; then
    echo "🔧 恢复代理技能..."
    mkdir -p ~/.agents/
    cp -r agents/skills ~/.agents/
fi

# 恢复插件
if [ -d extensions ]; then
    echo "🔌 恢复插件..."
    cp -r extensions/* ~/.openclaw/extensions/ 2>/dev/null || true
fi

# 恢复设备数据
if [ -d devices ]; then
    echo "📱 恢复设备数据..."
    cp -r devices ~/.openclaw/
fi

# 恢复代理定义
if [ -d agents ] && [ ! -d agents/skills ]; then
    echo "🤖 恢复代理定义..."
    cp -r agents ~/.openclaw/
elif [ -d agents ] && [ -d agents/skills ]; then
    # 如果 agents 目录只包含 skills，跳过（已在上面处理）
    :
fi

echo "✅ 恢复完成！"
echo ""
echo "🚀 下一步操作:"
echo "1. 启动 Gateway: openclaw gateway start"
echo "2. 验证状态: openclaw status"
echo "3. 测试功能: 向任意代理发送测试消息"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

# 8. 创建备份清单
echo "📋 生成备份清单..."
cat > "$BACKUP_DIR/backup_manifest.txt" << EOF
OpenClaw Backup Manifest
=======================
Backup Time: $(date)
OpenClaw Version: $(grep -o '"lastTouchedVersion":"[^"]*"' ~/.openclaw/openclaw.json | cut -d'"' -f4)

Files and directories backed up:
- openclaw.json (main configuration)
- openclaw.json.bak* (configuration backups)
- workspace/ (all workspaces)
- skills/ (custom skills, if any)
- agents/skills/ (agent skills, if any)
- extensions/ (plugins)
- devices/ (paired devices)
- agents/ (agent definitions)

Total backup size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF

echo ""
echo "✅ 备份完成！"
echo "📦 备份位置: $BACKUP_DIR"
echo "📄 备份清单: $BACKUP_DIR/backup_manifest.txt"
echo "🔄 恢复命令: cd $BACKUP_DIR && ./restore.sh"
echo ""
echo "💡 提示: 请妥善保管备份文件，其中包含敏感的 API 密钥和凭证！"