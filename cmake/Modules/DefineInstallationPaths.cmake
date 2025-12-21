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
        set(Color_Gray    "${Esc}[90m")      # 灰色 - 表示配置/设置
        set(Color_Red     "${Esc}[31m")      # 红色 - 表示错误/警告
        set(Color_Green   "${Esc}[32m")      # 绿色 - 表示成功/找到
        set(Color_Yellow  "${Esc}[33m")      # 黄色 - 表示信息/提示
        set(Color_Blue    "${Esc}[34m")      # 蓝色 - 表示路径/目录
        set(Color_Magenta "${Esc}[35m")      # 洋红色 - 表示重要信息
        set(Color_Cyan    "${Esc}[36m")      # 青色 - 表示变量/参数

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
# 安装路径配置（带颜色输出）
# ============================================================================

message(STATUS "${Color_Magenta}[=== 安装路径配置 ===]${Color_Reset}")

# 如果没有设置 APPLICATION_NAME，则使用 PROJECT_NAME 作为 APPLICATION_NAME
IF (NOT APPLICATION_NAME)
   MESSAGE(STATUS "${Color_Gray}[设置]${Color_Reset} 将 ${Color_Cyan}${PROJECT_NAME}${Color_Reset} 用作 APPLICATION_NAME")
   SET(APPLICATION_NAME ${PROJECT_NAME})
   MESSAGE(STATUS "${Color_Green}[确定]${Color_Reset} APPLICATION_NAME = ${Color_Cyan}${APPLICATION_NAME}${Color_Reset}")
ELSE()
   MESSAGE(STATUS "${Color_Green}[已有]${Color_Reset} APPLICATION_NAME = ${Color_Cyan}${APPLICATION_NAME}${Color_Reset}")
ENDIF (NOT APPLICATION_NAME)

message(STATUS "${Color_Yellow}[说明]${Color_Reset} 以下路径基于 CMAKE_INSTALL_PREFIX = ${Color_Blue}${CMAKE_INSTALL_PREFIX}${Color_Reset}")

# 设置可执行文件和库的安装基础目录
MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} 设置可执行文件和库的安装基础目录")
SET(EXEC_INSTALL_PREFIX
  "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH  "可执行文件和库的基础安装目录"
  FORCE
)
MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} EXEC_INSTALL_PREFIX = ${Color_Blue}${EXEC_INSTALL_PREFIX}${Color_Reset}")

# 设置共享文件的安装基础目录
MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} 设置共享文件的安装基础目录")
SET(SHARE_INSTALL_PREFIX
  "${CMAKE_INSTALL_PREFIX}/share"
  CACHE PATH "共享文件的安装基础目录（安装到 share/ 目录下）"
  FORCE
)
MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} SHARE_INSTALL_PREFIX = ${Color_Blue}${SHARE_INSTALL_PREFIX}${Color_Reset}")

# 设置应用程序数据的父目录
MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} 设置应用程序数据的父目录")
SET(DATA_INSTALL_PREFIX
  "${SHARE_INSTALL_PREFIX}/${APPLICATION_NAME}"
  CACHE PATH "应用程序数据文件的父安装目录"
  FORCE
)
MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} DATA_INSTALL_PREFIX = ${Color_Blue}${DATA_INSTALL_PREFIX}${Color_Reset}")

# 设置二进制文件的安装目录
MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} 设置二进制文件的安装目录")
SET(BIN_INSTALL_DIR
  "${EXEC_INSTALL_PREFIX}/bin"
  CACHE PATH "${APPLICATION_NAME} 二进制文件的安装目录（默认：prefix/bin）"
  FORCE
)
MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} BIN_INSTALL_DIR = ${Color_Blue}${BIN_INSTALL_DIR}${Color_Reset}")

#***********************************#
MESSAGE(STATUS "${Color_Magenta}[--- 平台相关路径配置 ---]${Color_Reset}")

# 设置本地状态文件的安装目录（平台相关）
if(WIN32)
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Windows平台: 本地状态文件安装目录")
  SET(LOCALSTATE_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/var"
    CACHE PATH "${APPLICATION_NAME} 本地状态文件的安装目录（默认：prefix/var）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} LOCALSTATE_INSTALL_DIR = ${Color_Blue}${LOCALSTATE_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Windows)${Color_Reset}")
