/*
 * Modified to support Windows and Linux automatically without external defines.
 */
#ifndef INCLUDED_MKDIR_PROTOS
#define INCLUDED_MKDIR_PROTOS

#include <sys/stat.h> /* Common for stat struct and mode_t constants */

/* ------------------------------------------------------------- */
/*                      Windows Platform                         */
/* ------------------------------------------------------------- */
#if defined(_WIN32)
#include <direct.h>   /* MSVC/MinGW puts _mkdir here */
#include <io.h>

/*
     * Windows _mkdir takes only 1 argument (the path).
     * We define p_mkdir to take 2 arguments to stay compatible with the
     * Linux usage, but we macro-discard the second argument (permissions).
     */
#define p_mkdir(path, mode) _mkdir(path)

/* ------------------------------------------------------------- */
/*                      Linux / Unix Platform                    */
/* ------------------------------------------------------------- */
#else
#include <sys/types.h>
#include <unistd.h>

/*
     * Linux mkdir takes 2 arguments: path and permission mode (e.g. 0755).
     */
#define p_mkdir(path, mode) mkdir(path, mode)

#endif

#endif
