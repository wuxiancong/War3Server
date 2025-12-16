/*
 * Class that implements the SRP-3 based authentication schema
 * used by Blizzards WarCraft 3. Implementations is based upon
 * public information available under
 * http://www.javaop.com/@ron/documents/SRP.html
 *
 * Copyright (C) 2008 - Olaf Freyer
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 */

#include "common/setup_before.h"
#include "bnetsrp3.h"

#include <cassert>
#include <cctype>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <stdexcept>

#include "common/bigint.h"
#include "common/bnethash.h"
#include "common/eventlog.h"
#include "common/util.h"
#include "common/xalloc.h"
#include "common/xstring.h"

#include "common/setup_after.h"

namespace pvpgn
{
// 2025年12月16日04:08:10
// --- 添加辅助日志函数 (Start) ---
static std::string debug_buf_to_hex(const unsigned char* buf, size_t len) {
    std::ostringstream ss;
    ss << std::hex << std::setfill('0');
    for (size_t i = 0; i < len; ++i) {
        ss << std::setw(2) << (int)buf[i];
    }
    return ss.str();
}
// --- 添加辅助日志函数 (End) ---

std::uint8_t bnetsrp3_g = 0x2F;

const unsigned char bnetsrp3_N[] = {
    0xF8, 0xFF, 0x1A, 0x8B, 0x61, 0x99, 0x18, 0x03,
    0x21, 0x86, 0xB6, 0x8C, 0xA0, 0x92, 0xB5, 0x55,
    0x7E, 0x97, 0x6C, 0x78, 0xC7, 0x32, 0x12, 0xD9,
    0x12, 0x16, 0xF6, 0x65, 0x85, 0x23, 0xC7, 0x87
};

const unsigned char bnetsrp3_I[] = {
    0xF8, 0x01, 0x8C, 0xF0, 0xA4, 0x25, 0xBA, 0x8B,
    0xEB, 0x89, 0x58, 0xB1, 0xAB, 0x6B, 0xF9, 0x0A,
    0xED, 0x97, 0x0E, 0x6C
};

BigInt BnetSRP3::N = BigInt(bnetsrp3_N, 32);
BigInt BnetSRP3::g = BigInt(bnetsrp3_g);
BigInt BnetSRP3::I = BigInt(bnetsrp3_I, 32);

int
BnetSRP3::init(const char* username_, const char* password_, BigInt* salt_)
{
    unsigned int i;
    const char* source;
    char* symbol;

    // [SRP3 DEBUG] 打印最原始的输入参数，用于检查内存指针是否正确
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] Raw inputs -> username_: \"{}\", password_: \"{}\", salt_: {}",
             username_ ? username_ : "NULL",
             password_ ? password_ : "NULL",
             salt_ ? "PRESENT" : "NULL");

    if (!username_) {
        eventlog(eventlog_level_error, __FUNCTION__, "got NULL username_");
        return -1;
    }

    username_length = std::strlen(username_);
    username = (char*)xmalloc(username_length + 1);
    source = username_;
    symbol = username;

    // 转换为大写
    for (i = 0; i < username_length; i++)
    {
        *(symbol++) = safe_toupper(*(source++));
    }

    // [SRP3 DEBUG] 打印处理后的大写用户名
    eventlog(eventlog_level_info, __FUNCTION__, "[SRP Init] Processed Username (Upper): \"{}\"", username);

    if (!((password_ == NULL) ^ (salt_ == NULL))) {
        eventlog(eventlog_level_error, __FUNCTION__, "need to init with EITHER password_ OR salt_");
        return -1;
    }

    if (password_ != NULL) {
        // ==================== 注册模式 / Server-Side Calc ====================
        password_length = std::strlen(password_);
        password = (char*)xmalloc(password_length + 1);
        source = password_;
        symbol = password;
        for (i = 0; i < password_length; i++)
        {
            *(symbol++) = safe_toupper(*(source++));
        }

        // [SRP3 DEBUG] 打印处理后的大写密码
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] Processed Password (Upper): \"{}\"", password);

        a = BigInt::random(32) % N;
        s = BigInt::random(32);

        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] Generated privKey a: {}", a.toHexString());
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] Generated Salt s: {}", s.toHexString());
    }
    else {
        // ==================== 登录模式 / Loaded form DB ====================
        password = NULL;
        password_length = 0;
        b = BigInt::random(32) % N;
        s = *salt_;

        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] Loaded Salt s: {}", s.toHexString());
    }

    B = NULL;

    s.getData(raw_salt, 32);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Init] raw_salt (Little Endian): {}", debug_buf_to_hex(raw_salt, 32));

    return 0;
}


