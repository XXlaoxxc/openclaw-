# OpenClaw 快速参考卡

## 🚀 5 分钟快速配置

### 新机器部署
```bash
# 1. 安装 OpenClaw
npm install -g openclaw

# 2. 运行一键配置脚本
cd /path/to/workspace
./setup-openclaw.sh

# 3. 编辑用户信息
nano USER.md
nano IDENTITY.md

# 4. 重启 Gateway
openclaw gateway restart
```

### 从备份恢复
```bash
./setup-openclaw.sh --from-backup ~/oc-backup-2026-04-03
```

---

## 📁 核心文件速查

| 文件 | 作用 | 编辑频率 |
|------|------|----------|
| `SOUL.md` | AI 人格 | 首次配置 |
| `AGENTS.md` | 行为规范 | 首次配置 |
| `USER.md` | 用户信息 | 偶尔更新 |
| `IDENTITY.md` | AI 身份 | 首次配置 |
| `MEMORY.md` | 长期记忆 | 定期更新 |
| `TOOLS.md` | 工具配置 | 按需添加 |
| `HEARTBEAT.md` | 心跳任务 | 按需配置 |

---

## 🔧 常用命令

```bash
# 查看状态
openclaw status
openclaw gateway status

# 重启 Gateway
openclaw gateway restart

# 配置工作区
openclaw config set workspace /path/to/workspace

# 备份配置
./backup-config.sh
./backup-config.sh --git

# 查看日志
openclaw gateway logs
```

---

## 🧠 记忆系统

```
memory/YYYY-MM-DD.md  → 每日原始日志
MEMORY.md             → 精选长期记忆
```

**维护规则**：
- 每天创建新的 daily note
- 每周回顾，提炼到 MEMORY.md
- 删除过时信息

---

## 💓 心跳任务

在 `HEARTBEAT.md` 添加周期性检查：

```markdown
# 每日检查
- [ ] 未读邮件
- [ ] 今日日历
- [ ] 天气查询
```

---

## 🔐 安全提醒

**不要复制**：
- ❌ API 密钥
- ❌ 密码
- ❌ 敏感个人信息（共享环境）

**建议**：
- ✅ 使用环境变量
- ✅ Git 忽略敏感文件
- ✅ 定期备份

---

## 📚 完整文档

- 部署指南：`DEPLOY-GUIDE.md`
- 官方文档：https://docs.openclaw.ai
- 技能市场：https://clawhub.com

---

_打印此卡片作为快速参考_
