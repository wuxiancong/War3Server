# ============================================================================
# 颜色定义（如果之前没有定义过）
# ============================================================================
if(NOT DEFINED Color_Reset)
    # 检查是否支持颜色输出（非Windows或启用颜色的Windows）
    if(NOT WIN32 OR CMAKE_COLOR_MAKEFILE)
	string(ASCII 27 Esc)
	# 基础颜色
	set(Color_Reset   "${Esc}[0m")
	set(Color_Bold    "${Esc}[1m")

	# 主要颜色
	set(Color_Gray    "${Esc}[90m")      # 灰色 - 表示检查中
	set(Color_Red     "${Esc}[31m")      # 红色 - 表示失败/未找到
	set(Color_Green   "${Esc}[32m")      # 绿色 - 表示成功/找到
	set(Color_Yellow  "${Esc}[33m")      # 黄色 - 表示警告/跳过
	set(Color_Blue    "${Esc}[34m")      # 蓝色 - 表示分组/标题
	set(Color_Magenta "${Esc}[35m")      # 洋红色 - 表示重要信息
	set(Color_Cyan    "${Esc}[36m")      # 青色 - 表示详细信息

	# 亮色
	set(Color_LRed    "${Esc}[91m")
	set(Color_LGreen  "${Esc}[92m")
	set(Color_LYellow "${Esc}[93m")
	set(Color_LBlue   "${Esc}[94m")
	set(Color_LMagenta "${Esc}[95m")
	set(Color_LCyan   "${Esc}[96m")
    else()
	# 不支持颜色时使用空字符串
	set(Color_Reset   "")
	set(Color_Bold    "")
	set(Color_Gray    "")
	set(Color_Red     "")
	set(Color_Green   "")
	set(Color_Yellow  "")
	set(Color_Blue    "")
	set(Color_Magenta "")
	set(Color_Cyan    "")
	set(Color_LRed    "")
	set(Color_LGreen  "")
	set(Color_LYellow "")
	set(Color_LBlue   "")
	set(Color_LMagenta "")
	set(Color_LCyan   "")
    endif()
endif()

# ============================================================================
# 增强版检查函数（包装原有检查函数，添加颜色输出）
# ============================================================================

# 增强版库检查函数 - 修正参数传递
function(enhanced_check_library_exists)
    # 解析参数
    if(ARGC LESS 4)
	message(FATAL_ERROR "enhanced_check_library_exists 需要4个参数: LIBRARY FUNCTION LOCATION VARIABLE")
    endif()

    set(LIBRARY ${ARGV0})
    set(FUNCTION ${ARGV1})
    set(LOCATION ${ARGV2})
    set(VARIABLE ${ARGV3})

    message(STATUS "${Color_Gray}[检查]${Color_Reset} 库: ${LIBRARY} (函数: ${FUNCTION})")

    # 调用原始的检查函数 - 使用正确的参数格式
    check_library_exists("${LIBRARY}" "${FUNCTION}" "${LOCATION}" "${VARIABLE}")

    # 根据结果输出彩色信息
    if(${${VARIABLE}})
	message(STATUS "${Color_Green}[找到]${Color_Reset} 库 ${LIBRARY}")
    else()
	message(STATUS "${Color_Red}[未找到]${Color_Reset} 库 ${LIBRARY}")
    endif()
endfunction()

# 增强版头文件检查函数 - 修正参数传递
function(enhanced_check_include_file_cxx)
    # 解析参数
    if(ARGC LESS 2)
	message(FATAL_ERROR "enhanced_check_include_file_cxx 需要2个参数: HEADER VARIABLE")
    endif()

    set(HEADER ${ARGV0})
    set(VARIABLE ${ARGV1})

    message(STATUS "${Color_Gray}[检查]${Color_Reset} 头文件: ${HEADER}")

    # 调用原始的检查函数
    check_include_file_cxx("${HEADER}" "${VARIABLE}")

    # 根据结果输出彩色信息
    if(${${VARIABLE}})
	message(STATUS "${Color_Green}[找到]${Color_Reset} ${HEADER}")
    else()
	message(STATUS "${Color_Red}[未找到]${Color_Reset} ${HEADER}")
    endif()
