/*
 * Copyright (C) 2001,2006  Dizzy
 * ... (版权注释保持不变)
 */
#define PDIR_INTERNAL_ACCESS
#include "common/setup_before.h"
#include "pdir.h"

#include <cstring>
#include <vector>
#include <string>

#include "common/eventlog.h"
#include "common/setup_after.h"
/*
 * Copyright (C) 2001,2006  Dizzy
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
#if defined(_WIN32) || defined(WIN32)
#include "win32/dirent.h"
#else
#include <dirent.h>
#endif

namespace pvpgn
{

    Directory::Directory(const std::string& path_, bool lazyread_)
        : path(path_), lazyread(lazyread_), dir(NULL)
    {
        if (!lazyread)
            open(path_, lazyread_);
    }

    Directory::~Directory() throw()
    {
        close();
    }

    void Directory::close()
    {
        if (dir) {
            closedir(dir);
            dir = NULL;
        }
    }

    void Directory::open(const std::string& path_, bool lazyread_)
    {
        close();
        path = path_;
        lazyread = lazyread_;

        if (!lazyread) {
            dir = opendir(path.c_str());
            if (!dir) {
                throw OpenError(path);
            }
        }
    }

    void Directory::rewind()
    {
        if (dir) {
            rewinddir(dir);
        } else if (lazyread) {
            open(path, false);
        }
    }

    char const * Directory::read() const
    {
        if (!dir && lazyread) {
            const_cast<Directory*>(this)->open(path, false);
        }

        if (!dir) return NULL;

        struct dirent *dentry = readdir(dir);
        if (!dentry) return NULL;

        const char* result = dentry->d_name;

        if (strcmp(result, ".") == 0 || strcmp(result, "..") == 0)
            return read();

        return result;
    }

    Directory::operator bool() const
    {
        return dir != NULL;
    }

    bool is_directory(const char* pzPath);

    extern std::vector<std::string> dir_getfiles(const char * directory, const char* ext, bool recursive)
    {
        std::vector<std::string> files, dfiles;
        const char* _ext;

        DIR *dir;
        struct dirent* ent;

        dir = opendir(directory);
        if (!dir)
            return files;

        while ((ent = readdir(dir)) != NULL)
        {
            const std::string file_name = ent->d_name;
            std::string full_file_name = directory;
            if (full_file_name.length() > 0 && full_file_name.back() != '/' && full_file_name.back() != '\\') {
                full_file_name += "/";
            }
            full_file_name += file_name;

            if (file_name == "." || file_name == "..")
                continue;

            if (is_directory(full_file_name.c_str()))
            {
                if (recursive)
                {
                    std::vector<std::string> subfiles = dir_getfiles(full_file_name.c_str(), ext, recursive);
                    dfiles.insert(dfiles.end(), subfiles.begin(), subfiles.end());
                }
                continue;
            }

            _ext = strrchr(file_name.c_str(), '.');
            if (ext && strcmp(ext, "*") != 0) {
                if (!_ext || strcasecmp(_ext, ext) != 0)
                    continue;
            }

            files.push_back(full_file_name);
        }
        closedir(dir);

        files.insert(files.begin(), dfiles.begin(), dfiles.end());

        return files;
    }

    bool is_directory(const char* pzPath)
    {
        if (pzPath == NULL) return false;

        DIR *pDir = opendir(pzPath);
        if (pDir != NULL)
        {
            closedir(pDir);
            return true;
        }
        return false;
    }
}
