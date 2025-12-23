cmake_minimum_required(VERSION 3.1.0)

if(POLICY CMP0074)
	cmake_policy(SET CMP0074 NEW)
endif()

if(POLICY CMP0075)
	cmake_policy(SET CMP0075 NEW)
endif()

set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# 项目定义
project(War3Server CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 编译选项定义
option(WITH_BNETD "编译 bnetd 目标" ON)
option(WITH_D2CS "编译 d2cs 目标" ON)
option(WITH_D2DBS "编译 d2dbs 目标" ON)
option(WITH_LUA "启用 Lua 支持" OFF)
if(WIN32)
	option(WITH_WIN32_GUI "启用图形界面构建（默认开启）" ON)
endif(WIN32)

# 存储后端选项
option(WITH_MYSQL "包含 MySQL 用户账户支持" OFF)
option(WITH_SQLITE3 "包含 SQLite3 用户账户支持" OFF)
option(WITH_PGSQL "包含 PostgreSQL 用户账户支持" OFF)
option(WITH_ODBC "包含 ODBC 用户账户支持" OFF)

if(WIN32)
	set(ZLIB_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/lib/zlib/x86)
endif()

# 查找 ZLIB 库
find_package(ZLIB REQUIRED)

# 包含配置检查文件
include(ConfigureChecks.cmake)

# 编译器特定设置
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
	# 使用 Clang 编译器
	set( CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -Wno-idiomatic-parentheses -pedantic")

elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	# 使用 G++ 编译器
	if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)
		message(FATAL_ERROR "需要 G++ 5.1 或更高版本")
	endif()
	set( CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -pedantic -Wno-variadic-macros" )

elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
	# 使用 Visual Studio 编译器
	if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.0)
		message(FATAL_ERROR "需要 Visual Studio 2015 或更高版本")
	endif()

	# -----------------------------------------------------------
	# 强制 MSVC 使用 UTF-8 编码读取源文件，解决 C4819 警告
	# -----------------------------------------------------------
	add_compile_options(/utf-8)

	# 预处理器定义
	add_definitions(
		-D_CRT_SECURE_NO_DEPRECATE
		-D_CRT_NONSTDC_NO_DEPRECATE
		-DUNICODE
		-D_UNICODE
	)

        # 调试版本编译器标志：
	#	/Zi 创建调试信息 PDB 文件
	#	/Od 禁用优化
	# 	/Oy- 不抑制帧指针（调试推荐）
	#	/MTd 使用静态链接、线程安全的调试版 CRT 库（Magic Builder 构建时设置此标志）
	#
	# 发布版本编译器标志：
	#	/MT 使用静态链接、线程安全的 CRT 库（Magic Builder 构建时设置此标志）
	# 	/GS- 禁用缓冲区安全检查
	#
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od /Oy-")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")

	# 链接器标志说明及为何在发布版本中启用带调试信息的 PDB：
	#  https://www.wintellect.com/correctly-creating-native-c-release-build-pdbs
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")
endif()

# 添加子目录
add_subdirectory(conf)
add_subdirectory(files)
add_subdirectory(lib/fmt)
add_subdirectory(man)
add_subdirectory(src)
if(WITH_LUA)
	add_subdirectory(lua)
endif(WITH_LUA)

# 启用测试功能
enable_testing()

# 卸载目标配置
configure_file(
	"${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in"
	"${CMAKE_MODULE_PATH}/cmake_uninstall.cmake"
	IMMEDIATE @ONLY)

add_custom_target(uninstall
	COMMAND ${CMAKE_COMMAND} -P ${CMAKE_MODULE_PATH}/cmake_uninstall.cmake)

# 清理目标配置
configure_file(
	"${CMAKE_MODULE_PATH}/cmake_purge.cmake.in"
	"${CMAKE_MODULE_PATH}/cmake_purge.cmake"
	IMMEDIATE @ONLY)

add_custom_target(purge
	COMMAND ${CMAKE_COMMAND} -P ${CMAKE_MODULE_PATH}/cmake_purge.cmake)
