/*
 * Copyright (C) 1999  Ross Combs (rocombs@cs.nmsu.edu)
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
#ifndef INCLUDED_SEND_PROTOS
#define INCLUDED_SEND_PROTOS

/*
 * Platform Detection & Header Inclusion
 */
#ifdef _WIN32
/* Windows Platform */
#include <winsock2.h>
#else
/* Linux / Unix Platform */
#include <sys/types.h>
#include <sys/socket.h>
#endif

/*
 * Compatibility Mapping:
 * The original code maps send() to sendto().
 * We remove this mapping and let each platform use its native send().
 */
#ifdef send
#undef send
#endif
/* Don't redefine send() - use the platform's native send() function */

#endif
