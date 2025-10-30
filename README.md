War3Server 是一款免费开源的跨平台服务器软件，基于PVPGN项目，支持 Battle.net 和 Westwood Online 游戏客户端。War3Server-PRO 是官方 War3Server 项目的一个分支，官方项目于 2011 年停止开发，War3Server-PRO 旨在为 War3Server 提供持续维护和额外功能。

默认情况下，跟踪功能已启用，仅用于向跟踪服务器发送信息数据（例如服务器描述、主页、正常运行时间、用户数量）。要禁用跟踪，请在 ````conf/bnetd.conf````中设置 ````track = 0````。

## 支持的客户端

- **魔兽争霸2：战网版**：2.02a、2.02b

- **魔兽争霸3：混乱之治**：1.13a、1.13b、1.14a、1.14b、1.15a、1.16a、1.17a、1.18a、1.19a、1.19b、1.20a、1.20b、1.20c、1.20d、1.20e、1.21a、1.21b、1.22a、1.23a、1.24a、1.24b、1.24c、1.24d、1.24e、1.25b、1.26a 1.27a、1.27b、1.28、1.28.1、1.28.2、1.28.4、1.28.5

- **魔兽争霸3：冰封王座**\*：1.13a、1.13b、1.14a、1.14b、1.15a、1.16a、1.17a、1.18a、1.19a、1.19b、1.20a、1.20b、1.20c、1.20d、1.20e、1.21a、1.21b、1.22a、1.23a、1.24a、1.24b、1.24c、1.24d、1.24e 1.25b、1.26a、1.27a、1.27b、1.28、1.28.1、1.28.2、1.28.4、1.28.5

- **星际争霸**：1.08、1.08b、1.09、1.09b、1.10、1.11、1.11b、1.12、1.12b、1.13、1.13b、1.13c、1.13d、1.13e、1.13f、1.14、1.15、1.15.1、1.15.2、1.15.3、1.16、1.16.1、1.17.0、1.18.0

- **星际争霸：母巢之战**：1.08、1.08b、1.09、1.09b、1.10、1.11、1.11b、1.12、1.12b、1.13、1.13b、1.13c、1.13d、1.13e、1.13f、1.14、1.15、1.15.1、1.15.2、1.15.3、1.16、1.16.1、1.17.0、1.18.0

- **暗黑破坏神**：1.09、1.09b

- **暗黑破坏神2**：1.10、1.11、1.11b、1.12a、1.13c 1.14a、1.14b、1.14c、1.14d

- **暗黑破坏神2：毁灭之王**：1.10、1.11、1.11b、1.12a、1.13c、1.14a、1.14b、1.14c、1.14d

- **Westwood聊天客户端**：4.221

- **命令与征服**：Win95 1.04a（使用Westwood聊天客户端）

- **命令与征服：红色警戒**：Win95 2.00（使用Westwood聊天客户端）、Win95 3.03

- **命令与征服：红色警戒2**：1.006

- **命令与征服：泰伯利亚之日**：2.03 ST-10

- **命令与征服**征服：泰伯利亚之日 烈焰风暴**：2.03 ST-10

- **命令与征服：尤里的复仇**：1.001

- **命令与征服：叛逆者**：1.037

- **诺克斯**：1.02b

- **诺克斯任务**：1.02b

- **沙丘2000**：1.06

- **帝皇：沙丘之战**：1.09