endfunction()

# 增强版函数检查函数 - 修正参数传递
function(enhanced_check_function_exists)
    # 解析参数
    if(ARGC LESS 2)
	message(FATAL_ERROR "enhanced_check_function_exists 需要2个参数: FUNCTION VARIABLE")
    endif()

    set(FUNCTION ${ARGV0})
    set(VARIABLE ${ARGV1})

    message(STATUS "${Color_Gray}[检查]${Color_Reset} 函数: ${FUNCTION}()")

    # 调用原始的检查函数
    check_function_exists("${FUNCTION}" "${VARIABLE}")

    # 根据结果输出彩色信息
    if(${${VARIABLE}})
	message(STATUS "${Color_Green}[找到]${Color_Reset} ${FUNCTION}()")
    else()
	message(STATUS "${Color_Red}[未找到]${Color_Reset} ${FUNCTION}()")
    endif()
endfunction()

# ============================================================================
# 原始代码部分（添加颜色）
# ============================================================================

message(STATUS "${Color_Magenta}[=== 初始化配置阶段 ===]${Color_Reset}")

# 设置 CMake 模块路径
message(STATUS "${Color_Gray}[配置]${Color_Reset} 设置 CMake 模块路径")
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules)

# 包含使用的模块
message(STATUS "${Color_Gray}[配置]${Color_Reset} 包含配置模块...")
include(DefineInstallationPaths)
include(CheckIncludeFileCXX)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckLibraryExists)
include(CheckCXXCompilerFlag)
include(CheckMkdirArgs)
include(CheckIncludeFiles)

# 设置简短的变量路径名称
message(STATUS "${Color_Gray}[配置]${Color_Reset} 设置路径变量别名")
set(BINDIR ${BIN_INSTALL_DIR})
set(SBINDIR ${SBIN_INSTALL_DIR})
set(SYSCONFDIR ${SYSCONF_INSTALL_DIR})
set(LOCALSTATEDIR ${LOCALSTATE_INSTALL_DIR})
set(MANDIR ${MAN_INSTALL_DIR})

# 设置默认的硬编码配置文件路径
if(WIN32)
    message(STATUS "${Color_Gray}[配置]${Color_Reset} Windows平台配置文件路径")
        set(BNETD_DEFAULT_CONF_FILE "conf/bnetd.conf")
	set(D2CS_DEFAULT_CONF_FILE "conf/d2cs.conf")
	set(D2DBS_DEFAULT_CONF_FILE "conf/d2dbs.conf")
else(WIN32)
    message(STATUS "${Color_Gray}[配置]${Color_Reset} Unix平台配置文件路径")
        set(BNETD_DEFAULT_CONF_FILE "${SYSCONFDIR}/bnetd.conf")
	set(D2CS_DEFAULT_CONF_FILE "${SYSCONFDIR}/d2cs.conf")
	set(D2DBS_DEFAULT_CONF_FILE "${SYSCONFDIR}/d2dbs.conf")
endif(WIN32)

message(STATUS "${Color_Magenta}[=== 库依赖检查阶段 ===]${Color_Reset}")

# 库检查
if(WITH_BNETD)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 ZLIB 库...")
        find_package(ZLIB REQUIRED)
    if(ZLIB_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} ZLIB 版本: ${ZLIB_VERSION_STRING}")
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 ZLIB 库")
    endif()
endif(WITH_BNETD)

if(WITH_LUA)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 Lua 库...")
    find_package(Lua REQUIRED)
    if(Lua_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} Lua 库")
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 Lua 库")
    endif()
endif(WITH_LUA)

# 存储模块检查
if(WITH_ODBC)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 ODBC 库...")
    find_package(ODBC REQUIRED)
    if(ODBC_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} ODBC 库")
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 ODBC 库")
    endif()
endif(WITH_ODBC)

