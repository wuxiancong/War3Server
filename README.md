# War3Server

**War3Server** 是一款免费开源的跨平台服务器软件，基于 **PVPGN** 项目，支持 Battle.net 和 Westwood Online 游戏客户端。由于 Pvpgn 项目已于 2011 年停止开发，War3Server 旨在为其提供持续维护和额外功能支持（只更新魔兽争霸部分）。

## 目录
- [功能配置](#功能配置)
- [支持的客户端](#支持的客户端)
- [安装指南 (Ubuntu 16.04/18.04)](#安装指南-ubuntu-1604-1804)
- [配置与启动](#配置与启动)
- [Systemd 服务配置](#systemd-服务配置)
- [维护与重新编译](#维护与重新编译)
- [错误修复日志](#错误修复日志)
- [完全卸载指南](#完全卸载指南)

---

## 功能配置

### 跟踪功能 (Tracking)
默认情况下，跟踪功能已启用。该功能用于向跟踪服务器发送统计数据（如服务器描述、主页、正常运行时间、在线用户数等）。

若需**禁用跟踪**，请修改配置文件 `conf/bnetd.conf`：
```ini
track = 0
```

### 日志级别
在获取并发布日志用于调试之前，建议在 `bnetd.conf` 文件中设置详细的日志级别：
```ini
loglevels = fatal,error,warn,info,debug,trace
```

---

## 支持的客户端

### Blizzard 游戏
> **注意**：
> 1. **魔兽争霸 3**：客户端若不进行修改（例如使用 [W3L](https://github.com/w3lh/w3l) 等工具禁用服务器签名验证），将无法连接到 War3Server。
> 2. **星际争霸**：由于协议变更，War3Server 不再支持 1.18 及之后版本的客户端。但在代码中包含了 1.18.0 版本检查条目以兼容机器人软件。

*   **魔兽争霸 2：战网版**：2.02a, 2.02b
*   **魔兽争霸 3：混乱之治**：1.13a - 1.28.5 (全系列支持)
*   **魔兽争霸 3：冰封王座**：1.13a - 1.28.5 (全系列支持)
*   **星际争霸**：1.08 - 1.18.0
*   **星际争霸：母巢之战**：1.08 - 1.18.0
*   **暗黑破坏神**：1.09, 1.09b
*   **暗黑破坏神 2**：1.10 - 1.14d
*   **暗黑破坏神 2：毁灭之王**：1.10 - 1.14d

### Westwood 游戏
*   **Westwood 聊天客户端**：4.221
*   **命令与征服 (C&C)**：Win95 1.04a
*   **C&C：红色警戒**：Win95 2.00, Win95 3.03
*   **C&C：红色警戒 2**：1.006
*   **C&C：泰伯利亚之日**：2.03 ST-10
*   **C&C：泰伯利亚之日 烈焰风暴**：2.03 ST-10
*   **C&C：尤里的复仇**：1.001
*   **C&C：叛逆者**：1.037
*   **诺克斯 (Nox) / 诺克斯任务**：1.02b
*   **沙丘 2000**：1.06
*   **帝皇：沙丘之战**：1.09

---

## 安装指南 (Ubuntu 16.04 / 18.04)

### 1. 环境准备与依赖安装
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装编译工具和依赖库
sudo apt install -y build-essential cmake git libmysqlclient-dev libssl-dev zlib1g-dev

# 安装 Lua 支持
apt-get install -y liblua5.1-0-dev

为了实现完全自动化并确保你的 Qt 程序（War3Bot）能够完美连接，我们需要针对 **Ubuntu 环境**、**Qt 驱动兼容性** 以及 **127.0.0.1 本地回环** 进行优化。

以下是为你整理好的 Markdown 文档，你可以直接替换或更新：

---

# MySQL 数据库环境自动化配置指南

### 1. 安装 MySQL 及 Qt 驱动
在 Ubuntu 上安装 MySQL 服务器以及 Qt 连接所需的驱动插件。
```bash
# 更新源并安装 MySQL 服务器、Qt MySQL 驱动及开发库
sudo apt update
sudo apt install -y mysql-server libqt5sql5-mysql libmysqlclient-dev

# 启动并启用 MySQL 服务
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 2. 自动化配置数据库与用户
为了确保 `pvpgn` 用户拥有足够的权限（包括自动创库、建表）以及兼容 Qt 的连接协议，请执行以下命令：

**方式 A：手动进入 MySQL 执行（推荐初次配置）**
```bash
# 使用系统 root 权限进入（Ubuntu 默认不需要密码）
sudo mysql
```

在 MySQL 提示符下执行以下 SQL（请直接复制全段）：
```sql
-- 1. 创建业务数据库 (使用 utf8mb4 支持中文及特殊字符)
CREATE DATABASE IF NOT EXISTS platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. 创建用户 (针对 127.0.0.1 和 localhost，确保 Qt 和终端都能连)
-- 使用 mysql_native_password 以确保旧版 Qt 驱动也能完美兼容
CREATE USER IF NOT EXISTS 'pvpgn'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
CREATE USER IF NOT EXISTS 'pvpgn'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';

-- 3. 授予权限
-- 授予全局 CREATE 权限，允许程序执行 "CREATE DATABASE IF NOT EXISTS"
GRANT CREATE ON *.* TO 'pvpgn'@'127.0.0.1';
GRANT CREATE ON *.* TO 'pvpgn'@'localhost';

-- 授予业务库 platform 的所有操作权限
GRANT ALL PRIVILEGES ON platform.* TO 'pvpgn'@'127.0.0.1';
GRANT ALL PRIVILEGES ON platform.* TO 'pvpgn'@'localhost';

-- 4. 刷新权限并退出
FLUSH PRIVILEGES;
EXIT;
```

**方式 B：一键脚本执行（适合自动化脚本）**
如果你在写 shell 脚本，可以直接运行这一行：
```bash
sudo mysql -e "CREATE DATABASE IF NOT EXISTS platform; CREATE USER IF NOT EXISTS 'pvpgn'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'yourpassword'; GRANT CREATE ON *.* TO 'pvpgn'@'127.0.0.1'; GRANT ALL PRIVILEGES ON platform.* TO 'pvpgn'@'127.0.0.1'; FLUSH PRIVILEGES;"
```

### 3. 程序连接参数建议
在你的 War3Bot 配置文件（`war3bot.ini`）或代码中，请使用以下参数：

| 参数 | 设定值 | 说明 |
| :--- | :--- | :--- |
| **驱动 (Driver)** | `QMYSQL` | Ubuntu 环境下的标准名称 |
| **主机 (Host)** | `127.0.0.1` | **必须使用 IP**，避开 .sock 文件冲突 |
| **端口 (Port)** | `3306` | 默认端口 |
| **用户 (User)** | `pvpgn` | 专用业务用户 |
| **密码 (Pass)** | `yourpassword` | 设定的安全密码 |
| **库名 (Database)** | `platform` | 业务数据库名称 |

--- 

### 3. 编译与安装 War3Server

```bash
# 克隆项目代码
git clone -v https://github.com/wuxiancong/War3Server.git
cd War3Server

# 创建构建目录
mkdir build && cd build

# 配置 CMake
cmake .. \
  -D WITH_LUA=true \
  -D WITH_MYSQL=true \
  -D MYSQL_INCLUDE_DIR=/usr/include/mysql \
  -D CMAKE_INSTALL_PREFIX=/usr/local/War3Server \
  -D MYSQL_LIBRARY=/usr/lib/x86_64-linux-gnu/libmysqlclient.so \
  -D CMAKE_BUILD_TYPE=Release

# 编译 (使用所有核心)
make -j$(nproc)

# 安装
sudo make install
```

#### ⚠️克隆失败
```bash
 #!/bin/bash
# 清理所有git进程
echo "清理git进程..."
pkill -9 git 2>/dev/null
pkill -f "git clone" 2>/dev/null

# 清理作业
echo "清理挂起的作业..."
jobs -p | xargs -r kill 2>/dev/null

# 删除可能的不完整目录
echo "检查不完整克隆..."
if [ -d "War3Server" ]; then
    echo "删除不完整的War3Server目录..."
    rm -rf War3Server
fi

echo "清理完成！现在可以重新克隆："
echo "git clone https://github.com/wuxiancong/War3Server.git"
```

```bash
# 1. 先终止所有作业
for i in {1..11}; do kill %$i 2>/dev/null; done

# 2. 强制杀死git进程
pkill -9 git

# 3. 清理目录
rm -rf War3Server

# 4. 重新克隆（使用浅克隆）
git clone --depth=1 https://github.com/wuxiancong/War3Server.git
```

### 4. 权限与目录配置
配置 `bnetd.conf` 中的数据库连接字符串（请根据实际密码修改）：
> 配置文件路径通常在 `/usr/local/War3Server/etc/bnetd.conf`
```ini
storage_path = "sql:mode=mysql;host=localhost;name=pvpgn;user=pvpgn;pass=yourpassword;default=0;prefix=pvpgn_"
```

设置运行用户和目录权限：
```bash
# 创建系统用户 pvpgn
sudo useradd -r -s /bin/false pvpgn

# 修改安装目录所有权
sudo chown -R pvpgn:pvpgn /usr/local/War3Server

# 修改 var 目录权限
sudo chown -R pvpgn:pvpgn /usr/local/War3Server/var/
sudo chmod 755 /usr/local/War3Server/var/War3Server

# 修改配置文件权限
sudo chmod 666 /usr/local/War3Server/etc/War3Server/bnban.conf

```

---

## 配置与启动

### 手动启动
```bash
# 后台模式启动
sudo /usr/local/War3Server/sbin/bnetd

# 前台模式启动 (用于调试)
sudo /usr/local/War3Server/sbin/bnetd --foreground

# 检查进程
ps aux | grep bnetd

# 停止所有进程
sudo killall bnetd

# 杀掉所有 bnetd 进程（释放端口）
sudo killall -9 bnetd

# 杀掉所有 gdb 调试进程
sudo killall -9 gdb

# 杀掉那些卡住的 tail 日志查看进程（清理干扰）
sudo killall -9 tail

```

### 数据库连接测试
```bash
mysql -u pvpgn -p -e "USE pvpgn; SHOW TABLES;"
```

### 查看实时日志
```bash
sudo tail -f /usr/local/War3Server/var/War3Server/bnetd.log
```

---

## Systemd 服务配置

创建服务文件 `/etc/systemd/system/pvpgn.service`，内容如下：
### simple
```
[Unit]
Description=PvPGN Battle.net Server
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
ExecStart=/usr/local/War3Server/sbin/bnetd -f
WorkingDirectory=/usr/local/War3Server
User=pvpgn
Group=pvpgn
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

```
### forking
```ini
[Unit]
Description=PvPGN Battle.net Server
After=network.target mysql.service
Wants=mysql.service
Requires=mysql.service

[Service]
Type=forking
ExecStart=/usr/local/War3Server/sbin/bnetd
ExecStop=/usr/local/War3Server/sbin/bnetd --stop
WorkingDirectory=/usr/local/War3Server
User=pvpgn
Group=pvpgn
RuntimeDirectory=War3Server
PIDFile=/usr/local/War3Server/var/War3Server/bnetd.pid
Restart=on-failure
RestartSec=5
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
```

**管理服务命令：**

```bash
# 停止服务
systemctl stop pvpgn

# 禁用服务
systemctl disable pvpgn

# 清理缓存
systemctl daemon-reexec

# 重新加载配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start pvpgn

# 停止服务
sudo systemctl stop pvpgn

# 查看状态
sudo systemctl status pvpgn

# 开机自启
sudo systemctl enable pvpgn
```

---

## 维护与重新编译

**清理并重新安装：**
```bash
# 停止服务
sudo systemctl stop pvpgn
sudo pkill bnetd

cd ~/War3Server/build

# 卸载旧文件
sudo make uninstall 2>/dev/null || true
sudo make clean

# 重新编译安装
cmake .. -DWITH_MYSQL=ON
make -j$(nproc)
sudo make install

# 重启服务
sudo systemctl start pvpgn
```

---

## 错误修复日志

以下是针对原始 PvPGN 代码进行的具体修复列表。

### [1] 格式化字符串严重错误 (CRITICAL)
**文件**: `src/bnetd/handle_bnet.cpp`
**描述**: 修复了 `fmt::format_to` 中的指针运算错误。原代码中 `"{}" + '\n'` 会导致指针偏移 10 个字节指向无效内存，从而抛出 "argument index out of range" 异常。

**Before:**
```cpp
fmt::format_to(serverinfo, "{}" + '\n', (line + 1));
```
**After:**
```cpp
fmt::format_to(serverinfo, "{}\n", (line + 1));
```

### [2] 随机数生成修正
**文件**: `src/bnetd/anongame_wol.cpp`
**描述**: 修正随机数范围计算。

**Before:**
```cpp
*i = (max * rand() / (RAND_MAX + 1));
```
**After:**
```cpp
*i = (max * rand() / RAND_MAX);
```

### [3] 布尔类型定义
**文件**: `src/bnetd/sql_mysql.cpp`

**Before:**
```cpp
my_bool my_true = true;
```
**After:**
```cpp
bool my_true = true;
```

### [4] 外部变量声明修正
**文件**: `src/common/eventlog.cpp`
**描述**: 移除了 `extern` 关键字以正确定义变量。

**Before:**
```cpp
extern std::FILE *eventstrm = NULL;
extern unsigned currlevel = ...;
extern int eventlog_debugmode = 0;
```
**After:**
```cpp
std::FILE *eventstrm = NULL;
unsigned currlevel = ...;
int eventlog_debugmode = 0;
```

### [5] 缓冲区溢出保护
**文件**: `src/common/proginfo.cpp`
**描述**: 增加版本字符串缓冲区大小。

**After:**
```cpp
static char verstr[32]; // 原为 16，增加至 32 或 64
```

### [6] BigInt 移位溢出修复
**文件**: `src/common/bigint.cpp`
**描述**: 修复了在 32 位系统或特定类型下，右移 64 位导致的未定义行为。

**Code Fix:**
```cpp
// 构造函数 BigInt::BigInt(std::uint64_t input) 中:
#ifdef HAVE_UINT64_T
    segment[0] = input;
#else
    for (i = 0; i < segment_count; i++){
        segment[i] = input & bigint_base_mask;
        // 修复: 增加边界检查
        if (bigint_base_bitcount >= sizeof(input) * 8) {
            input = 0;
        } else {
            input >>= bigint_base_bitcount;
        }
    }
#endif

// 构造函数 BigInt::BigInt(std::uint32_t input) 中:
// 修复: 只有当 input 不为 0 且位宽允许时才移位
if (input != 0 && bigint_base_bitcount < 32) {
    input >>= bigint_base_bitcount;
} else {
    input = 0;
}
```

### [7] 字符串格式化安全
**文件**: `src/bnetd/command.cpp`
**描述**: 使用 `snprintf` 替代 `sprintf` 并修正格式说明符。

**After:**
```cpp
std::snprintf(msgtemp0, sizeof(msgtemp0), " \"%.64s\" (%.80s = \"%.80s\")", account_get_name(account), key, value);
```

### [8] 增加缓冲区大小
**文件**: `src/bnetd/handle_apireg.cpp`

**After:**
```cpp
char data[1024];  // 原为 MAX_IRC_MESSAGE_LEN
char temp[1024];
```

### [9] 格式化精度调整
**文件**: `src/bnetd/ipban.cpp`

**After:**
```cpp
std::sprintf(timestr, "(%.47s)", seconds_to_timestr(entry->endtime - now)); // 原为 %.48s
```

### [10] SQL 注入与溢出防护
**文件**: `src/bnetd/sql_dbcreator.cpp`

**After:**
```cpp
// 增加缓冲区大小
char query[2048]; 

// 限制读取字符数
std::sscanf(column->name, "%1023s", _column);

// 使用 snprintf
std::snprintf(query, sizeof(query), "INSERT INTO %s (%s) VALUES (%s)", table->name, _column, column->value);
```

### [11] Tracker 缓冲区修正
**文件**: `src/bnetd/tracker.cpp`

**After:**
```cpp
// 1. 使用 memset 清零
std::memset(packet.platform, 0, sizeof packet.platform);

// 2. 限制复制长度
std::snprintf(reinterpret_cast<char*>(packet.platform), sizeof packet.platform, "%.31s", utsbuf.sysname);
```

---

## 完全卸载指南

**警告：以下操作将删除编译环境、数据库和相关数据文件。**

```bash
# 1. 卸载编译工具和依赖
sudo apt remove --purge build-essential cmake git libmysqlclient-dev libssl-dev zlib1g-dev
sudo apt autoremove

# 2. 卸载 Lua 支持
sudo apt remove --purge liblua5.1-0-dev

# 3. 卸载 MySQL 服务器 (谨慎操作！)
sudo apt remove --purge mysql-server

# 4. 删除 MySQL 数据文件 (危险：这将删除所有数据库！)
sudo apt purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo rm -rf /etc/mysql /var/lib/mysql
sudo deluser mysql
sudo delgroup mysql

# 5. 系统清理
sudo apt autoremove
sudo apt clean
```
