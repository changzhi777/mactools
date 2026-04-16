<#
.SYNOPSIS
    Windows 11 OpenClaw 环境一键配置脚本

.DESCRIPTION
    自动检测、安装、配置 OpenClaw 运行所需的所有环境组件
    支持 Node.js、Python、Git、Windows Terminal 的自动安装和配置
    内置国内镜像源，支持离线安装

.PARAMETER Menu
        直接显示菜单（默认）

.PARAMETER Install
        跳过菜单，直接执行全新安装

.PARAMETER Update
        跳过菜单，直接执行更新

.PARAMETER Uninstall
        跳过菜单，直接执行卸载

.PARAMETER Repair
        跳过菜单，直接执行修复

.PARAMETER Check
        跳过菜单，仅检查环境

.PARAMETER ConfigureMirrors
        跳过菜单，仅配置镜像源

.PARAMETER ViewLogs
        跳过菜单，仅查看日志

.PARAMETER DownloadOffline
        下载离线安装包

.PARAMETER Offline
        使用离线模式安装

.EXAMPLE
    .\Install-OpenClaw.ps1
    显示交互式菜单

.EXAMPLE
    .\Install-OpenClaw.ps1 -Install
    直接执行全新安装

.EXAMPLE
    .\Install-OpenClaw.ps1 -DownloadOffline
    下载离线安装包

.NOTES
    作者：BB小子 🤙
    版本：1.1.0
    日期：2026-04-16
    要求：PowerShell 5.1+，管理员权限
    许可：MIT License
#>

[CmdletBinding()]
param(
    [switch]$Menu,
    [switch]$Install,
    [switch]$Update,
    [switch]$Uninstall,
    [switch]$Repair,
    [switch]$Check,
    [switch]$ConfigureMirrors,
    [switch]$ViewLogs,
    [switch]$DownloadOffline,
    [switch]$Offline
)

#region ============================================================================
# 脚本元数据和版本信息
#==============================================================================

$ScriptVersion = "1.1.0"
$ScriptName = "Install-OpenClaw"
$ScriptAuthor = "BB小子 🤙"
$ScriptDate = "2026-04-16"

#endregion

#region ============================================================================
# 配置常量区域
#==============================================================================

# 版本配置
$NodeJsVersion = "22.14.0"
$PythonVersion = "3.12.0"
$GitVersion = "2.46.0"

# 组件配置
$ComponentConfig = @{
    NodeJs = @{
        Name = "Node.js"
        Version = $NodeJsVersion
        Mirror = "https://npmmirror.com/mirrors/node"
        FilePattern = "node-v{version}-win-{arch}.zip"
        InstallPath = "$env:LOCALAPPDATA\Programs\nodejs"
        Executable = "node.exe"
    }
    Python = @{
        Name = "Python"
        Version = $PythonVersion
        Mirror = "https://mirrors.tuna.tsinghua.edu.cn/python"
        FilePattern = "python-{version}-{arch}.exe"
        InstallPath = "$env:LOCALAPPDATA\Programs\Python"
        Executable = "python.exe"
    }
    Git = @{
        Name = "Git"
        Version = $GitVersion
        Mirror = "https://mirrors.tuna.tsinghua.edu.cn/git-for-windows"
        FilePattern = "Git-{arch}.exe"
        InstallPath = "$env:ProgramFiles\Git"
        Executable = "git.exe"
    }
}

# 国内镜像源配置
$NpmMirror = "https://registry.npmmirror.com"
$GitHubProxy = "https://mirror.ghproxy.com/https://github.com"
$OpenClawMirror = "https://openclaw.ai"

# 文件路径配置
$DocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
$BaseDir = Join-Path $DocumentsFolder "openclaw-installer"
$LogDir = Join-Path $BaseDir "logs"
$BackupDir = Join-Path $BaseDir "backup"
$PackageDir = Join-Path $BaseDir "packages"
$ConfigFile = Join-Path $BaseDir "config.json"

# 日志文件
$LogFile = Join-Path $LogDir "install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$MaxLogSize = 10MB

# 下载配置
$DownloadTimeout = 300
$MaxRetryCount = 3
$UseParallelDownload = $true

# 进度条配置
$ProgressActivity = "OpenClaw 环境配置"

#endregion

#region ============================================================================
# 工具函数库
#==============================================================================

<#
.SYNOPSIS
    彩色输出函数
#>
function Write-ColorOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Success", "Error", "Warning", "Info", "Header")]
        [string]$Level = "Info"
    )

    $color = switch ($Level) {
        "Success" { "Green" }
        "Error"   { "Red" }
        "Warning" { "Yellow" }
        "Info"    { "Cyan" }
        "Header"  { "Magenta" }
    }

    $prefix = switch ($Level) {
        "Success" { "✓ " }
        "Error"   { "✗ " }
        "Warning" { "⚠ " }
        "Info"    { "ℹ " }
        "Header"  { "► " }
    }

    Write-Host "$prefix$Message" -ForegroundColor $color

    # 记录到日志
    $logLevel = switch ($Level) {
        "Success" { "INFO" }
        "Error"   { "ERROR" }
        "Warning" { "WARN" }
        "Info"    { "INFO" }
        "Header"  { "INFO" }
    }
    Write-Log -Message $Message -Level $logLevel
}

<#
.SYNOPSIS
    写入进度
#>
function Write-ScriptProgress {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,

        [Parameter(Mandatory=$false)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        [Parameter(Mandatory=$false)]
        [string]$CurrentOperation
    )

    if ($PSBoundParameters.ContainsKey('PercentComplete')) {
        Write-Progress -Activity $ProgressActivity -Status $Status -PercentComplete $PercentComplete -CurrentOperation $CurrentOperation
    }
    else {
        Write-Progress -Activity $ProgressActivity -Status $Status
    }
}

<#
.SYNOPSIS
    初始化日志系统