if(WITH_MYSQL)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 MySQL 库...")

    # 先尝试自动查找
    find_package(MySQL)

    # 如果没有自动找到，尝试手动指定
    if(NOT MySQL_FOUND)
	message(STATUS "${Color_Yellow}[警告]${Color_Reset} find_package 未找到 MySQL，尝试手动查找...")

	# 尝试常见路径
	set(MYSQL_POSSIBLE_PATHS
	    "/usr/include/mysql"
	    "/usr/local/include/mysql"
	    "/usr/include/mariadb"
	    "/usr/local/mysql/include"
	    "/opt/homebrew/include/mysql"
	    "$ENV{MYSQL_DIR}/include"
	)

        set(MYSQL_LIB_POSSIBLE_PATHS
	    "/usr/lib/x86_64-linux-gnu"
	    "/usr/lib64"
	    "/usr/lib"
	    "/usr/local/mysql/lib"
	    "/opt/homebrew/lib"
	    "$ENV{MYSQL_DIR}/lib"
	)

        # 查找头文件
	find_path(MYSQL_INCLUDE_DIR mysql.h
	    PATHS ${MYSQL_POSSIBLE_PATHS}
	    NO_DEFAULT_PATH
	)

        # 查找库文件
	find_library(MYSQL_LIBRARY NAMES mysqlclient mysqlclient_r
	    PATHS ${MYSQL_LIB_POSSIBLE_PATHS}
	    NO_DEFAULT_PATH
	)

        # 查找额外的库
	find_library(MYSQL_EXTRA_LIBRARY NAMES m z)

	if(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)
	    set(MySQL_FOUND TRUE)
	    set(MySQL_INCLUDE_DIRS ${MYSQL_INCLUDE_DIR})
	    set(MySQL_LIBRARIES ${MYSQL_LIBRARY})
	    if(MYSQL_EXTRA_LIBRARY)
		list(APPEND MySQL_LIBRARIES ${MYSQL_EXTRA_LIBRARY})
	    endif()

	    message(STATUS "${Color_Green}[手动找到]${Color_Reset} MySQL 库")
	    message(STATUS "${Color_Cyan}[头文件]${Color_Reset} ${MYSQL_INCLUDE_DIR}")
	    message(STATUS "${Color_Cyan}[库文件]${Color_Reset} ${MYSQL_LIBRARY}")
	endif()
    endif()

    if(MySQL_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} MySQL 库")

	# 验证 MySQL 库是否可用
	include(CheckLibraryExists)
	set(CMAKE_REQUIRED_LIBRARIES ${MySQL_LIBRARIES})
	set(CMAKE_REQUIRED_INCLUDES ${MySQL_INCLUDE_DIRS})

	check_library_exists(mysqlclient mysql_init "" HAVE_MYSQL_INIT)
	if(NOT HAVE_MYSQL_INIT)
	    message(STATUS "${Color_Red}[验证失败]${Color_Reset} MySQL 库无法使用 mysql_init 函数")

	    # 尝试其他可能的函数名
	    check_library_exists(mysqlclient mysql_library_init "" HAVE_MYSQL_LIBRARY_INIT)
	    if(HAVE_MYSQL_LIBRARY_INIT)
		message(STATUS "${Color_Green}[验证通过]${Color_Reset} 使用 mysql_library_init")
		set(HAVE_MYSQL_INIT TRUE)
	    endif()
	else()
	    message(STATUS "${Color_Green}[验证通过]${Color_Reset} MySQL 库可用")
	endif()

	if(HAVE_MYSQL_INIT)
	    # 检查版本
	    try_run(MYSQL_TEST_RUN_RESULT MYSQL_TEST_COMPILE_RESULT
		${CMAKE_BINARY_DIR}
		${CMAKE_SOURCE_DIR}/cmake/test_mysql_version.cpp
		CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${MySQL_INCLUDE_DIRS}"
		LINK_LIBRARIES ${MySQL_LIBRARIES}
		COMPILE_OUTPUT_VARIABLE COMPILE_OUTPUT
		RUN_OUTPUT_VARIABLE RUN_OUTPUT
	    )

	    if(MYSQL_TEST_COMPILE_RESULT AND MYSQL_TEST_RUN_RESULT EQUAL 0)
		message(STATUS "${Color_Green}[版本]${Color_Reset} ${RUN_OUTPUT}")
	    endif()
	endif()
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 MySQL 库")
    endif()
