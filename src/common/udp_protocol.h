/*
 * Copyright (C) 1998  Mark Baysinger (mbaysing@ucsd.edu)
 * Copyright (C) 1998,1999,2000,2001  Ross Combs (rocombs@cs.nmsu.edu)
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
#ifndef INCLUDED_UDP_PROTOCOL_TYPES
#define INCLUDED_UDP_PROTOCOL_TYPES

#include "common/bn_type.h"

#if defined(_MSC_VER)
#  define PACKED_ATTR()
#elif defined(__GNUC__) || defined(__clang__)
#  define PACKED_ATTR() __attribute__((packed))
#else
#  define PACKED_ATTR()
#endif

namespace pvpgn
{

#if defined(_MSC_VER)
#pragma pack(push, 1)
#endif

/*
     * UDP packet definitions
     */

typedef struct
{
    bn_int type;
} PACKED_ATTR() t_udp_header;


typedef struct
{
    t_udp_header h;
} PACKED_ATTR() t_udp_generic;


#define SERVER_UDPTEST 0x00000005
typedef struct
{
    t_udp_header h;
    bn_int       bnettag;
} PACKED_ATTR() t_server_udptest;


#define CLIENT_UDPPING 0x00000007
typedef struct
{
    t_udp_header h;
    bn_int       unknown1;
} PACKED_ATTR() t_client_udpping;


#define CLIENT_SESSIONADDR1 0x00000008
typedef struct
{
    t_udp_header h;
    bn_int       sessionkey;
} PACKED_ATTR() t_client_sessionaddr1;


#define CLIENT_SESSIONADDR2 0x00000009
typedef struct
{
    t_udp_header h;
    bn_int       sessionkey;
    bn_int       sessionnum;
} PACKED_ATTR() t_client_sessionaddr2;

#if defined(_MSC_VER)
#pragma pack(pop)
#endif

} // namespace pvpgn

#endif // INCLUDED_UDP_PROTOCOL_TYPES