#>
function Initialize-Logger {
    try {
        # 创建所有必需的目录
        $dirs = @($LogDir, $BackupDir, $PackageDir)
        foreach ($dir in $dirs) {
            if (-not (Test-Path $dir)) {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
                Write-ColorOutput "创建目录: $dir" "Success"
            }
        }

        # 写入日志头
        $logHeader = @"
================================================================================
OpenClaw 环境配置脚本 - 安装日志
脚本版本: $ScriptVersion
开始时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
操作系统: $([System.Environment]::OSVersion.VersionString)
PowerShell 版本: $($PSVersionTable.PSVersion)
计算机名: $env:COMPUTERNAME
用户名: $env:USERNAME
================================================================================
"@

        Add-Content -Path $LogFile -Value $logHeader

        return $true
    }
    catch {
        Write-Warning "无法初始化日志系统: $_"
        return $false
    }
}

<#
.SYNOPSIS
    写入日志
#>
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        Add-Content -Path $LogFile -Value $logEntry

        # 日志轮转
        $logItem = Get-Item $LogFile -ErrorAction SilentlyContinue
        if ($logItem -and $logItem.Length -gt $MaxLogSize) {
            $archiveFile = $LogFile -replace '\.log$', "-old.log"
            if (Test-Path $archiveFile) {
                Remove-Item $archiveFile -Force
            }
            Move-Item -Path $LogFile -Destination $archiveFile -Force
            Add-Content -Path $LogFile -Value "=== 日志轮转，旧日志已归档 ==="
        }
    }
    catch {
        # 静默失败，避免影响主流程
    }
}

<#
.SYNOPSIS
    测试网络连接
#>
function Test-NetworkConnection {
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$TestUrls = @(
            "https://www.baidu.com",
            "https://registry.npmmirror.com",
            "https://github.com"
        ),

        [Parameter(Mandatory=$false)]
        [ValidateRange(1, 60)]
        [int]$TimeoutSeconds = 10
    )

    Write-ColorOutput "正在测试网络连接..." "Info"

    $results = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($url in $TestUrls) {
        try {
            $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec $TimeoutSeconds -UseBasicParsing -ErrorAction Stop
            $results.Add([PSCustomObject]@{
                Url = $url
                Status = "成功"
                StatusCode = $response.StatusCode
            })
            Write-ColorOutput "  ✓ $url" "Success"
        }
        catch {
            $statusCode = try { $_.Exception.Response.StatusCode.value__ } catch { "N/A" }
            $results.Add([PSCustomObject]@{
                Url = $url
                Status = "失败"
                StatusCode = $statusCode
            })
            Write-ColorOutput "  ✗ $url - $($_.Exception.Message)" "Error"
        }
    }

    return $results
}

<#
.SYNOPSIS
    获取系统架构
#>
function Get-SystemArchitecture {
    return if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
}

<#
.SYNOPSIS
    通用下载函数
#>
function Invoke-DownloadComponent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$MirrorUrl,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePattern,

        [Parameter(Mandatory=$false)]
        [string]$Architecture = (Get-SystemArchitecture)
    )

    Write-ColorOutput "`n=== 下载 $Name ===" "Header"

    try {
        # 构建文件名和下载 URL
        $fileName = $FilePattern -replace '\{version\}', $Version -replace '\{arch\}', $Architecture
        $downloadUrl = if ($MirrorUrl.EndsWith('/')) {
            "$MirrorUrl$Version/$fileName"
        } else {
            "$MirrorUrl/$Version/$fileName"
        }

        $outputPath = Join-Path $PackageDir $fileName

        # 检查是否已存在
        if (Test-Path $outputPath) {
            $fileSize = (Get-Item $outputPath).Length
            if ($fileSize -gt 1MB) {
                Write-ColorOutput "安装包已存在，跳过下载" "Info"
                Write-ColorOutput "文件大小: $([math]::Round($fileSize/1MB, 2)) MB" "Info"
                return $outputPath
            } else {
                Write-ColorOutput "已存在的文件可能损坏，重新下载" "Warning"
                Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
            }
        }

        Write-ColorOutput "正在下载: $fileName" "Info"
        Write-ColorOutput "URL: $downloadUrl" "Info"

        # 使用 WebClient 下载
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
        $webClient.DownloadFile($downloadUrl, $outputPath)
        $webClient.Dispose()

        # 验证文件
        if (Test-Path $outputPath) {
            $fileSize = (Get-Item $outputPath).Length
            if ($fileSize -gt 0) {
                Write-ColorOutput "✓ 下载完成，文件大小: $([math]::Round($fileSize/1MB, 2)) MB" "Success"
                return $outputPath
            } else {
                Write-ColorOutput "✗ 下载的文件大小为 0" "Error"
                Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
                return $null
            }
        } else {
            Write-ColorOutput "✗ 下载失败，文件未找到" "Error"
            return $null
        }
    }
    catch {
        Write-ColorOutput "✗ 下载失败: $_" "Error"
        Write-Log -Message "下载 $Name 失败: $_" -Level "ERROR"
        return $null
    }
}

<#
.SYNOPSIS
    测试系统先决条件