endif(WITH_MYSQL)

if(WITH_SQLITE3)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 SQLite3 库...")
    find_package(SQLite3 REQUIRED)
    if(SQLite3_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} SQLite3 版本: ${SQLite3_VERSION}")
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 SQLite3 库")
    endif()
endif(WITH_SQLITE3)

if(WITH_PGSQL)
    message(STATUS "${Color_Gray}[检查]${Color_Reset} 查找 PostgreSQL 库...")
    find_package(PostgreSQL REQUIRED)
    if(PostgreSQL_FOUND)
	message(STATUS "${Color_Green}[找到]${Color_Reset} PostgreSQL 版本: ${PostgreSQL_VERSION_STRING}")
    else()
	message(FATAL_ERROR "${Color_Red}[错误]${Color_Reset} 未找到 PostgreSQL 库")
    endif()
endif(WITH_PGSQL)

message(STATUS "${Color_Magenta}[=== 网络库检查 ===]${Color_Reset}")

# 检查网络相关库（使用增强版函数）- 注意空字符串需要用引号
enhanced_check_library_exists(nsl gethostbyname "" HAVE_LIBNSL)
enhanced_check_library_exists(socket socket "" HAVE_LIBSOCKET)
enhanced_check_library_exists(resolv inet_aton "" HAVE_LIBRESOLV)
enhanced_check_library_exists(bind __inet_aton "" HAVE_LIBBIND)

# 将找到的网络库添加到所需的库列表中
message(STATUS "${Color_Gray}[配置]${Color_Reset} 配置网络库链接...")
if(HAVE_LIBNSL)
        SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} nsl)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} nsl)
    message(STATUS "${Color_Cyan}[添加]${Color_Reset} nsl 到网络库列表")
endif(HAVE_LIBNSL)

if(HAVE_LIBSOCKET)
        SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} socket)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} socket)
    message(STATUS "${Color_Cyan}[添加]${Color_Reset} socket 到网络库列表")
endif(HAVE_LIBSOCKET)

if(HAVE_LIBRESOLV)
        SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} resolv)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} resolv)
    message(STATUS "${Color_Cyan}[添加]${Color_Reset} resolv 到网络库列表")
endif(HAVE_LIBRESOLV)

if(HAVE_LIBBIND)
        # 该库用于 BeOS BONE 系统，如果有人想在 BeOS 上
	# 使用 CMake 测试 War3Server，请联系我们
	SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} bind)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} bind)
    message(STATUS "${Color_Cyan}[添加]${Color_Reset} bind 到网络库列表 (BeOS BONE专用)")
endif(HAVE_LIBBIND)

# 对于 Win32 平台，无条件添加网络库链接 "ws2_32"
if(WIN32)
        SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} ws2_32)
    message(STATUS "${Color_Cyan}[添加]${Color_Reset} ws2_32 到网络库列表 (Windows平台)")
endif(WIN32)

message(STATUS "${Color_Magenta}[=== 系统头文件检查 ===]${Color_Reset}")

