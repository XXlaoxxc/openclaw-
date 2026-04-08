# OpenClaw 一键配置指南

> 本指南用于在新 OpenClaw 实例上快速复现当前配置方案。
> 适用于：新机器部署、迁移、备份恢复场景

---

## 📦 核心文件清单

以下是必须配置的核心文件（按优先级排序）：

| 文件 | 用途 | 必填 |
|------|------|------|
| `SOUL.md` | AI 人格定义 | ✅ |
| `AGENTS.md` | 工作区行为规范 | ✅ |
| `USER.md` | 用户信息 | ✅ |
| `IDENTITY.md` | AI 身份定义 | ✅ |
| `MEMORY.md` | 长期记忆存储 | ✅ |
| `TOOLS.md` | 本地工具配置 | ⚠️ 按需 |
| `HEARTBEAT.md` | 心跳任务配置 | ⚠️ 按需 |

---

## 🚀 快速部署脚本

### 方式一：Git Clone（推荐）

```bash
# 1. 克隆配置仓库到新 workspace
cd /path/to/new/workspace
git clone <your-config-repo-url> .

# 2. 确保 OpenClaw 指向新 workspace
openclaw config set workspace /path/to/new/workspace

# 3. 重启 Gateway
openclaw gateway restart
```

### 方式二：手动复制

```bash
# 复制核心配置文件
cp -r /home/admin/.openclaw/workspace-main/{SOUL.md,AGENTS.md,USER.md,IDENTITY.md,MEMORY.md,TOOLS.md,HEARTBEAT.md} /path/to/new/workspace/

# 复制 memory 目录（如有）
cp -r /home/admin/.openclaw/workspace-main/memory /path/to/new/workspace/
```

### 方式三：自动化脚本

创建 `setup-openclaw.sh`：

```bash
#!/bin/bash
set -e

WORKSPACE_DIR="${1:-$HOME/.openclaw/workspace-main}"

echo "🔧 正在配置 OpenClaw 工作区：$WORKSPACE_DIR"

# 创建工作区目录
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR/memory"

# 创建核心文件（如果不存在）
files=("SOUL.md" "AGENTS.md" "USER.md" "IDENTITY.md" "MEMORY.md" "TOOLS.md" "HEARTBEAT.md")

for file in "${files[@]}"; do
    if [ ! -f "$WORKSPACE_DIR/$file" ]; then
        echo "📄 创建 $file"
        # 从模板或备份复制
        # cp "/path/to/backup/$file" "$WORKSPACE_DIR/$file"
    fi
done

# 设置权限
chmod 644 "$WORKSPACE_DIR"/*.md

echo "✅ 配置完成！"
echo "📌 下一步：编辑 USER.md 和 IDENTITY.md 填入你的信息"
```

---

## 📝 核心文件配置说明

### 1. SOUL.md - AI 人格定义

**作用**：定义 AI 的核心行为准则和性格

**关键配置项**：
- 核心真理（Core Truths）
- 边界规则（Boundaries）
- 交流风格（Vibe）

**示例要点**：
```markdown
- 真诚帮助，不表演式帮助
- 有观点，可以表达偏好
- 先尝试自己解决，再提问
- 通过能力赢得信任
- 尊重隐私，谨慎对外操作
```

---

### 2. AGENTS.md - 工作区行为规范

**作用**：定义 AI 在日常工作中的行为模式

**关键配置项**：
- 会话启动流程（读取哪些文件）
- 记忆系统规则（MEMORY.md vs daily notes）
- 群聊行为规范
- 心跳任务指南
- 工具使用规范

**重要规则**：
```markdown
1. 会话启动必读：SOUL.md → USER.md → memory/YYYY-MM-DD.md → MEMORY.md(主会话)
2. 记忆分级：daily notes(原始日志) vs MEMORY.md(精选记忆)
3. 群聊：只在有价值时发言，使用表情反应
4. 心跳：2-4 次/天，检查邮件/日历/天气等
```

---

### 3. USER.md - 用户信息

**作用**：存储用户基本信息和偏好

**必填字段**：
```markdown
- Name: 用户姓名
- What to call them: 称呼方式
- Timezone: 时区 (如 Asia/Shanghai)
- Notes: 其他备注
- Context: 用户关心的项目、爱好等
```

---