* 魔兽争霸3客户端若不通过客户端修改（例如使用[W3L](https://github.com/w3lh/w3l)等工具禁用服务器签名验证）则无法连接到War3Server服务器。

* 由于协议变更，War3Server-PRO将不再支持1.18版本及之后的星际争霸客户端。为了与机器人软件兼容，包含了 1.18.0 版本检查条目。

在获取并发布日志之前，请在 `bnetd.conf` 文件中设置 `loglevels = fatal,error,warn,info,debug,trace`。


# 安装
## Ubuntu 16.04, 18.04
```
sudo apt-get -y install build-essential git cmake zlib1g-dev
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server && cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

# 错误修复

## 我在原来的pvpgn上修复了一些错误如下：

### [1] - ⚠ 最严重的错误
https://github.com/pvpgn/pvpgn-server/blob/master/src/bnetd/handle_bnet.cpp#L2935

为什么这是问题的根源？
1. "{}" + '\n' 是指针运算，不是字符串拼接
2. 在C++中，"string" + char 会将char的ASCII值加到字符串指针上
3. '\n' 的ASCII值是10，所以 "{}" + 10 会指向无效的内存地址
4. 当 fmt::format_to 尝试使用这个无效的格式字符串时，会抛出异常

这个修复应该能解决 "argument index out of range" 错误，因为：
1. 原来的代码使用了无效的格式字符串指针
2. 修复后的代码使用有效的格式字符串 "{}\n"
3. 这发生在处理Warcraft III MOTD时，与客户端连接时机匹配

修复前（错误）：
```bash
fmt::format_to(serverinfo, "{}" + '\n', (line + 1));
```
修复后（正确）：
```bash
fmt::format_to(serverinfo, "{}\n", (line + 1));
```
### [2]
/root/pvpgn-server/src/bnetd/anongame_wol.cpp
将：
```bash
*i = (max * rand() / (RAND_MAX + 1)); 改为 *i = (max * rand() / RAND_MAX);
*j = (max * rand() / (RAND_MAX + 1)); 改为 *j = (max * rand() / RAND_MAX);
*j = (max * rand() / (RAND_MAX + 1)); 改为 *j = (max * rand() / RAND_MAX);
```
### [3]
 /root/pvpgn-server/src/bnetd/sql_mysql.cpp
将：
```bash
my_bool  my_true = true;
```
修改为：
```bash
bool  my_true = true;
```
### [4]
 /root/pvpgn-server/src/common/eventlog.cpp
```bash
extern std::FILE *eventstrm = NULL;

extern unsigned currlevel = eventlog_level_debug | eventlog_level_info | eventlog_level_warn | eventlog_level_error | eventlog_level_fatal

extern int eventlog_debugmode = 0;
```
改为：
```bash
std::FILE *eventstrm = NULL;
unsigned currlevel = eventlog_level_debug | eventlog_level_info | eventlog_level_warn | eventlog_level_error | eventlog_level_fatal
int eventlog_debugmode = 0;
```
### [5]
/root/pvpgn-server/src/common/proginfo.cpp

搜索 vernum_to_verstr 函数：
将缓冲区大小从 16 增加到足够的大小
// 将原来的 16 改为更大的值，比如 32
```bash
static char verstr[32]; // 或者 64 更安全
```
### [6]
/root/pvpgn-server/src/common/bigint.cpp

搜索 BigInt::BigInt(std::uint32_t input) 构造函数
问题分析
```bash
bigint_base_bitcount = sizeof(bigint_base) * 8
```
如果 bigint_base 是 64 位类型，那么 bigint_base_bitcount = 64

input 是 uint32_t (32位)

input >>= 64 试图右移64位，超过了32位类型的宽度

#修复方法：添加边界检查
```bash
BigInt::BigInt(std::uint64_t input)
{
#ifndef HAVE_UINT64_T
    int i;
#endif
    segment_count = sizeof(std::uint32_t) / sizeof(bigint_base);
    segment = (bigint_base*)xmalloc(segment_count * sizeof(bigint_base));
#ifdef HAVE_UINT64_T
    segment[0] = input;
#else
    for (i = 0; i < segment_count; i++){
        segment[i] = input & bigint_base_mask;
        // 修复移位计数溢出
        if (bigint_base_bitcount >= sizeof(input) * 8) {
            input = 0;
        } else {
            input >>= bigint_base_bitcount;
        }
    }
#endif
}

BigInt::BigInt(std::uint32_t input)
{
    int i;
    segment_count = sizeof(std::uint32_t) / sizeof(bigint_base);
    segment = (bigint_base*)xmalloc(segment_count * sizeof(bigint_base));
    
    for (i = 0; i < segment_count; i++){
        segment[i] = input & bigint_base_mask;
        // 只有当还有数据需要处理时才移位
        if (input != 0 && bigint_base_bitcount < 32) {
            input >>= bigint_base_bitcount;
        } else {
            input = 0;
        }
    }
}
```
### [7]
/root/pvpgn-server/src/bnetd/command.cpp
第 4696 行
```bash
std::sprintf(msgtemp0, " \"%.64s\" (%.128s = \"%.128s\")", account_get_name(account), key, value);
```
改为
```bash
std::snprintf(msgtemp0, sizeof(msgtemp0), " \"%.64s\" (%.80s = \"%.80s\")",  account_get_name(account), key, value);
```
### [8]
/root/pvpgn-server/src/bnetd/handle_apireg.cpp
```bash
// 原来的代码：
char data[MAX_IRC_MESSAGE_LEN];
char temp[MAX_IRC_MESSAGE_LEN];

// 修复后的代码：
char data[1024];  // 增加到1024字节
char temp[1024];  // 增加到1024字节
```
### [9]
/root/pvpgn-server/src/bnetd/ipban.cpp

第 697 行
```bash
std::sprintf(timestr, "(%.48s)", seconds_to_timestr(entry->endtime - now));
```
改为
```bash
std::sprintf(timestr, "(%.47s)", seconds_to_timestr(entry->endtime - now));
```
### [10]
/root/pvpgn-server/src/bnetd/sql_dbcreator.cpp
第 641 行
```bash
char           query[1024];
char           query[2048];
```
第 724 行
```bash
std::sscanf(column->name, "%s", _column); //get column name without format infos
std::sprintf(query, "INSERT INTO %s (%s) VALUES (%s)", table->name, _column, column->value);
```
改为
```bash
// 限制读取的字符数量
std::sscanf(column->name, "%1023s", _column);
// 使用安全的 snprintf
std::snprintf(query, sizeof(query), "INSERT INTO %s (%s) VALUES (%s)", table->name, _column, column->value);
```
### [11]
/root/pvpgn-server/src/bnetd/tracker.cpp

第 122 行
```bash
std::snprintf(reinterpret_cast<char*>(packet.platform), sizeof packet.platform, "");
```
改为
```bash
// 直接设置空字符串，不需要使用 snprintf
std::memset(packet.platform, 0, sizeof packet.platform);
```
第 127 行
```bash
std::snprintf(reinterpret_cast<char*>(packet.platform), sizeof packet.platform, "%s", utsbuf.sysname);
```
改为
```bash
// 修复2：确保不会溢出，即使截断也是安全的
std::snprintf(reinterpret_cast<char*>(packet.platform), sizeof packet.platform, "%.31s", utsbuf.sysname);
```