# 检查 POSIX 头文件
message(STATUS "${Color_Blue}[POSIX 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(arpa/inet.h HAVE_ARPA_INET_H)
enhanced_check_include_file_cxx(dirent.h HAVE_DIRENT_H)
enhanced_check_include_file_cxx(grp.h HAVE_GRP_H)
enhanced_check_include_file_cxx(fcntl.h HAVE_FCNTL_H)
enhanced_check_include_file_cxx(netdb.h HAVE_NETDB_H)
enhanced_check_include_file_cxx(netinet/in.h HAVE_NETINET_IN_H)
enhanced_check_include_file_cxx(poll.h HAVE_POLL_H)
enhanced_check_include_file_cxx(pwd.h HAVE_PWD_H)
enhanced_check_include_file_cxx(sys/mman.h HAVE_SYS_MMAN_H)
enhanced_check_include_file_cxx(sys/resource.h HAVE_SYS_RESOURCE_H)
enhanced_check_include_file_cxx(sys/select.h HAVE_SYS_SELECT_H)
enhanced_check_include_file_cxx(sys/socket.h HAVE_SYS_SOCKET_H)
enhanced_check_include_file_cxx(sys/stat.h HAVE_SYS_STAT_H)
enhanced_check_include_file_cxx(sys/time.h HAVE_SYS_TIME_H)
enhanced_check_include_file_cxx(sys/types.h HAVE_SYS_TYPES_H)
enhanced_check_include_file_cxx(sys/utsname.h HAVE_SYS_UTSNAME_H)
enhanced_check_include_file_cxx(sys/wait.h HAVE_SYS_WAIT_H)
enhanced_check_include_file_cxx(termios.h HAVE_TERMIOS_H)
enhanced_check_include_file_cxx(unistd.h HAVE_UNISTD_H)

message(STATUS "${Color_Blue}[可选 POSIX/SUS 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(sys/timeb.h HAVE_SYS_TIMEB_H)

message(STATUS "${Color_Blue}[FreeBSD 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(sys/event.h HAVE_SYS_EVENT_H)
enhanced_check_include_file_cxx(sys/param.h HAVE_SYS_PARAM_H)

message(STATUS "${Color_Blue}[BSD 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(sys/file.h HAVE_SYS_FILE_H)

message(STATUS "${Color_Blue}[Linux 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(sys/epoll.h HAVE_SYS_EPOLL_H)

message(STATUS "${Color_Blue}[Win32 头文件]${Color_Reset}")
enhanced_check_include_file_cxx(windows.h HAVE_WINDOWS_H)
enhanced_check_include_file_cxx(winsock2.h HAVE_WINSOCK2_H)
enhanced_check_include_file_cxx(ws2tcpip.h HAVE_WS2TCPIP_H)
enhanced_check_include_file_cxx(process.h HAVE_PROCESS_H)

message(STATUS "${Color_Blue}[其他头文件]${Color_Reset}")
enhanced_check_include_file_cxx(dir.h HAVE_DIR_H)
enhanced_check_include_file_cxx(direct.h HAVE_DIRECT_H)
enhanced_check_include_file_cxx(ndir.h HAVE_NDIR_H)
enhanced_check_include_file_cxx(sys/dir.h HAVE_SYS_DIR_H)
enhanced_check_include_file_cxx(sys/ndir.h HAVE_SYS_NDIR_H)
enhanced_check_include_file_cxx(sys/poll.h HAVE_SYS_POLL_H)

message(STATUS "${Color_Magenta}[=== 系统函数检查 ===]${Color_Reset}")

# 检查函数存在性（使用增强版函数）
enhanced_check_function_exists(chdir HAVE_CHDIR)
enhanced_check_function_exists(epoll_create HAVE_EPOLL_CREATE)
enhanced_check_function_exists(fork HAVE_FORK)
enhanced_check_function_exists(ftime HAVE_FTIME)
enhanced_check_function_exists(getgid HAVE_GETGID)
enhanced_check_function_exists(getgrnam HAVE_GETGRNAM)
enhanced_check_function_exists(getlogin HAVE_GETLOGIN)
enhanced_check_function_exists(getopt HAVE_GETOPT)
enhanced_check_function_exists(getpid HAVE_GETPID)
enhanced_check_function_exists(getpwnam HAVE_GETPWNAME)
enhanced_check_function_exists(getrlimit HAVE_GETRLIMIT)
enhanced_check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
enhanced_check_function_exists(getuid HAVE_GETUID)
enhanced_check_function_exists(ioctl HAVE_IOCTL)
enhanced_check_function_exists(kqueue HAVE_KQUEUE)
enhanced_check_function_exists(_mkdir HAVE__MKDIR)
enhanced_check_function_exists(mkdir HAVE_MKDIR)
enhanced_check_function_exists(mmap HAVE_MMAP)
enhanced_check_function_exists(pipe HAVE_PIPE)
enhanced_check_function_exists(poll HAVE_POLL)
enhanced_check_function_exists(setitimer HAVE_SETITIMER)
enhanced_check_function_exists(setpgid HAVE_SETPGID)
enhanced_check_function_exists(setpgrp HAVE_SETPGRP)
enhanced_check_function_exists(setsid HAVE_SETSID)
enhanced_check_function_exists(setuid HAVE_SETUID)
enhanced_check_function_exists(sigaction HAVE_SIGACTION)
enhanced_check_function_exists(sigaddset HAVE_SIGADDSET)
enhanced_check_function_exists(sigprocmask HAVE_SIGPROCMASK)
enhanced_check_function_exists(strcasecmp HAVE_STRCASECMP)
enhanced_check_function_exists(strdup HAVE_STRDUP)
enhanced_check_function_exists(stricmp HAVE_STRICMP)
enhanced_check_function_exists(strncasecmp HAVE_STRNCASECMP)
enhanced_check_function_exists(strnicmp HAVE_STRNICMP)
enhanced_check_function_exists(strsep HAVE_STRSEP)
enhanced_check_function_exists(uname HAVE_UNAME)
enhanced_check_function_exists(wait HAVE_WAIT)
enhanced_check_function_exists(waitpid HAVE_WAITPID)

message(STATUS "${Color_Magenta}[=== 网络函数检查 ===]${Color_Reset}")

# 网络相关函数检查（Win32 平台特殊处理）
if(HAVE_WINSOCK2_H)
        # 如果包含 WinSock2 头文件，则假定这些网络函数存在
    message(STATUS "${Color_Green}[自动设置]${Color_Reset} Win32 网络函数 (WinSock2)")
        set(HAVE_GETHOSTNAME ON)
	set(HAVE_SELECT ON)
	set(HAVE_SOCKET ON)
	set(HAVE_RECV ON)
	set(HAVE_SEND ON)
	set(HAVE_RECVFROM ON)
	set(HAVE_SENDTO ON)
	set(HAVE_GETHOSTBYNAME ON)
	set(HAVE_GETSERVBYNAME ON)
else(HAVE_WINSOCK2_H)
        # 其他平台检查这些网络函数
	enhanced_check_function_exists(gethostname HAVE_GETHOSTNAME)
	enhanced_check_function_exists(select HAVE_SELECT)
	enhanced_check_function_exists(socket HAVE_SOCKET)
	enhanced_check_function_exists(recv HAVE_RECV)
	enhanced_check_function_exists(send HAVE_SEND)
	enhanced_check_function_exists(recvfrom HAVE_RECVFROM)
	enhanced_check_function_exists(sendto HAVE_SENDTO)
	enhanced_check_function_exists(gethostbyname HAVE_GETHOSTBYNAME)
	enhanced_check_function_exists(getservbyname HAVE_GETSERVBYNAME)
endif(HAVE_WINSOCK2_H)

message(STATUS "${Color_Magenta}[=== 特殊函数检查 ===]${Color_Reset}")

# 检查 mkdir 函数的参数数量
# 这里保持原始的调用方式，或者使用简单的方式
message(STATUS "${Color_Gray}[检查]${Color_Reset} mkdir 函数参数数量")
check_mkdir_args(MKDIR_TAKES_ONE_ARG)
if(MKDIR_TAKES_ONE_ARG)
    message(STATUS "${Color_Green}[找到]${Color_Reset} mkdir 只需要1个参数")
else()
    message(STATUS "${Color_Red}[未找到]${Color_Reset} mkdir 需要多个参数")
endif()

message(STATUS "${Color_Magenta}[=== 生成配置文件 ===]${Color_Reset}")

# 生成配置头文件
message(STATUS "${Color_Gray}[生成]${Color_Reset} 配置头文件 config.h")
configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

message(STATUS "${Color_Green}[完成]${Color_Reset} 系统检查和配置完成")
