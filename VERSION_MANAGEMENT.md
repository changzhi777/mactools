# 版本管理指南 - MacTools

**项目**: MacTools
**作者**: 外星动物（常智）
**组织**: IoTchange
**邮箱**: 14455975@qq.com
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 📋 版本号规则

### 版本格式

```
V主版本.次版本.修订版本
```

**示例**: `V1.0.1`

### 版本号说明

| 部分 | 名称 | 说明 | 示例 |
|------|------|------|------|
| **第一位** | 主版本 | 重大架构变更、不兼容的API修改 | V1.0.0 → V2.0.0 |
| **第二位** | 次版本 | 功能添加、向后兼容的功能变更 | V1.0.0 → V1.1.0 |
| **第三位** | 修订版本 | Bug修复、小改进、文档更新 | V1.0.1 → V1.0.2 |

### 自动化规则

- ✅ **每次推送**: 修订版本号 +1（V1.0.1 → V1.0.2）
- ✅ **新功能**: 次版本号 +1，修订版本归零（V1.0.1 → V1.1.0）
- ✅ **重大变更**: 主版本号 +1，次版本和修订版本归零（V1.0.1 → V2.0.0）

---

## 🚀 版本管理工具

### 使用 version.sh 脚本

项目提供了 `version.sh` 脚本用于自动化版本管理。

#### 显示当前版本

```bash
./version.sh --version
# 输出: V1.0.1
```

#### 增加修订版本号（每次推送）

```bash
./version.sh --increment
# 或直接运行
./version.sh
# 效果: V1.0.1 → V1.0.2
```

#### 增加次版本号（新功能）

```bash
./version.sh --bump MINOR
# 效果: V1.0.1 → V1.1.0
```

#### 增加主版本号（重大变更）

```bash
./version.sh --bump MAJOR
# 效果: V1.0.1 → V2.0.0
```

#### 设置特定版本号

```bash
./version.sh --set V1.2.3
# 效果: 设置版本为 V1.2.3
```

#### 检查版本一致性

```bash
./version.sh --check
# 检查所有文件的版本号是否一致
```

#### 完整工作流（推送时）

```bash
# 1. 进行代码修改
git add .
git commit -m "feat: 添加新功能"

# 2. 更新版本号
./version.sh

# 3. 脚本会自动：
#    - 更新 VERSION 文件
#    - 更新 README.md
#    - 更新所有脚本文件
#    - 创建 Git 提交
#    - 推送到 GitHub
```

---

## 📝 文件头部格式

### 标准格式

所有脚本文件都应包含以下标准头部：

```bash
#!/bin/bash
#
# 文件/脚本描述
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 详细说明文件用途
#
```

### 示例

```bash
#!/bin/bash
#
# MacClaw Installer - 一键安装脚本
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 一键安装 OpenClaw + oMLX + 本地 AI 模型
# 使用: curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
#
```

---

## 🔄 工作流程

### 日常开发流程

1. **进行代码修改**
   ```bash
   # 编辑代码
   vim macclaw-installer/install.sh

   # 测试修改
   ./tests/run_e2e_tests.sh
   ```

2. **提交代码**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   ```

3. **更新版本号**
   ```bash
   ./version.sh
   ```

4. **推送到 GitHub**
   ```bash
   git push
   ```

### 功能发布流程

1. **完成功能开发**
   ```bash
   # 确保所有测试通过
   ./tests/run_e2e_tests.sh
   ```

2. **增加次版本号**
   ```bash
   ./version.sh --bump MINOR
   ```

3. **创建 Git 标签（可选）**
   ```bash
   git tag -a v1.1.0 -m "发布 v1.1.0"
   git push origin v1.1.0
   ```

### 重大版本发布流程

1. **完成重大变更**
   - 更新 CHANGELOG.md
   - 更新文档
   - 完成所有测试

2. **增加主版本号**
   ```bash
   ./version.sh --bump MAJOR
   ```

3. **创建发布标签**
   ```bash
   git tag -a v2.0.0 -m "发布 v2.0.0 - 重大变更说明"
   git push origin v2.0.0
   ```

---

## 📊 版本历史

### 当前版本: V1.0.1

**更新内容**:
- ✅ 初始版本发布
- ✅ MacClaw Installer 一键安装功能
- ✅ GitHub SSH 配置脚本
- ✅ UI/UX Pro Max 提示词资源
- ✅ e2e 测试框架

### 版本计划

- **V1.1.0** - 计划中
  - [ ] 增加更多 AI 模型支持
  - [ ] Web UI 优化
  - [ ] Docker 支持

- **V2.0.0** - 未来版本
  - [ ] 多平台支持（Linux）
  - [ ] 插件系统
  - [ ] 云端同步功能

---

## 🛠️ 维护任务

### 每次推送前

- [ ] 运行测试套件
- [ ] 更新版本号（修订版本+1）
- [ ] 更新 CHANGELOG.md
- [ ] 检查版本一致性

### 每周

- [ ] 检查 GitHub Issues
- [ ] 更新文档
- [ ] 代码审查

### 每月

- [ ] 发布稳定版本
- [ ] 性能优化
- [ ] 安全审计

---

## 📞 联系方式

**作者**: 外星动物（常智）
**组织**: IoTchange
**邮箱**: 14455975@qq.com
**项目**: https://github.com/changzhi777/mactools
**问题反馈**: https://github.com/changzhi777/mactools/issues

---

## ⚖️ 许可证

Copyright (C) 2026 IoTchange - All Rights Reserved

---

**📌 记住：每次推送前都要运行 `./version.sh` 更新版本号！**