BnetSRP3::BnetSRP3(const char* username_, BigInt& salt)
{
    // [SRP3 DEBUG] 构造函数跟踪
    eventlog(eventlog_level_debug, __FUNCTION__, "[Ctor] Called (const char* username, BigInt& salt). User: \"{}\"", username_ ? username_ : "NULL");
    init(username_, NULL, &salt);
}

BnetSRP3::BnetSRP3(const std::string& username_, BigInt& salt)
{
    // [SRP3 DEBUG] 构造函数跟踪
    eventlog(eventlog_level_debug, __FUNCTION__, "[Ctor] Called (std::string username, BigInt& salt). User: \"{}\"", username_.c_str());
    init(username_.c_str(), NULL, &salt);
}

BnetSRP3::BnetSRP3(const char* username_, const char* password_)
{
    // [SRP3 DEBUG] 构造函数跟踪
    eventlog(eventlog_level_debug, __FUNCTION__, "[Ctor] Called (const char* username, const char* password). User: \"{}\", Pass: \"{}\"",
             username_ ? username_ : "NULL", password_ ? password_ : "NULL");
    init(username_, password_, NULL);
}

BnetSRP3::BnetSRP3(const std::string& username_, const std::string& password_)
{
    // [SRP3 DEBUG] 构造函数跟踪
    eventlog(eventlog_level_debug, __FUNCTION__, "[Ctor] Called (std::string username, std::string password). User: \"{}\", Pass: \"{}\"",
             username_.c_str(), password_.c_str());
    init(username_.c_str(), password_.c_str(), NULL);
}

BnetSRP3::~BnetSRP3()
{
    if (username)
        xfree(username);

    if (password)
        xfree(password);

    delete B;
}

BigInt
BnetSRP3::getClientPrivateKey() const
{
    char* userpass;	// username,':',password
    t_hash userpass_hash;
    char private_value[32 + 20];	// s, H(userpass)
    t_hash private_value_hash;

    userpass = (char*)xmalloc(username_length + 1 + password_length + 1);
    std::memcpy(userpass, username, username_length);
    userpass[username_length] = ':';
    std::memcpy(userpass + username_length + 1, password, password_length);
    userpass[username_length + 1 + password_length] = '\0';

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculating x for {}", userpass);

    little_endian_sha1_hash(&userpass_hash, username_length + 1 + password_length, userpass);
    xfree(userpass);

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] H(P) (BE in Hash): {}", debug_buf_to_hex((unsigned char*)userpass_hash, 20));

    std::memcpy(&private_value[0], raw_salt, 32);
    std::memcpy(&private_value[32], userpass_hash, 20);
    little_endian_sha1_hash(&private_value_hash, 52, private_value);

    BigInt result((unsigned char const*)private_value_hash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculated x: {}", result.toHexString());

    return result;
}

BigInt
BnetSRP3::getScrambler(BigInt& B) const
{
    unsigned char raw_B[32];
    std::uint32_t scrambler;
    t_hash hash;

    B.getData(raw_B, 32, 4, false);
    sha1_hash(&hash, 32, raw_B);
    scrambler = *(std::uint32_t*)hash;

    BigInt u(scrambler);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculated Scrambler u: {}", u.toHexString());

    return u;
}

BigInt
BnetSRP3::getClientSecret(BigInt& B) const
{
    BigInt x = getClientPrivateKey();
    BigInt u = getScrambler(B);
    BigInt S = (N + B - g.powm(x, N)).powm((x*u) + a, N);

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculated Pre-Master Secret S: {}", S.toHexString());
    return S;
}

BigInt
BnetSRP3::getServerSecret(BigInt& A, BigInt& v)
{
    BigInt B = getServerSessionPublicKey(v);
    BigInt u = getScrambler(B);
    // 这里计算 S
    BigInt S = ((A * v.powm(u, N)) % N).powm(b, N);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculated Pre-Master Secret S (Server side): {}", S.toHexString());
    return S;
}