#>
function Test-Prerequisites {
    Write-ColorOutput "`n=== 检查系统先决条件 ===" "Header"

    $issues = [System.Collections.Generic.List[string]]::new()

    # 检查 PowerShell 版本
    Write-ColorOutput "`n检查 PowerShell 版本..." "Info"
    $psVersion = $PSVersionTable.PSVersion
    Write-ColorOutput "  当前版本: $psVersion" "Info"

    if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
        $issues.Add("PowerShell 版本过低，需要 5.1 或更高")
        Write-ColorOutput "  ✗ PowerShell 版本不符合要求" "Error"
    }
    else {
        Write-ColorOutput "  ✓ PowerShell 版本符合要求" "Success"
    }

    # 检查管理员权限
    Write-ColorOutput "`n检查管理员权限..." "Info"
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        $issues.Add("未以管理员身份运行，某些功能可能无法使用")
        Write-ColorOutput "  ⚠ 未检测到管理员权限" "Warning"
    }
    else {
        Write-ColorOutput "  ✓ 已获得管理员权限" "Success"
    }

    # 检查操作系统版本
    Write-ColorOutput "`n检查操作系统版本..." "Info"
    $buildNumber = (Get-CimInstance Win32_OperatingSystem).BuildNumber
    Write-ColorOutput "  版本: $([System.Environment]::OSVersion.VersionString)" "Info"
    Write-ColorOutput "  构建号: $buildNumber" "Info"

    if ($buildNumber -lt 22000) {
        $issues.Add("操作系统版本不是 Windows 11")
        Write-ColorOutput "  ⚠ 当前系统不是 Windows 11" "Warning"
    }
    else {
        Write-ColorOutput "  ✓ Windows 11 检测通过" "Success"
    }

    # 测试网络连接（仅在非离线模式下）
    if (-not $Offline) {
        Write-ColorOutput "`n测试网络连接..." "Info"
        $networkResults = Test-NetworkConnection
        $failedConnections = ($networkResults | Where-Object { $_.Status -eq "失败" }).Count

        if ($failedConnections -gt 0) {
            $issues.Add("部分网络连接失败，可能影响下载")
            Write-ColorOutput "  ⚠ $failedConnections 个网络连接测试失败" "Warning"
        }
        else {
            Write-ColorOutput "  ✓ 网络连接正常" "Success"
        }
    }

    # 显示问题汇总
    if ($issues.Count -gt 0) {
        Write-ColorOutput "`n⚠ 发现以下问题:" "Warning"
        foreach ($issue in $issues) {
            Write-ColorOutput "  • $issue" "Warning"
        }
        Write-ColorOutput "`n是否继续？(Y/N)" "Warning"
        $choice = Read-Host
        if ($choice -ne "Y" -and $choice -ne "y") {
            return $false
        }
    }
    else {
        Write-ColorOutput "`n✓ 所有检查通过！" "Success"
    }

    return $true
}

<#
.SYNOPSIS
    检查组件是否已安装
#>
function Test-ComponentInstalled {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("NodeJs", "Python", "Git", "WindowsTerminal")]
        [string]$ComponentName
    )

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
    }

    switch ($ComponentName) {
        "NodeJs" {
            try {
                $nodeVersion = node --version 2>$null
                if ($nodeVersion -match 'v(\d+\.\d+\.\d+)') {
                    $result.Installed = $true
                    $result.Version = $matches[1]
                    $result.Path = (Get-Command node).Source
                    Write-ColorOutput "  ✓ Node.js 已安装: v$($result.Version)" "Success"
                }
            } catch {}
            if (-not $result.Installed) {
                Write-ColorOutput "  ✗ Node.js 未安装" "Error"
            }
        }

        "Python" {
            try {
                $pythonVersion = python --version 2>&1
                if ($pythonVersion -match 'Python (\d+\.\d+\.\d+)') {
                    $result.Installed = $true
                    $result.Version = $matches[1]
                    $result.Path = (Get-Command python).Source
                    Write-ColorOutput "  ✓ Python 已安装: v$($result.Version)" "Success"
                }
            } catch {}
            if (-not $result.Installed) {
                Write-ColorOutput "  ✗ Python 未安装" "Error"
            }
        }

        "Git" {
            try {
                $gitVersion = git --version 2>$null
                if ($gitVersion -match 'git version (.+)') {
                    $result.Installed = $true
                    $result.Version = $matches[1]
                    $result.Path = (Get-Command git).Source
                    Write-ColorOutput "  ✓ Git 已安装: $($result.Version)" "Success"
                }
            } catch {}
            if (-not $result.Installed) {
                Write-ColorOutput "  ✗ Git 未安装" "Error"
            }
        }

        "WindowsTerminal" {
            try {
                $wtPackage = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
                if ($wtPackage) {
                    $result.Installed = $true
                    $result.Version = $wtPackage.Version
                    $result.Path = $wtPackage.InstallLocation
                    Write-ColorOutput "  ✓ Windows Terminal 已安装: v$($result.Version)" "Success"
                }
            } catch {}
            if (-not $result.Installed) {
                Write-ColorOutput "  ✗ Windows Terminal 未安装" "Error"
            }
        }
    }

    return $result
}

<#
.SYNOPSIS
    检查环境状态
#>
function Test-EnvironmentStatus {
    Write-ColorOutput "`n=== 检查当前环境状态 ===" "Header"

    Write-ColorOutput "`n检查 Node.js..." "Info"
    $nodeJsStatus = Test-ComponentInstalled -ComponentName "NodeJs"

    Write-ColorOutput "`n检查 Python..." "Info"
    $pythonStatus = Test-ComponentInstalled -ComponentName "Python"

    Write-ColorOutput "`n检查 Git..." "Info"
    $gitStatus = Test-ComponentInstalled -ComponentName "Git"

    Write-ColorOutput "`n检查 Windows Terminal..." "Info"
    $terminalStatus = Test-ComponentInstalled -ComponentName "WindowsTerminal"

    # 检查 npm 配置
    Write-ColorOutput "`n检查 npm 镜像配置..." "Info"
    try {
        $npmRegistry = npm config get registry
        if ($npmRegistry -eq $NpmMirror) {
            Write-ColorOutput "  ✓ npm 已配置淘宝镜像" "Success"
        }
        else {
            Write-ColorOutput "  ⚠ npm 当前镜像: $npmRegistry" "Warning"
        }
    }
    catch {
        Write-ColorOutput "  ✗ 无法检查 npm 配置" "Error"
    }

    return @{
        NodeJs = $nodeJsStatus
        Python = $pythonStatus
        Git = $gitStatus
        WindowsTerminal = $terminalStatus
    }
}

<#
.SYNOPSIS
    配置 npm 淘宝镜像
#>
function Set-NpmMirror {
    Write-ColorOutput "`n=== 配置 npm 镜像源 ===" "Header"

    try {
        Write-ColorOutput "设置 npm registry 为淘宝镜像..." "Info"
        npm config set registry $NpmMirror
        Write-ColorOutput "✓ npm 镜像配置完成" "Success"

        $currentRegistry = npm config get registry
        Write-ColorOutput "当前 registry: $currentRegistry" "Info"

        return $true
    }
    catch {
        Write-ColorOutput "✗ npm 镜像配置失败: $_" "Error"
        return $false
    }
}

<#
.SYNOPSIS
    恢复 npm 默认镜像
