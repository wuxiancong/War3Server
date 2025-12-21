# ============================================================================
# 颜色定义（添加到文件开头）
# ============================================================================
# 检查是否支持颜色输出（非Windows或启用颜色的Windows）
if(NOT WIN32 OR CMAKE_COLOR_MAKEFILE)
    string(ASCII 27 Esc)
    # 基础颜色
    set(Color_Reset   "${Esc}[0m")
    set(Color_Bold    "${Esc}[1m")

    # 主要颜色
    set(Color_Gray    "${Esc}[90m")      # 灰色
    set(Color_Red     "${Esc}[31m")      # 红色
    set(Color_Green   "${Esc}[32m")      # 绿色
    set(Color_Yellow  "${Esc}[33m")      # 黄色
    set(Color_Blue    "${Esc}[34m")      # 蓝色

    # 亮色
    set(Color_LRed    "${Esc}[91m")
    set(Color_LGreen  "${Esc}[92m")
    set(Color_LYellow "${Esc}[93m")
    set(Color_LBlue   "${Esc}[94m")
else()
    # 不支持颜色时使用空字符串
    set(Color_Reset   "")
    set(Color_Bold    "")
    set(Color_Gray    "")
    set(Color_Red     "")
    set(Color_Green   "")
    set(Color_Yellow  "")
    set(Color_Blue    "")
    set(Color_LRed    "")
    set(Color_LGreen  "")
    set(Color_LYellow "")
    set(Color_LBlue   "")
endif()

# ============================================================================
# 检查 mkdir 函数参数数量的宏（带颜色输出）
# ============================================================================

# - 检查文件是否能被包含
#
# CHECK_MKDIR_ARGS(VARIABLE)
#
#  变量说明：
#  VARIABLE - 返回变量，指示 mkdir/_mkdir 是否需要单个参数
#
# 可以在调用此宏之前设置以下变量来修改检查方式：
#
#  CMAKE_REQUIRED_FLAGS = 编译命令行标志字符串
#  CMAKE_REQUIRED_DEFINITIONS = 要定义的宏列表 (-DFOO=bar)
#  CMAKE_REQUIRED_INCLUDES = 包含目录列表