BigInt
BnetSRP3::hashSecret(BigInt& secret) const
{
    int i;
    unsigned char* raw_secret;
    unsigned char odd[16], even[16], hashedSecret[40];
    unsigned char* secretPointer;
    unsigned char* oddPointer;
    unsigned char* evenPointer;
    t_hash odd_hash, even_hash;

    raw_secret = secret.getData(32, 4, false);
    secretPointer = raw_secret;
    oddPointer = odd;
    evenPointer = even;

    for (i = 0; i < 16; i++)
    {
        *(oddPointer++) = *(secretPointer++);
        *(evenPointer++) = *(secretPointer++);
    }

    xfree(raw_secret);
    little_endian_sha1_hash(&odd_hash, 16, odd);
    little_endian_sha1_hash(&even_hash, 16, even);

    secretPointer = hashedSecret;
    oddPointer = (unsigned char*)odd_hash;
    evenPointer = (unsigned char*)even_hash;

    for (i = 0; i < 20; i++)
    {
        *(secretPointer++) = *(oddPointer++);
        *(secretPointer++) = *(evenPointer++);
    }

    BigInt K(hashedSecret, 40, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculated Session Key K: {}", K.toHexString());

    return K;
}

BigInt
BnetSRP3::getVerifier() const
{
    return g.powm(getClientPrivateKey(), N);
}

BigInt
BnetSRP3::getSalt() const
{
    return s;
}

void
BnetSRP3::setSalt(BigInt salt_)
{
    s = salt_;
    s.getData(raw_salt, 32);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Updated Salt s: {}", s.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Updated raw_salt (LE): {}", debug_buf_to_hex(raw_salt, 32));
}

BigInt
BnetSRP3::getClientSessionPublicKey() const
{
    BigInt A = g.powm(a, N);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Step 1.1 Internal] Client PubKey A: {}", A.toHexString());
    return A;
}

BigInt
BnetSRP3::getServerSessionPublicKey(BigInt& v)
{
    if (!B) {
        // 这是 Step 2 的核心计算 B = (v + g^b) % N
        B = new BigInt((v + g.powm(b, N)) % N);
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Step 2.2 Internal] Calculated Server PubKey B: {}", B->toHexString());
    }

    return *B;
}

BigInt
BnetSRP3::getHashedClientSecret(BigInt& B) const
{
    BigInt clientSecret = getClientSecret(B);
    return hashSecret(clientSecret);
}

BigInt
BnetSRP3::getHashedServerSecret(BigInt& A, BigInt& v)
{
    BigInt serverSecret = getServerSecret(A, v);
    return hashSecret(serverSecret);
}

BigInt
BnetSRP3::getClientPasswordProof(BigInt& A, BigInt& B, BigInt& K) const
{
    unsigned char proofData[176];
    t_hash usernameHash, proofHash;

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculating M1 Proof...");

    little_endian_sha1_hash(&usernameHash, username_length, username);

    I.getData(&proofData[0], 20, 4, false);
    std::memcpy(&proofData[20], usernameHash, 20);

    // LOG DETAILS FOR DEBUGGING M1
    eventlog(eventlog_level_debug, __FUNCTION__, "  > I:           {}", debug_buf_to_hex(&proofData[0], 20));
    eventlog(eventlog_level_debug, __FUNCTION__, "  > H(U):        {}", debug_buf_to_hex(&proofData[20], 20));

    s.getData(&proofData[40], 32);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > Salt (LE):   {}", debug_buf_to_hex(&proofData[40], 32));

    A.getData(&proofData[72], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > A (LE):      {}", debug_buf_to_hex(&proofData[72], 32));

    B.getData(&proofData[104], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > B (LE):      {}", debug_buf_to_hex(&proofData[104], 32));

    K.getData(&proofData[136], 40, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > K (LE):      {}", debug_buf_to_hex(&proofData[136], 40));

    little_endian_sha1_hash(&proofHash, 176, proofData);

    BigInt M1((unsigned char*)proofHash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] M1 Result: {}", M1.toHexString());

    return M1;
}

BigInt
BnetSRP3::getServerPasswordProof(BigInt& A, BigInt& M, BigInt& K) const
{
    unsigned char proofData[92];
    t_hash proofHash;

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] Calculating M2 Proof...");

    A.getData(&proofData[0], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > A (LE): {}", debug_buf_to_hex(&proofData[0], 32));

    M.getData(&proofData[32], 20, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > M1(LE): {}", debug_buf_to_hex(&proofData[32], 20));

    K.getData(&proofData[52], 40, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > K (LE): {}", debug_buf_to_hex(&proofData[52], 40));

    little_endian_sha1_hash(&proofHash, 92, proofData);

    BigInt M2((unsigned char*)proofHash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP Internal] M2 Result: {}", M2.toHexString());

    return M2;
}

}