#>
function Restore-NpmMirror {
    Write-ColorOutput "`n=== 恢复 npm 默认镜像 ===" "Header"

    try {
        npm config set registry https://registry.npmjs.org/
        Write-ColorOutput "✓ npm 镜像已恢复为官方源" "Success"
        return $true
    }
    catch {
        Write-ColorOutput "✗ npm 镜像恢复失败: $_" "Error"
        return $false
    }
}

<#
.SYNOPSIS
    刷新环境变量
#>
function Refresh-EnvironmentVariables {
    try {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # 刷新注册表
        if (-not ("Win32.NativeMethods" -as [Type])) {
            Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, IntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out IntPtr lpdwResult);
"@
        }

        $HWND_BROADCAST = [IntPtr]0xffff
        $WM_SETTINGCHANGE = 0x1a
        $result = [IntPtr]::Zero

        [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [IntPtr]::Zero, "Environment", 2, 5000, [ref]$result) | Out-Null
    }
    catch {
        Write-Log -Message "刷新环境变量失败: $_" -Level "WARN"
    }
}

<#
.SYNOPSIS
    安装 Node.js
#>
function Install-NodeJs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$PackagePath
    )

    Write-ColorOutput "`n=== 安装 Node.js ===" "Header"

    try {
        # 如果没有提供安装包，尝试下载
        if ([string]::IsNullOrWhiteSpace($PackagePath) -or -not (Test-Path $PackagePath)) {
            $config = $ComponentConfig.NodeJs
            $PackagePath = Invoke-DownloadComponent -Name $config.Name -Version $config.Version -MirrorUrl $config.Mirror -FilePattern $config.FilePattern
            if (-not $PackagePath) {
                Write-ColorOutput "✗ 无法下载 Node.js 安装包" "Error"
                return $false
            }
        }

        Write-ColorOutput "正在解压 Node.js..." "Info"
        $architecture = Get-SystemArchitecture
        $extractPath = $ComponentConfig.NodeJs.InstallPath

        # 创建临时目录
        $tempDir = Join-Path $env:TEMP "nodejs-temp"
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

        try {
            # 解压 ZIP 文件
            Expand-Archive -Path $PackagePath -DestinationPath $tempDir -Force

            # 移动文件到目标位置
            $nodeSource = Join-Path $tempDir "node-v$NodeJsVersion-win-$architecture"
            if (Test-Path $extractPath) {
                Remove-Item $extractPath -Recurse -Force
            }
            New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
            Copy-Item -Path "$nodeSource\*" -Destination $extractPath -Recurse -Force

            # 添加到 PATH
            $pathVar = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($pathVar -notlike "*$extractPath*") {
                [Environment]::SetEnvironmentVariable("Path", "$pathVar;$extractPath", "User")
                Write-ColorOutput "✓ Node.js 已添加到 PATH" "Success"
            }

            Write-ColorOutput "✓ Node.js 安装完成" "Success"

            # 刷新环境变量
            Refresh-EnvironmentVariables

            return $true
        }
        finally {
            # 清理临时目录
            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-ColorOutput "✗ Node.js 安装失败: $_" "Error"
        Write-Log -Message "Node.js 安装失败: $_" -Level "ERROR"
        return $false
    }
}

<#
.SYNOPSIS
    安装 Python
#>
function Install-Python {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$PackagePath
    )

    Write-ColorOutput "`n=== 安装 Python ===" "Header"

    try {
        # 如果没有提供安装包，尝试下载
        if ([string]::IsNullOrWhiteSpace($PackagePath) -or -not (Test-Path $PackagePath)) {
            $config = $ComponentConfig.Python
            $PackagePath = Invoke-DownloadComponent -Name $config.Name -Version $config.Version -MirrorUrl $config.Mirror -FilePattern $config.FilePattern
            if (-not $PackagePath) {
                Write-ColorOutput "✗ 无法下载 Python 安装包" "Error"
                return $false
            }
        }

        Write-ColorOutput "正在静默安装 Python..." "Info"

        # 静默安装参数
        $installArgs = @(
            "/quiet",
            "InstallAllUsers=1",
            "PrependPath=1",
            "Include_test=0"
        ) -join " "

        $process = Start-Process -FilePath $PackagePath -ArgumentList $installArgs -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            Write-ColorOutput "✓ Python 安装完成" "Success"

            # 刷新环境变量
            Refresh-EnvironmentVariables

            return $true
        }
        else {
            Write-ColorOutput "✗ Python 安装失败，退出代码: $($process.ExitCode)" "Error"
            Write-Log -Message "Python 安装失败，退出代码: $($process.ExitCode)" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-ColorOutput "✗ Python 安装失败: $_" "Error"
        Write-Log -Message "Python 安装失败: $_" -Level "ERROR"
        return $false
    }
}

<#
.SYNOPSIS
    安装 Git
#>
function Install-Git {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$PackagePath
    )

    Write-ColorOutput "`n=== 安装 Git ===" "Header"

    try {
        # 如果没有提供安装包，尝试下载
        if ([string]::IsNullOrWhiteSpace($PackagePath) -or -not (Test-Path $PackagePath)) {
            $config = $ComponentConfig.Git
            $PackagePath = Invoke-DownloadComponent -Name $config.Name -Version $config.Version -MirrorUrl $config.Mirror -FilePattern $config.FilePattern
            if (-not $PackagePath) {
                Write-ColorOutput "✗ 无法下载 Git 安装包" "Error"
                return $false
            }
        }

        Write-ColorOutput "正在静默安装 Git..." "Info"

        # 静默安装参数
        $installArgs = @(
            "/VERYSILENT",
            "/NORESTART",
            "/NOCANCEL",
            "/SP-",
            "/CLOSEAPPLICATIONS",
            "/RESTARTAPPLICATIONS",
            "/COMPONENTS=gitlfs",
            "/EditorOption=VIM",
            "/PathOption=Cmd",
            "/SSHOption=OpenSSH"
        ) -join " "

        $process = Start-Process -FilePath $PackagePath -ArgumentList $installArgs -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            Write-ColorOutput "✓ Git 安装完成" "Success"

            # 刷新环境变量
            Refresh-EnvironmentVariables

            return $true
        }
        else {
            Write-ColorOutput "✗ Git 安装失败，退出代码: $($process.ExitCode)" "Error"
            Write-Log -Message "Git 安装失败，退出代码: $($process.ExitCode)" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-ColorOutput "✗ Git 安装失败: $_" "Error"
        Write-Log -Message "Git 安装失败: $_" -Level "ERROR"
        return $false
    }
}

