#!/bin/bash
#
# Fix Chinese test names in Bats files
#

cd "/Users/mac/cz_code/mactools/tests/e2e"

# Fix test_01_environment.bats
sed -i '' 's/@test "检测 macOS 版本" {@test "Check macOS version" {@g' test_01_environment.bats
sed -i '' 's/@test "检测 macOS 主版本号" {@test "Check macOS major version" {@g' test_01_environment.bats
sed -i '' 's/@test "检测系统架构" {@test "Check system architecture" {@g' test_01_environment.bats
sed -i '' 's/@test "验证系统架构兼容性" {@test "Verify system architecture compatibility" {@g' test_01_environment.bats
sed -i '' 's/@test "检测磁盘可用空间" {@test "Check available disk space" {@g' test_01_environment.bats
sed -i '' 's/@test "验证磁盘空间满足要求" {@test "Verify disk space requirements" {@g' test_01_environment.bats
sed -i '' 's/@test "检测 curl 工具" {@test "Check curl tool" {@g' test_01_environment.bats
sed -i '' 's/@test "检测 git 工具" {@test "Check git tool" {@g' test_01_environment.bats
sed -i '' 's/@test "检测 bash 版本" {@test "Check bash version" {@g' test_01_environment.bats
sed -i '' 's/@test "检测常用系统工具" {@test "Check common system tools" {@g' test_01_environment.bats

echo "Fixed test_01_environment.bats"

# 运行测试验证
echo ""
echo "Running test to verify..."
bats test_00_simple.bats test_01_environment.bats --tap | head -20
