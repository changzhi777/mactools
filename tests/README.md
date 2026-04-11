# MacClaw Installer e2e 测试

**版本**: 1.0.0
**测试框架**: Bats-core
**测试环境**: macOS 12+

---

## 📋 测试概述

本测试套件为 MacClaw Installer 提供端到端（e2e）测试，验证安装脚本在各种场景下的功能完整性和稳定性。

---

## 🚀 快速开始

### 安装 Bats 测试框架

```bash
# 方法 1: 使用 Homebrew（推荐）
brew install bats-core

# 方法 2: 手动安装到用户目录
mkdir -p ~/.local/bin
cd /tmp && git clone --depth 1 https://github.com/bats-core/bats.git
cd bats && PREFIX=~/.local ./install.sh ~/.local

# 验证安装
bats --version
```

### 运行所有测试

```bash
# 使用测试运行器
./tests/run_e2e_tests.sh

# 或直接使用 Bats
bats tests/e2e/
```

### 运行特定测试

```bash
# 列出所有测试
./tests/run_e2e_tests.sh --list

# 运行特定测试文件
./tests/run_e2e_tests.sh --file tests/e2e/test_01_environment.bats

# 或使用 Bats 直接运行
bats tests/e2e/test_01_environment.bats
```

---

## 📁 测试结构

```
tests/
├── e2e/                           # e2e 测试文件
│   ├── test_01_environment.bats   # 环境检测测试
│   ├── test_02_online_install.bats # 在线安装测试
│   ├── test_03_local_install.bats  # 本地安装测试
│   ├── test_04_components.bats     # 组件功能测试
│   ├── test_05_error_handling.bats # 错误处理测试
│   └── test_06_uninstall.bats      # 卸载测试
├── helpers/                       # 测试辅助函数
│   ├── fixtures.bash              # 测试数据 fixtures
│   └── assertions.bash            # 自定义断言
├── test_helper/                   # 测试辅助库
│   └── common-setup.bash          # 公共设置
├── run_e2e_tests.sh              # 测试运行器
└── README.md                     # 本文档
```

---

## 📊 测试覆盖

### 1. 环境检测测试 (test_01_environment.bats)

验证系统环境是否满足安装要求：

- ✅ macOS 版本检测（12+）
- ✅ 系统架构检测（Apple Silicon/Intel）
- ✅ 磁盘空间检查（至少 20GB）
- ✅ 依赖工具检测（curl, git, bash）
- ✅ 网络连接测试
- ✅ 用户权限验证
- ✅ 项目文件结构完整性

### 2. 在线安装测试 (test_02_online_install.bats)

验证在线安装模式的可用性：

- ✅ GitHub Raw URL 可访问性
- ✅ 在线脚本内容完整性
- ✅ 在线安装模式检测逻辑
- ✅ 脚本语法正确性
- ✅ 依赖文件可访问性
- ✅ 版本一致性检查

### 3. 本地安装测试 (test_03_local_install.bats)

验证本地安装脚本的完整性：

- ✅ 安装脚本存在性和权限
- ✅ 库文件完整性
- ✅ 配置文件格式
- ✅ 组件脚本可用性
- ✅ 卸载脚本完整性
- ✅ 脚本功能模块覆盖
- ✅ 错误处理机制

### 4. 组件功能测试 (test_04_components.bats)

验证已安装组件的功能（可选）：

- ✅ Node.js 和 npm 可用性
- ✅ nvm 安装检查
- ✅ OpenClaw CLI 功能
- ✅ oMLX 服务状态
- ✅ gemma-4 模型文件
- ✅ Skills 组件
- ✅ 服务集成验证
- ✅ 配置文件验证

### 5. 错误处理测试 (test_05_error_handling.bats)

验证各种错误场景的处理：

- ✅ 无效参数处理
- ✅ 权限错误处理
- ✅ 文件系统错误
- ✅ 网络错误处理
- ✅ 资源限制处理
- ✅ 并发冲突处理
- ✅ 依赖缺失处理
- ✅ 边界条件测试

### 6. 卸载测试 (test_06_uninstall.bats)

验证卸载脚本的完整性：

- ✅ 卸载脚本结构
- ✅ 清理逻辑覆盖
- ✅ 安全性检查
- ✅ 备份功能
- ✅ 服务停止逻辑
- ✅ 残留文件清理
- ✅ 用户数据保护

---

## 🔧 开发指南

### 编写新的测试用例

1. 在 `tests/e2e/` 下创建新的 `.bats` 文件
2. 包含公共设置：

```bash
#!/usr/bin/env bats

setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"
    source "${PROJECT_ROOT}/tests/helpers/assertions.bash"
}

teardown() {
    cleanup_test_env
}

@test "测试描述" {
    # 测试代码
    [ "condition" = "true" ]
}
```

### 使用辅助函数

```bash
# 检查命令是否存在
command_exists "openclaw"

# 检查服务是否运行
service_running 8008

# HTTP 请求
http_get "http://127.0.0.1:8008/health"

# 断言函数
assert_openclaw_installed
assert_omlx_service_running
```

### 跳过耗时测试

```bash
@test "耗时测试示例" {
    skip "此测试耗时较长，默认跳过"
    # 测试代码
}
```

---

## 📈 测试报告

### TAP 格式输出

```bash
bats tests/e2e/ --tap
```

### 带时间戳的输出

```bash
bats tests/e2e/ --timing
```

### 详细报告

```bash
bats tests/e2e/ --verbose-report
```

---

## 🐛 调试测试

### 启用详细输出

```bash
BATS_VERBOSE_RUN=1 ./tests/run_e2e_tests.sh
```

### 查看特定测试的输出

```bash
bats --print-output-on-failure tests/e2e/test_01_environment.bats
```

### 调试单个测试

```bash
bats --filter "检测 macOS 版本" tests/e2e/
```

---

## ⚠️ 注意事项

### 测试环境

- 测试应该在真实的 macOS 环境中运行
- 某些测试需要网络连接
- 建议在测试前备份重要数据

### 测试时间

- 快速测试（环境检测）：~1 分钟
- 完整测试套件：~5-10 分钟
- 包含跳过的测试：可能需要 30+ 分钟

### 清理

- 测试会创建临时文件在 `/tmp` 目录
- 测试失败后可能需要手动清理
- 使用 `teardown` 函数确保清理

---

## 🤝 贡献指南

### 添加新测试

1. 确定测试类别（环境、安装、组件等）
2. 创建相应的 `.bats` 文件
3. 编写测试用例
4. 更新此文档

### 测试命名规范

- 文件名：`test_<编号>_<类别>.bats`
- 测试函数：使用清晰的描述性名称
- 注释：添加必要的注释说明

### 代码审查

- 确保测试独立性
- 避免测试间的依赖
- 提供清晰的错误消息

---

## 📞 获取帮助

### 问题排查

1. 查看测试报告了解失败原因
2. 检查系统日志：`~/macclaw-install.log`
3. 验证环境配置：`./tests/run_e2e_tests.sh --list`

### 联系方式

- **作者**: 外星动物（常智）
- **邮箱**: 14455975@qq.com
- **项目**: https://github.com/changzhi777/mactools
- **问题反馈**: https://github.com/changzhi777/mactools/issues

---

## 📝 更新日志

### v1.0.0 (2026-04-11)

- ✅ 初始版本
- ✅ 6 个测试文件，50+ 测试用例
- ✅ 完整的测试辅助函数库
- ✅ 测试运行器和文档

---

**🎯 让测试成为质量的保障！**