<#
.SYNOPSIS
    安装 Windows Terminal
#>
function Install-WindowsTerminal {
    Write-ColorOutput "`n=== 安装 Windows Terminal ===" "Header"

    try {
        # 使用 winget 安装
        Write-ColorOutput "使用 winget 安装 Windows Terminal..." "Info"

        $process = Start-Process -FilePath "winget" -ArgumentList "install --id Microsoft.WindowsTerminal --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
            Write-ColorOutput "✓ Windows Terminal 安装完成" "Success"
            return $true
        }
        else {
            Write-ColorOutput "✗ Windows Terminal 安装失败，退出代码: $($process.ExitCode)" "Error"
            Write-ColorOutput "请手动从 Microsoft Store 安装" "Warning"
            Write-Log -Message "Windows Terminal 安装失败，退出代码: $($process.ExitCode)" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-ColorOutput "✗ Windows Terminal 安装失败: $_" "Error"
        Write-ColorOutput "请手动从 Microsoft Store 安装" "Warning"
        Write-Log -Message "Windows Terminal 安装失败: $_" -Level "ERROR"
        return $false
    }
}

<#
.SYNOPSIS
    全新安装所有组件
#>
function Install-AllComponents {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" "Header"
    Write-ColorOutput "║          开始全新安装 OpenClaw 环境                     ║" "Header"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Header"

    $startTime = Get-Date
    $results = @{}

    # 检查环境
    if (-not (Test-Prerequisites)) {
        Write-ColorOutput "✗ 环境检查失败，安装中止" "Error"
        return $false
    }

    # 配置镜像源
    Write-ColorOutput "`n=== 配置国内镜像源 ===" "Header"
    Set-NpmMirror

    # 下载或安装组件
    if ($DownloadOffline) {
        Write-ColorOutput "`n=== 下载离线安装包 ===" "Header"

        Write-ScriptProgress -Status "下载 Node.js" -PercentComplete 25
        $nodePackage = Invoke-DownloadComponent -Name "Node.js" -Version $NodeJsVersion -MirrorUrl $ComponentConfig.NodeJs.Mirror -FilePattern $ComponentConfig.NodeJs.FilePattern
        $results.NodeJs = ($null -ne $nodePackage)

        Write-ScriptProgress -Status "下载 Python" -PercentComplete 50
        $pythonPackage = Invoke-DownloadComponent -Name "Python" -Version $PythonVersion -MirrorUrl $ComponentConfig.Python.Mirror -FilePattern $ComponentConfig.Python.FilePattern
        $results.Python = ($null -ne $pythonPackage)

        Write-ScriptProgress -Status "下载 Git" -PercentComplete 75
        $gitPackage = Invoke-DownloadComponent -Name "Git" -Version $GitVersion -MirrorUrl $ComponentConfig.Git.Mirror -FilePattern $ComponentConfig.Git.FilePattern
        $results.Git = ($null -ne $gitPackage)

        Write-ScriptProgress -Status "下载完成" -PercentComplete 100 -Completed

        Write-ColorOutput "`n✓ 离线安装包下载完成" "Success"
        Write-ColorOutput "保存位置: $PackageDir" "Info"
    }
    else {
        Write-ScriptProgress -Status "安装 Node.js" -PercentComplete 20
        $results.NodeJs = Install-NodeJs

        Write-ScriptProgress -Status "安装 Python" -PercentComplete 40
        $results.Python = Install-Python

        Write-ScriptProgress -Status "安装 Git" -PercentComplete 60
        $results.Git = Install-Git

        Write-ScriptProgress -Status "安装 Windows Terminal" -PercentComplete 80
        $results.WindowsTerminal = Install-WindowsTerminal

        Write-ScriptProgress -Status "安装完成" -PercentComplete 100 -Completed
    }

    # 显示安装摘要
    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" "Header"
    Write-ColorOutput "║                    安装摘要                               ║" "Header"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Header"

    if ($DownloadOffline) {
        Write-ColorOutput "`n下载状态:" "Info"
        Write-ColorOutput "  Node.js: $(if ($results.NodeJs) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.NodeJs) { 'Success' } else { 'Error' })
        Write-ColorOutput "  Python: $(if ($results.Python) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.Python) { 'Success' } else { 'Error' })
        Write-ColorOutput "  Git: $(if ($results.Git) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.Git) { 'Success' } else { 'Error' })
    }
    else {
        Write-ColorOutput "`n组件安装状态:" "Info"
        Write-ColorOutput "  Node.js: $(if ($results.NodeJs) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.NodeJs) { 'Success' } else { 'Error' })
        Write-ColorOutput "  Python: $(if ($results.Python) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.Python) { 'Success' } else { 'Error' })
        Write-ColorOutput "  Git: $(if ($results.Git) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.Git) { 'Success' } else { 'Error' })
        Write-ColorOutput "  Windows Terminal: $(if ($results.WindowsTerminal) { '✓ 成功' } else { '✗ 失败' })" $(if ($results.WindowsTerminal) { 'Success' } else { 'Error' })

        # 验证安装
        Write-ColorOutput "`n=== 验证安装 ===" "Header"
        Test-EnvironmentStatus

        # 显示下一步操作
        if ($results.NodeJs -and $results.Git) {
            Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" "Header"
            Write-ColorOutput "║              环境配置完成！开始安装 OpenClaw              ║" "Header"
            Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Header"

            Write-ColorOutput "`n请运行以下命令安装 OpenClaw:" "Info"
            Write-ColorOutput "`n  powershell -c `"irm https://openclaw.ai/install.ps1 | iex`"`n" "Success"
        }
        else {
            Write-ColorOutput "`n⚠ 部分组件安装失败，请检查日志文件" "Warning"
            Write-ColorOutput "日志位置: $LogFile" "Info"
        }
    }

    Write-ColorOutput "`n总耗时: $($duration.Minutes) 分 $($duration.Seconds) 秒" "Info"
    Write-ColorOutput "日志文件: $LogFile" "Info"

    return $results
}