MACRO(CHECK_MKDIR_ARGS VARIABLE)
  # 检查变量是否尚未设置（避免重复检查）
  IF("${VARIABLE}" MATCHES "^${VARIABLE}$")
    # 输出检查开始信息（灰色）
    message(STATUS "${Color_Gray}[检查开始]${Color_Reset} 检查 mkdir 函数参数数量...")

    # 初始化配置文件内容
    SET(CMAKE_CONFIGURABLE_FILE_CONTENT "/* */\n")

    # 处理必需的包含目录
    IF(CMAKE_REQUIRED_INCLUDES)
      SET(CHECK_MKDIR_ARGS_INCLUDE_DIRS "-DINCLUDE_DIRECTORIES=${CMAKE_REQUIRED_INCLUDES}")
      message(STATUS "${Color_Gray}[配置]${Color_Reset} 包含目录: ${CMAKE_REQUIRED_INCLUDES}")
    ELSE(CMAKE_REQUIRED_INCLUDES)
      SET(CHECK_MKDIR_ARGS_INCLUDE_DIRS)
      message(STATUS "${Color_Gray}[配置]${Color_Reset} 无额外包含目录")
    ENDIF(CMAKE_REQUIRED_INCLUDES)

    # 设置宏检查相关的标志和内容
    SET(CHECK_MKDIR_ARGS_CONTENT "/* */\n")
    SET(MACRO_CHECK_MKDIR_ARGS_FLAGS ${CMAKE_REQUIRED_FLAGS})

    # 如果有额外编译标志，输出提示
    IF(CMAKE_REQUIRED_FLAGS)
      message(STATUS "${Color_Gray}[配置]${Color_Reset} 编译标志: ${CMAKE_REQUIRED_FLAGS}")
    ENDIF()

    IF(CMAKE_REQUIRED_DEFINITIONS)
      message(STATUS "${Color_Gray}[配置]${Color_Reset} 定义宏: ${CMAKE_REQUIRED_DEFINITIONS}")
    ENDIF()

    # 构建测试程序的源代码内容
    SET(CMAKE_CONFIGURABLE_FILE_CONTENT
      "${CMAKE_CONFIGURABLE_FILE_CONTENT}\n#include<direct.h>\nint main(){mkdir(\"\");}\n")

    message(STATUS "${Color_Gray}[生成]${Color_Reset} 创建测试源文件")

    # 配置生成测试源文件
    CONFIGURE_FILE("${CMAKE_ROOT}/Modules/CMakeConfigurableFile.in"
      "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckMkdirArgs.cxx" @ONLY IMMEDIATE)

    # 开始检查单参数 mkdir 函数
    message(STATUS "${Color_Gray}[编译]${Color_Reset} 尝试编译测试程序...")

    # 尝试编译测试程序
    TRY_COMPILE(${VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckMkdirArgs.cxx
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      CMAKE_FLAGS
      -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_MKDIR_ARGS_FLAGS}
      "${CHECK_MKDIR_ARGS_INCLUDE_DIRS}"
      OUTPUT_VARIABLE OUTPUT)

    # 处理编译结果
    IF(${VARIABLE})
      # 编译成功：mkdir 只需要单个参数
      message(STATUS "${Color_Green}[✓ 成功]${Color_Reset} mkdir 函数只需要单个参数")
      SET(${VARIABLE} 1 CACHE INTERNAL "mkdir 函数只需要单个参数")

      # 记录详细成功日志（带颜色）
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "========================================\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "检查 mkdir 参数数量 - 成功\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "时间: ${CMAKE_CURRENT_TIME}\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "结果: mkdir 接受单个参数 (mkdir(\"\"))\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "输出:\n${OUTPUT}\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "========================================\n\n")

    ELSE(${VARIABLE})
      # 编译失败：mkdir 可能需要多个参数
      message(STATUS "${Color_Red}[✗ 失败]${Color_Reset} mkdir 函数需要多个参数")
      SET(${VARIABLE} "" CACHE INTERNAL "mkdir 函数需要多个参数")

      # 记录详细错误日志（带颜色指示）
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "========================================\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "检查 mkdir 参数数量 - 失败\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "时间: ${CMAKE_CURRENT_TIME}\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "结果: mkdir 可能需要模式参数 (mkdir(\"\", mode))\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "输出:\n${OUTPUT}\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "源代码:\n${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "========================================\n\n")
    ENDIF(${VARIABLE})

    # 输出检查完成信息
    IF(${VARIABLE})
      message(STATUS "${Color_Green}[检查完成]${Color_Reset} mkdir 函数参数检查成功")
    ELSE(${VARIABLE})
      message(STATUS "${Color_Red}[检查完成]${Color_Reset} mkdir 函数参数检查失败")
    ENDIF(${VARIABLE})

  ELSE("${VARIABLE}" MATCHES "^${VARIABLE}$")
    # 变量已设置，输出跳过信息
    message(STATUS "${Color_Yellow}[跳过]${Color_Reset} mkdir 参数检查已执行 (${VARIABLE}=${${VARIABLE}})")
  ENDIF("${VARIABLE}" MATCHES "^${VARIABLE}$")
ENDMACRO(CHECK_MKDIR_ARGS)

# ============================================================================
# 增强版检查宏（可选，提供更简洁的接口）
# ============================================================================
macro(ENHANCED_CHECK_MKDIR_ARGS VARIABLE)
  message(STATUS "${Color_Blue}[========== 开始检查 mkdir 参数 ==========]${Color_Reset}")
  CHECK_MKDIR_ARGS(${VARIABLE})
  message(STATUS "${Color_Blue}[========== 结束检查 mkdir 参数 ==========]${Color_Reset}")
endmacro()

# ============================================================================
# 颜色测试函数（可选，用于测试颜色是否正常工作）
# ============================================================================
function(TEST_COLORS)
  message(STATUS "${Color_Gray}[测试]${Color_Reset} 灰色 - 表示检查中")
  message(STATUS "${Color_Green}[测试]${Color_Reset} 绿色 - 表示成功/找到")
  message(STATUS "${Color_Red}[测试]${Color_Reset} 红色 - 表示失败/未找到")
  message(STATUS "${Color_Yellow}[测试]${Color_Reset} 黄色 - 表示警告/跳过")
  message(STATUS "${Color_Blue}[测试]${Color_Reset} 蓝色 - 表示分组/标题")
  message(STATUS "${Color_LGreen}[测试]${Color_Reset} 亮绿色 - 表示详细信息")
endfunction()