### 4. IDENTITY.md - AI 身份定义

**作用**：定义 AI 的具体身份标识

**必填字段**：
```markdown
- Name: AI 的名字
- Creature: AI 的本质 (AI/robot/familiar 等)
- Vibe: 交流风格 (sharp/warm/casual 等)
- Emoji: 签名表情
- Avatar: 头像路径 (可选)
```

---

### 5. MEMORY.md - 长期记忆

**作用**：存储需要长期保留的重要信息

**内容类型**：
- 用户偏好和习惯
- 重要决策和结论
- 项目进度和状态
- 关键日期和事件

**维护规则**：
- 定期从 daily notes 提炼内容
- 删除过时信息
- 保持简洁，只保留精华

---

### 6. TOOLS.md - 本地工具配置

**作用**：存储环境特定的工具配置

**常见内容**：
```markdown
### Cameras
- living-room → 描述

### SSH
- home-server → IP, user

### TTS
- Preferred voice: "Nova"
- Default speaker: Kitchen HomePod
```

---

### 7. HEARTBEAT.md - 心跳任务

**作用**：配置周期性检查任务

**使用场景**：
- 邮件检查
- 日历提醒
- 天气查询
- 其他周期性任务

**保持简洁**：文件过大会增加 token 消耗

---

## 🔐 安全注意事项

### 不要复制的内容：
- ❌ 包含 API 密钥的文件
- ❌ 包含密码的文件
- ❌ 包含个人隐私的 MEMORY.md 内容（在共享环境）
- ❌ `.openclaw/config` 中的敏感配置

### 建议：
- ✅ 使用环境变量存储敏感信息
- ✅ 对敏感文件使用加密
- ✅ 在群聊/共享环境中不加载 MEMORY.md

---

## 📁 完整目录结构

```
workspace-main/
├── .git/                    # Git 版本控制（推荐）
├── .openclaw/               # OpenClaw 内部状态
│   └── workspace-state.json
├── memory/                  # 每日记忆目录
│   ├── 2026-04-03.md
│   └── heartbeat-state.json
├── AGENTS.md                # ⭐ 核心：行为规范
├── SOUL.md                  # ⭐ 核心：人格定义
├── USER.md                  # ⭐ 核心：用户信息
├── IDENTITY.md              # ⭐ 核心：AI 身份
├── MEMORY.md                # ⭐ 核心：长期记忆
├── TOOLS.md                 # 工具配置
├── HEARTBEAT.md             # 心跳任务
└── DEPLOY-GUIDE.md          # 本部署指南
```

---

## ✅ 部署验证清单

部署完成后，逐项检查：

- [ ] 所有核心文件已创建
- [ ] USER.md 已填入用户信息
- [ ] IDENTITY.md 已定义 AI 身份
- [ ] SOUL.md 和 AGENTS.md 内容完整
- [ ] memory/ 目录已创建
- [ ] OpenClaw Gateway 已重启
- [ ] 测试发送消息，确认 AI 行为符合预期

---

## 🔄 更新与同步

### 从备份恢复：
```bash
# 拉取最新配置
cd /home/admin/.openclaw/workspace-main
git pull origin main

# 重启 Gateway 使配置生效
openclaw gateway restart
```

### 备份当前配置：
```bash
# 提交当前配置到 Git
cd /home/admin/.openclaw/workspace-main
git add .
git commit -m "Backup: $(date +%Y-%m-%d)"
git push origin main
```

---

## 🆘 故障排查

### AI 不读取配置文件：
1. 检查文件路径是否正确
2. 确认文件权限（应为 644）
3. 重启 OpenClaw Gateway

### 记忆系统不工作：
1. 确认 memory/ 目录存在
2. 检查 MEMORY.md 格式是否正确
3. 确认在主会话中（MEMORY.md 只在主会话加载）

### 心跳任务不执行：
1. 检查 HEARTBEAT.md 是否有内容
2. 确认 Gateway 心跳配置
3. 查看 Gateway 日志

---

## 📚 相关文档

- OpenClaw 官方文档：`/usr/local/lib/node_modules/openclaw/docs`
- 在线文档：https://docs.openclaw.ai
- 技能市场：https://clawhub.com
- 社区：https://discord.com/invite/clawd

---

_最后更新：2026-04-03_
_维护者：OpenClaw Agent_