<#
.SYNOPSIS
    更新所有组件
#>
function Update-AllComponents {
    Write-ColorOutput "`n=== 更新所有组件 ===" "Header"
    Write-ColorOutput "此功能将检查并更新所有组件到最新版本" "Info"

    $confirm = Read-Host "是否继续？(Y/N)"
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        return $false
    }

    $results = @{}

    # 更新 Node.js
    Write-ColorOutput "`n检查 Node.js 更新..." "Info"
    $currentNode = Test-ComponentInstalled -ComponentName "NodeJs"
    if ($currentNode.Installed) {
        Write-ColorOutput "当前版本: $($currentNode.Version)" "Info"
        Write-ColorOutput "最新版本: $NodeJsVersion" "Info"
        $update = Read-Host "是否更新？(Y/N)"
        if ($update -eq "Y" -or $update -eq "y") {
            $results.NodeJs = Install-NodeJs
        }
    }
    else {
        Write-ColorOutput "Node.js 未安装，跳过更新" "Warning"
    }

    # 更新 Python
    Write-ColorOutput "`n检查 Python 更新..." "Info"
    $currentPython = Test-ComponentInstalled -ComponentName "Python"
    if ($currentPython.Installed) {
        Write-ColorOutput "当前版本: $($currentPython.Version)" "Info"
        Write-ColorOutput "最新版本: $PythonVersion" "Info"
        $update = Read-Host "是否更新？(Y/N)"
        if ($update -eq "Y" -or $update -eq "y") {
            $results.Python = Install-Python
        }
    }
    else {
        Write-ColorOutput "Python 未安装，跳过更新" "Warning"
    }

    # 更新 Git
    Write-ColorOutput "`n检查 Git 更新..." "Info"
    $currentGit = Test-ComponentInstalled -ComponentName "Git"
    if ($currentGit.Installed) {
        Write-ColorOutput "当前版本: $($currentGit.Version)" "Info"
        Write-ColorOutput "最新版本: $GitVersion" "Info"
        $update = Read-Host "是否更新？(Y/N)"
        if ($update -eq "Y" -or $update -eq "y") {
            $results.Git = Install-Git
        }
    }
    else {
        Write-ColorOutput "Git 未安装，跳过更新" "Warning"
    }

    Write-ColorOutput "`n✓ 更新完成" "Success"
    return $results
}

<#
.SYNOPSIS
    卸载所有组件
#>
function Uninstall-AllComponents {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" "Header"
    Write-ColorOutput "║              警告：即将卸载所有组件                      ║" "Header"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Header"

    Write-ColorOutput "`n此操作将卸载以下组件:" "Warning"
    Write-ColorOutput "  • Node.js" "Warning"
    Write-ColorOutput "  • Python" "Warning"
    Write-ColorOutput "  • Git" "Warning"
    Write-ColorOutput "  • Windows Terminal" "Warning"

    $confirm = Read-Host "`n确定要继续吗？(输入 '确认' 继续)"
    if ($confirm -ne "确认") {
        Write-ColorOutput "操作已取消" "Info"
        return $false
    }

    $results = @{}

    # 备份配置
    Write-ColorOutput "`n=== 备份配置 ===" "Header"
    $backupFile = Join-Path $BackupDir "config-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    try {
        # 备份 npm 配置
        $npmConfig = npm config list
        $backupData = @{
            NpmConfig = $npmConfig
            BackupDate = Get-Date
        }
        $backupData | ConvertTo-Json | Set-Content -Path $backupFile
        Write-ColorOutput "✓ 配置已备份到: $backupFile" "Success"
    }
    catch {
        Write-ColorOutput "⚠ 配置备份失败: $_" "Warning"
    }

    # 卸载 Node.js
    Write-ColorOutput "`n=== 卸载 Node.js ===" "Header"
    try {
        $nodePath = $ComponentConfig.NodeJs.InstallPath
        if (Test-Path $nodePath) {
            # 从 PATH 中移除
            $pathVar = [Environment]::GetEnvironmentVariable("Path", "User")
            $pathVar = $pathVar -replace [regex]::Escape("$nodePath;?), ""
            [Environment]::SetEnvironmentVariable("Path", $pathVar, "User")

            # 删除文件
            Remove-Item $nodePath -Recurse -Force -ErrorAction SilentlyContinue
            Write-ColorOutput "✓ Node.js 已卸载" "Success"
            $results.NodeJs = $true
        }
        else {
            Write-ColorOutput "⚠ Node.js 未安装" "Warning"
        }
    }
    catch {
        Write-ColorOutput "✗ Node.js 卸载失败: $_" "Error"
        $results.NodeJs = $false
    }

    # 卸载 Python
    Write-ColorOutput "`n=== 卸载 Python ===" "Header"
    try {
        # 查找 Python 安装
        $pythonPaths = @(
            "$env:LOCALAPPDATA\Programs\Python",
            "$env:LOCALAPPDATA\Programs\Python312",
            "$env:LOCALAPPDATA\Programs\Python311"
        )

        $uninstalled = $false
        foreach ($path in $pythonPaths) {
            if (Test-Path $path) {
                # 从 PATH 中移除
                $pathVar = [Environment]::GetEnvironmentVariable("Path", "User")
                $pathVar = $pathVar -replace [regex]::Escape("$path;?), ""
                [Environment]::SetEnvironmentVariable("Path", $pathVar, "User")

                # 删除文件
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-ColorOutput "✓ Python 已卸载 ($path)" "Success"
                $uninstalled = $true
            }
        }

        if (-not $uninstalled) {
            Write-ColorOutput "⚠ Python 未安装" "Warning"
        }
        $results.Python = $uninstalled
    }
    catch {
        Write-ColorOutput "✗ Python 卸载失败: $_" "Error"
        $results.Python = $false
    }

    # 卸载 Git
    Write-ColorOutput "`n=== 卸载 Git ===" "Header"
    try {
        $gitPath = $ComponentConfig.Git.InstallPath
        if (Test-Path $gitPath) {
            # 从 PATH 中移除
            $pathVar = [Environment]::GetEnvironmentVariable("Path", "User")
            $pathVar = $pathVar -replace [regex]::Escape("$gitPath\bin;?"), ""
            [Environment]::SetEnvironmentVariable("Path", $pathVar, "User")

            # 使用卸载程序
            $uninstaller = Get-ChildItem -Path "$gitPath\unins*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($uninstaller) {
                Start-Process -FilePath $uninstaller.FullName -ArgumentList "/S" -Wait
            }

            # 删除残留文件
            Remove-Item $gitPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-ColorOutput "✓ Git 已卸载" "Success"
            $results.Git = $true
        }
        else {
            Write-ColorOutput "⚠ Git 未安装" "Warning"
        }
    }
    catch {
        Write-ColorOutput "✗ Git 卸载失败: $_" "Error"
        $results.Git = $false
    }

    # 卸载 Windows Terminal
    Write-ColorOutput "`n=== 卸载 Windows Terminal ===" "Header"
    try {
        Get-AppxPackage -Name "Microsoft.WindowsTerminal" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-ColorOutput "✓ Windows Terminal 已卸载" "Success"
        $results.WindowsTerminal = $true
    }
    catch {
        Write-ColorOutput "✗ Windows Terminal 卸载失败: $_" "Error"
        Write-ColorOutput "请手动从设置中卸载" "Warning"
        $results.WindowsTerminal = $false
    }

    # 显示卸载摘要
    Write-ColorOutput "`n=== 卸载摘要 ===" "Header"
    Write-ColorOutput "Node.js: $(if ($results.NodeJs) { '✓ 已卸载' } else { '✗ 失败' })" $(if ($results.NodeJs) { 'Success' } else { 'Error' })
    Write-ColorOutput "Python: $(if ($results.Python) { '✓ 已卸载' } else { '✗ 失败' })" $(if ($results.Python) { 'Success' } else { 'Error' })
    Write-ColorOutput "Git: $(if ($results.Git) { '✓ 已卸载' } else { '✗ 失败' })" $(if ($results.Git) { 'Success' } else { 'Error' })
    Write-ColorOutput "Windows Terminal: $(if ($results.WindowsTerminal) { '✓ 已卸载' } else { '✗ 失败' })" $(if ($results.WindowsTerminal) { 'Success' } else { 'Error' })

    Write-ColorOutput "`n✓ 卸载完成" "Success"
    Write-ColorOutput "配置备份: $backupFile" "Info"

    return $results
}

