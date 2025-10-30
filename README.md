War3Server 是一款免费开源的跨平台服务器软件，支持 Battle.net 和 Westwood Online 游戏客户端。War3Server-PRO 是官方 War3Server 项目的一个分支，官方项目于 2011 年停止开发，War3Server-PRO 旨在为 War3Server 提供持续维护和额外功能。

[![License (GPL version 2)](https://img.shields.io/badge/license-GNU%20GPL%20version%202-blue.svg?style=flat-square)](http://opensource.org/licenses/GPL-2.0)
![Language (C++)](https://img.shields.io/badge/powered_by-C++-brightgreen.svg?style=flat-square)
[![Language (Lua)](https://img.shields.io/badge/powered_by-Lua-red.svg?style=flat-square)](https://lua.org)
[![Github Releases (by Release)](https://img.shields.io/github/downloads/wuxiancong/War3Server/1.99.7.2.1/total.svg?maxAge=2592000)]()

[![Compiler (Microsoft Visual C++)](https://img.shields.io/badge/compiled_with-Microsoft%20Visual%20C++-yellow.svg?style=flat-square)](https://msdn.microsoft.com/en-us/vstudio/hh386302.aspx)
[![Compiler (LLVM/Clang)](https://img.shields.io/badge/compiled_with-LLVM/Clang-lightgrey.svg?style=flat-square)](http://clang.llvm.org/)
[![Compiler (GCC)](https://img.shields.io/badge/compiled_with-GCC-yellowgreen.svg?style=flat-square)](https://gcc.gnu.org/)

[![Build Status](https://travis-ci.org/wuxiancong/War3Server.svg?branch=master)](https://travis-ci.org/wuxiancong/War3Server)
[![Build status](https://ci.appveyor.com/api/projects/status/dqoj9lkvhfwthmn6)](https://ci.appveyor.com/project/HarpyWar/pvpgn)

[Deleaker](http://www.deleaker.com/) helps us find memory leaks.

## Tracking
默认情况下，跟踪功能已启用，仅用于向跟踪服务器发送信息数据（例如服务器描述、主页、正常运行时间、用户数量）。要禁用跟踪，请设置 ````track = 0```` in ````conf/bnetd.conf````.

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

## Support
[Create an issue](https://github.com/wuxiancong/War3Server/issues) if you have any questions, suggestions, or anything else to say about War3Server-PRO. Please note that D2GS is not part of the War3Server project and is therefore unsupported here.
Set `loglevels = fatal,error,warn,info,debug,trace` in `bnetd.conf` before obtaining logs and posting them.

## Development
Submit pull requests to contribute to this project. Utilize C++11 features and adhere to the [C++ Core Guidelines](https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md) whenever possible.

## Building
See [docs/ports.md](https://github.com/wuxiancong/War3Server/blob/master/docs/ports.md) for operating systems and compilers that have been confirmed to work with War3Server. Any operating system that supports WinAPI or POSIX, and any C++11 compliant compiler should be able to build War3Server. The CMake files have been hardcoded to reject compilers older than Visual Studio 2015 and GCC 5.1.

#### Windows
Use [Magic Builder](https://github.com/pvpgn/pvpgn-magic-builder).

Alternatively, use cmake to generate the .sln project and build it from Visual Studio.
```
cmake -g "Visual Studio 14 2015" -H./ -B./build
```
This will generate .sln in `build` directory.

#### Linux in general
Do not blindly run these commands. The main problem with older distributions is installing CMake 3.2.x and GCC 5, so external repositories are used in the examples.

```
apt-get install git install cmake make build-essential zlib1g-dev
apt-get install liblua5.1-0-dev #Lua support
apt-get install mysql-server mysql-client libmysqlclient-dev #MySQL support
cd /home
git clone https://github.com/wuxiancong/War3Server.git
cmake -D CMAKE_INSTALL_PREFIX=/usr/local/pvpgn -D WITH_MYSQL=true -D WITH_LUA=true ../
make
make install
```

#### Ubuntu 16.04, 18.04
```
sudo apt-get -y install build-essential git cmake zlib1g-dev
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server && cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

#### Ubuntu 14.04
```
sudo apt-get -y install build-essential zlib1g-dev git
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get -y update
sudo apt-get -y install gcc-5 g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
sudo add-apt-repository -y ppa:george-edison55/cmake-3.x
sudo apt-get update
sudo apt-get -y install cmake
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server && cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

#### Debian 8 with clang compiler
```
sudo apt-get -y install build-essential zlib1g-dev clang libc++-dev git
wget https://cmake.org/files/v3.7/cmake-3.7.1-Linux-x86_64.tar.gz
tar xvfz cmake-3.7.1-Linux-x86_64.tar.gz
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server && CC=/usr/bin/clang CXX=/usr/bin/clang++ ../cmake-3.7.1-Linux-x86_64/bin/cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

#### CentOS 7
```
sudo yum -y install epel-release centos-release-scl
sudo yum -y install git zlib-devel cmake3 devtoolset-4-gcc*
sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server
CC=/opt/rh/devtoolset-4/root/usr/bin/gcc CXX=/opt/rh/devtoolset-4/root/usr/bin/g++ cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

#### Fedora 25
```
sudo dnf -y install gcc-c++ gcc make zlib-devel cmake git
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server
cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

#### FreeBSD 11
```
sudo pkg install -y git cmake
git clone https://github.com/wuxiancong/War3Server.git
cd War3Server
cmake -G "Unix Makefiles" -H./ -B./build
cd build && make
```

Full instructions: [Русский](http://harpywar.com/?a=articles&b=2&c=1&d=74) | [English](http://harpywar.com/?a=articles&b=2&c=1&d=74&lang=en)

## 局域网或VPS主机（使用私有IP地址）

部分VPS提供商不会为您的服务器分配直接的公网IP地址。如果您的服务器位于NAT网络后，或者您的主机托管在家中，则需要在`address_translation.conf`文件中配置路由转换。公网IP地址会作为路由服务器地址推送给游戏客户端，用于匹配游戏。如果推送的地址不正确，玩家将无法匹配和加入游戏（长时间搜索游戏并出现错误）。

如果您的网络接口直接绑定到公网IP地址，War3Server可以自动识别，无需执行此步骤。

## License

本程序为自由软件；您可以根据自由软件基金会发布的 GNU 通用公共许可证的条款重新分发和/或

修改本程序；您可以选择使用许可证的第 2 版

或（由您选择）任何后续版本。

本程序分发的目的是希望它能有用，

但没有任何担保；甚至不包含适销性或特定用途适用性的默示担保。

请参阅
GNU 通用公共许可证了解更多详情。

您应该已收到一份 GNU 通用公共许可证的副本

随本程序一起提供；如果没有，请写信至：自由软件

基金会，地址：51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA。