else()
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Unix平台: 本地状态文件安装目录")
  SET(LOCALSTATE_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/var/${APPLICATION_NAME}"
    CACHE PATH "${APPLICATION_NAME} 本地状态文件的安装目录（默认：prefix/var）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} LOCALSTATE_INSTALL_DIR = ${Color_Blue}${LOCALSTATE_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Unix)${Color_Reset}")
endif()

# 设置手册页的安装目录
MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} 设置手册页的安装目录")
SET(MAN_INSTALL_DIR
  "${SHARE_INSTALL_PREFIX}/man"
  CACHE PATH "${APPLICATION_NAME} 手册页的安装目录（默认：prefix/man）"
  FORCE
)
MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} MAN_INSTALL_DIR = ${Color_Blue}${MAN_INSTALL_DIR}${Color_Reset}")

# 设置系统管理员二进制文件的安装目录（平台相关）
if(WIN32)
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Windows平台: 系统管理员二进制文件安装目录")
  SET(SBIN_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}"
    CACHE PATH "${APPLICATION_NAME} 系统管理员二进制文件的安装目录（默认：prefix/sbin）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} SBIN_INSTALL_DIR = ${Color_Blue}${SBIN_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Windows, 与bin目录相同)${Color_Reset}")
else()
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Unix平台: 系统管理员二进制文件安装目录")
  SET(SBIN_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/sbin"
    CACHE PATH "${APPLICATION_NAME} 系统管理员二进制文件的安装目录（默认：prefix/sbin）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} SBIN_INSTALL_DIR = ${Color_Blue}${SBIN_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Unix, 独立sbin目录)${Color_Reset}")
endif()

# 设置系统配置文件的安装目录（平台相关）
if(WIN32)
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Windows平台: 系统配置文件安装目录")
  SET(SYSCONF_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/conf"
    CACHE PATH "${APPLICATION_NAME} 系统配置文件的安装目录（默认：conf）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} SYSCONF_INSTALL_DIR = ${Color_Blue}${SYSCONF_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Windows, conf目录)${Color_Reset}")
else()
  MESSAGE(STATUS "${Color_Gray}[配置]${Color_Reset} Unix平台: 系统配置文件安装目录")
  SET(SYSCONF_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/etc/${APPLICATION_NAME}"
    CACHE PATH "${APPLICATION_NAME} 系统配置文件的安装目录（默认：prefix/etc）"
    FORCE
  )
  MESSAGE(STATUS "${Color_Blue}[路径]${Color_Reset} SYSCONF_INSTALL_DIR = ${Color_Blue}${SYSCONF_INSTALL_DIR}${Color_Reset} ${Color_Yellow}(Unix, etc/子目录)${Color_Reset}")
endif()

# 显示配置摘要
MESSAGE(STATUS "${Color_Magenta}[=== 安装路径配置摘要 ===]${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}│${Color_Reset} 应用程序名称: ${Color_Bold}${APPLICATION_NAME}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}│${Color_Reset} 安装前缀:     ${Color_Blue}${CMAKE_INSTALL_PREFIX}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 二进制文件:    ${Color_Blue}${BIN_INSTALL_DIR}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 系统二进制:    ${Color_Blue}${SBIN_INSTALL_DIR}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 配置文件:      ${Color_Blue}${SYSCONF_INSTALL_DIR}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 数据文件:      ${Color_Blue}${DATA_INSTALL_PREFIX}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 本地状态:      ${Color_Blue}${LOCALSTATE_INSTALL_DIR}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}├${Color_Reset} 手册页:        ${Color_Blue}${MAN_INSTALL_DIR}${Color_Reset}")
MESSAGE(STATUS "${Color_Cyan}└${Color_Reset} 共享文件:      ${Color_Blue}${SHARE_INSTALL_PREFIX}${Color_Reset}")
MESSAGE(STATUS "${Color_Green}[完成]${Color_Reset} 安装路径配置完成")
