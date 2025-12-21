# 如果没有设置 APPLICATION_NAME，则使用 PROJECT_NAME 作为 APPLICATION_NAME
IF (NOT APPLICATION_NAME)
   MESSAGE(STATUS "将 ${PROJECT_NAME} 用作 APPLICATION_NAME")
   SET(APPLICATION_NAME ${PROJECT_NAME})
ENDIF (NOT APPLICATION_NAME)

# 设置可执行文件和库的安装基础目录
SET(EXEC_INSTALL_PREFIX
  "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH  "可执行文件和库的基础安装目录"
  FORCE
)

# 设置共享文件的安装基础目录
SET(SHARE_INSTALL_PREFIX
  "${CMAKE_INSTALL_PREFIX}/share"
  CACHE PATH "共享文件的安装基础目录（安装到 share/ 目录下）"
  FORCE
)

# 设置应用程序数据的父目录
SET(DATA_INSTALL_PREFIX
  "${SHARE_INSTALL_PREFIX}/${APPLICATION_NAME}"
  CACHE PATH "应用程序数据文件的父安装目录"
  FORCE
)

# 设置二进制文件的安装目录
SET(BIN_INSTALL_DIR
  "${EXEC_INSTALL_PREFIX}/bin"
  CACHE PATH "${APPLICATION_NAME} 二进制文件的安装目录（默认：prefix/bin）"
  FORCE
)

#***********************************#

# 设置本地状态文件的安装目录（平台相关）
if(WIN32)
  SET(LOCALSTATE_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/var"
    CACHE PATH "${APPLICATION_NAME} 本地状态文件的安装目录（默认：prefix/var）"
    FORCE
  )
else()
  SET(LOCALSTATE_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/var/${APPLICATION_NAME}"
    CACHE PATH "${APPLICATION_NAME} 本地状态文件的安装目录（默认：prefix/var）"
    FORCE
  )
endif()

# 设置手册页的安装目录
SET(MAN_INSTALL_DIR
  "${SHARE_INSTALL_PREFIX}/man"
  CACHE PATH "${APPLICATION_NAME} 手册页的安装目录（默认：prefix/man）"
  FORCE
)

# 设置系统管理员二进制文件的安装目录（平台相关）
if(WIN32)
  SET(SBIN_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}"
    CACHE PATH "${APPLICATION_NAME} 系统管理员二进制文件的安装目录（默认：prefix/sbin）"
    FORCE
  )
else()
  SET(SBIN_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/sbin"
    CACHE PATH "${APPLICATION_NAME} 系统管理员二进制文件的安装目录（默认：prefix/sbin）"
    FORCE
  )
endif()

# 设置系统配置文件的安装目录（平台相关）
if(WIN32)
  SET(SYSCONF_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/conf"
    CACHE PATH "${APPLICATION_NAME} 系统配置文件的安装目录（默认：conf）"
    FORCE
  )
else()
  SET(SYSCONF_INSTALL_DIR
    "${EXEC_INSTALL_PREFIX}/etc/${APPLICATION_NAME}"
    CACHE PATH "${APPLICATION_NAME} 系统配置文件的安装目录（默认：prefix/etc）"
    FORCE
  )
endif()