<#
.SYNOPSIS
    修复安装
#>
function Repair-AllComponents {
    Write-ColorOutput "`n=== 修复安装 ===" "Header"
    Write-ColorOutput "此功能将检测并修复损坏的组件" "Info"

    $results = @{}

    # 修复 Node.js
    Write-ColorOutput "`n检查 Node.js..." "Info"
    $nodeStatus = Test-ComponentInstalled -ComponentName "NodeJs"
    if ($nodeStatus.Installed) {
        Write-ColorOutput "Node.js 已安装，验证完整性..." "Info"
        try {
            $testOutput = node --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ Node.js 正常" "Success"
                $results.NodeJs = $true
            }
            else {
                Write-ColorOutput "✗ Node.js 损坏，重新安装..." "Warning"
                $results.NodeJs = Install-NodeJs
            }
        }
        catch {
            Write-ColorOutput "✗ Node.js 损坏，重新安装..." "Warning"
            $results.NodeJs = Install-NodeJs
        }
    }
    else {
        Write-ColorOutput "Node.js 未安装" "Warning"
    }

    # 修复 Python
    Write-ColorOutput "`n检查 Python..." "Info"
    $pythonStatus = Test-ComponentInstalled -ComponentName "Python"
    if ($pythonStatus.Installed) {
        Write-ColorOutput "Python 已安装，验证完整性..." "Info"
        try {
            $testOutput = python --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ Python 正常" "Success"
                $results.Python = $true
            }
            else {
                Write-ColorOutput "✗ Python 损坏，重新安装..." "Warning"
                $results.Python = Install-Python
            }
        }
        catch {
            Write-ColorOutput "✗ Python 损坏，重新安装..." "Warning"
            $results.Python = Install-Python
        }
    }
    else {
        Write-ColorOutput "Python 未安装" "Warning"
    }

    # 修复 Git
    Write-ColorOutput "`n检查 Git..." "Info"
    $gitStatus = Test-ComponentInstalled -ComponentName "Git"
    if ($gitStatus.Installed) {
        Write-ColorOutput "Git 已安装，验证完整性..." "Info"
        try {
            $testOutput = git --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ Git 正常" "Success"
                $results.Git = $true
            }
            else {
                Write-ColorOutput "✗ Git 损坏，重新安装..." "Warning"
                $results.Git = Install-Git
            }
        }
        catch {
            Write-ColorOutput "✗ Git 损坏，重新安装..." "Warning"
            $results.Git = Install-Git
        }
    }
    else {
        Write-ColorOutput "Git 未安装" "Warning"
    }

    # 修复环境变量
    Write-ColorOutput "`n修复环境变量..." "Info"
    Refresh-EnvironmentVariables
    Write-ColorOutput "✓ 环境变量已刷新" "Success"

    # 显示修复摘要
    Write-ColorOutput "`n=== 修复摘要 ===" "Header"
    Write-ColorOutput "Node.js: $(if ($results.NodeJs) { '✓ 已修复' } else { '✗ 无需修复' })" $(if ($results.NodeJs) { 'Success' } else { 'Info' })
    Write-ColorOutput "Python: $(if ($results.Python) { '✓ 已修复' } else { '✗ 无需修复' })" $(if ($results.Python) { 'Success' } else { 'Info' })
    Write-ColorOutput "Git: $(if ($results.Git) { '✓ 已修复' } else { '✗ 无需修复' })" $(if ($results.Git) { 'Success' } else { 'Info' })

    Write-ColorOutput "`n✓ 修复完成" "Success"
    return $results
}

<#
.SYNOPSIS
    仅检查环境
#>
function Check-EnvironmentOnly {
    Write-ColorOutput "`n=== 环境检查报告 ===" "Header"

    Test-Prerequisites
    Test-EnvironmentStatus

    return $true
}

<#
.SYNOPSIS
    仅配置镜像源
#>
function Configure-MirrorsOnly {
    Write-ColorOutput "`n=== 配置镜像源 ===" "Header"

    Write-ColorOutput "`n1. 配置 npm 镜像" "Info"
    Set-NpmMirror

    Write-ColorOutput "`n2. 配置 Git 代理（可选）" "Info"
    $useProxy = Read-Host "是否配置 Git 代理？(Y/N)"
    if ($useProxy -eq "Y" -or $useProxy -eq "y") {
        $proxyUrl = Read-Host "请输入代理 URL（留空使用默认代理）"
        if ([string]::IsNullOrWhiteSpace($proxyUrl)) {
            $proxyUrl = $GitHubProxy
        }
        try {
            git config --global http.proxy $proxyUrl
            git config --global https.proxy $proxyUrl
            Write-ColorOutput "✓ Git 代理配置完成: $proxyUrl" "Success"
        }
        catch {
            Write-ColorOutput "✗ Git 代理配置失败: $_" "Error"
        }
    }

    Write-ColorOutput "`n✓ 镜像源配置完成" "Success"
    return $true
}

<#
.SYNOPSIS
    查看日志
#>
function View-LogsOnly {
    Write-ColorOutput "`n=== 查看日志 ===" "Header"

    $logFiles = Get-ChildItem -Path $LogDir -Filter "*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

    if (-not $logFiles -or $logFiles.Count -eq 0) {
        Write-ColorOutput "未找到日志文件" "Warning"
        return $false
    }

    Write-ColorOutput "`n最近的日志文件:" "Info"
    $displayCount = [Math]::Min(5, $logFiles.Count)
    for ($i = 0; $i -lt $displayCount; $i++) {
        $file = $logFiles[$i]
        $fileSize = [math]::Round($file.Length / 1KB, 2)
        Write-ColorOutput "  $($i + 1). $($file.Name) - $($file.LastWriteTime) - $fileSize KB" "Info"
    }

    $selection = Read-Host "`n请选择要查看的日志文件编号（1-$displayCount，0 返回）"

    if ($selection -match "^\d+$" -and $selection -gt 0 -and $selection -le $displayCount) {
        $selectedFile = $logFiles[$selection - 1]
        Write-ColorOutput "`n=== $($selectedFile.Name) ===" "Header"
        Write-ColorOutput "`n最近 50 行日志：" "Info"
        Get-Content -Path $selectedFile.FullName | Select-Object -Last 50
    }

    return $true
}

<#
.SYNOPSIS
    显示主菜单
#>
function Show-MainMenu {
    Clear-Host

    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════╗" "Header"
    Write-ColorOutput "║                                                                ║" "Header"
    Write-ColorOutput "║        OpenClaw 环境配置脚本 v$ScriptVersion                   ║" "Header"
    Write-ColorOutput "║        by $ScriptAuthor                                          ║" "Header"
    Write-ColorOutput "║                                                                ║" "Header"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Header"

    Write-ColorOutput "`n【主菜单】" "Header"
    Write-ColorOutput "  1. 全新安装" "Info"
    Write-ColorOutput "  2. 更新组件" "Info"
    Write-ColorOutput "  3. 卸载" "Info"
    Write-ColorOutput "  4. 修复安装" "Info"
    Write-ColorOutput "  5. 检查环境" "Info"
    Write-ColorOutput "  6. 配置镜像源" "Info"
    Write-ColorOutput "  7. 查看日志" "Info"
    Write-ColorOutput "  8. 退出" "Info"

    Write-ColorOutput "`n═════════════════════════════════════════════════════════════" "Info"

    $choice = Read-Host "请选择操作（1-8）"

    return $choice
}

<#
.SYNOPSIS
    主函数
#>
function Main {
    # 初始化日志
    Initialize-Logger

    # 检查是否使用命令行参数
    $directAction = $false
    $actionResult = $null

    if ($Install) {
        $actionResult = Install-AllComponents
        $directAction = $true
    }
    elseif ($Update) {
        $actionResult = Update-AllComponents
        $directAction = $true
    }
    elseif ($Uninstall) {
        $actionResult = Uninstall-AllComponents
        $directAction = $true
    }
    elseif ($Repair) {
        $actionResult = Repair-AllComponents
        $directAction = $true
    }
    elseif ($Check) {
        $actionResult = Check-EnvironmentOnly
        $directAction = $true
    }
    elseif ($ConfigureMirrors) {
        $actionResult = Configure-MirrorsOnly
        $directAction = $true
    }
    elseif ($ViewLogs) {
        $actionResult = View-LogsOnly
        $directAction = $true
    }
    elseif ($DownloadOffline) {
        $actionResult = Install-AllComponents
        $directAction = $true
    }

    # 如果是直接操作，执行后退出
    if ($directAction) {
        Write-ColorOutput "`n按任意键退出..." "Info"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    # 交互式菜单循环
    do {
        $choice = Show-MainMenu

        switch ($choice) {
            "1" {
                $Offline = $false
                Install-AllComponents
            }
            "2" {
                Update-AllComponents
            }
            "3" {
                Uninstall-AllComponents
            }
            "4" {
                Repair-AllComponents
            }
            "5" {
                Check-EnvironmentOnly
            }
            "6" {
                Configure-MirrorsOnly
            }
            "7" {
                View-LogsOnly
            }
            "8" {
                Write-ColorOutput "`n感谢使用！再见 🤙" "Success"
                break
            }
            default {
                Write-ColorOutput "`n无效的选择，请重新输入" "Warning"
            }
        }

        if ($choice -ne "8") {
            Write-ColorOutput "`n按任意键返回主菜单..." "Info"
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($choice -ne "8")
}

# 启动主函数
Main

#endregion
