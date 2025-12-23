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

#include "common/bigint.h"
#include "common/bnethash.h"
#include "common/eventlog.h"
#include "common/xalloc.h"
#include "common/xstring.h"

#include "common/setup_after.h"

namespace pvpgn
{

// 辅助日志函数：转Hex
static std::string debug_buf_to_hex(const unsigned char* buf, size_t len) {
    std::ostringstream ss;
    ss << std::hex << std::setfill('0');
    for (size_t i = 0; i < len; ++i) {
        ss << std::setw(2) << (int)buf[i];
    }
    return ss.str();
}

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

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 初始化] 原始输入 -> 用户名: \"{}\", 密码: \"{}\", 盐: {}",
             username_ ? username_ : "NULL",
             password_ ? password_ : "NULL",
             salt_ ? "PRESENT" : "NULL");

    if (!username_) {
        eventlog(eventlog_level_error, __FUNCTION__, "got NULL username_");
        return -1;
    }

    // =========== 修改开始 ===========
    // [修复] 处理用户名：防止宏副作用导致字符被跳过
    username_length = std::strlen(username_);
    username = (char*)xmalloc(username_length + 1);

    source = username_;
    symbol = username;

    for (i = 0; i < username_length; i++) {
        char c = *source; // 1. 先把字符取出来
        source++;         // 2. 指针只移动一次

        *symbol = safe_toupper(c); // 3. 安全转换
        symbol++;
    }
    *symbol = '\0'; // 4. 手动封口，保证字符串完整
    // =========== 修改结束 ===========

    if (!((password_ == NULL) ^ (salt_ == NULL))) {
        eventlog(eventlog_level_error, __FUNCTION__, "need to init with EITHER password_ OR salt_");
        return -1;
    }

    if (password_ != NULL) {
        // ==================== 注册模式 ====================
        password_length = std::strlen(password_);
        password = (char*)xmalloc(password_length + 1);
        std::memcpy(password, password_, password_length);
        password[password_length] = '\0';

        a = BigInt::random(32) % N;
        s = BigInt::random(32);
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 初始化] 生成私钥 a: {}", a.toHexString());
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 初始化] 生成盐值 s: {}", s.toHexString());
    }
    else {
        password = NULL;
        password_length = 0;
        b = BigInt::random(32) % N;
        s = *salt_;
    }

    B = NULL;

    s.getData(raw_salt, 32);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 初始化] 原始盐值 (小端序/LE): {}", debug_buf_to_hex(raw_salt, 32));

    return 0;
}


BnetSRP3::BnetSRP3(const char* username_, BigInt& salt)
{
    init(username_, NULL, &salt);
}

BnetSRP3::BnetSRP3(const std::string& username_, BigInt& salt)
{
    init(username_.c_str(), NULL, &salt);
}

BnetSRP3::BnetSRP3(const char* username_, const char* password_)
{
    init(username_, password_, NULL);
}

BnetSRP3::BnetSRP3(const std::string& username_, const std::string& password_)
{
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

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 正在计算 x, 输入: \"{}\"", userpass);

    little_endian_sha1_hash(&userpass_hash, username_length + 1 + password_length, userpass);
    xfree(userpass);

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] H(P) (Hash字节流): {}", debug_buf_to_hex((unsigned char*)userpass_hash, 20));

    std::memcpy(&private_value[0], raw_salt, 32);
    std::memcpy(&private_value[32], userpass_hash, 20);
    little_endian_sha1_hash(&private_value_hash, 52, private_value);

    BigInt result((unsigned char const*)private_value_hash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 计算出的 x (BigInt): {}", result.toHexString());

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
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 计算出的扰码 u (BigInt): {}", u.toHexString());

    return u;
}

BigInt BnetSRP3::getClientSecret(BigInt& B) const
{
    // SRP 客户端公式: S = (B - g^x)^(a + u * x) % N

    // 1. 获取私钥 x 和 扰码 u
    BigInt x = getClientPrivateKey();
    BigInt u = getScrambler(B);

    // 2. 计算底数 Base = (B - g^x) % N
    // 防止无符号减法溢出: (N + B - g^x) % N
    BigInt g_pow_x = g.powm(x, N);
    BigInt N_plus_B = N + B;
    BigInt base = (N_plus_B - g_pow_x) % N;

    // 3. 计算指数 Exp = a + u * x
    BigInt x_mul_u = x * u;
    BigInt exp = x_mul_u + a;

    // 4. 计算 S
    BigInt S = base.powm(exp, N);

    eventlog(eventlog_level_debug, __FUNCTION__, "=== [服务端(ClientLogic) S 计算细节] ===");
    eventlog(eventlog_level_debug, __FUNCTION__, "B:       {}", B.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "x:       {}", x.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "u:       {}", u.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "a:       {}", a.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "g^x%N:   {}", g_pow_x.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "Base:    {}", base.toHexString());    // (N+B-g^x)%N
    eventlog(eventlog_level_debug, __FUNCTION__, "x*u:     {}", x_mul_u.toHexString()); // 检查乘法精度
    eventlog(eventlog_level_debug, __FUNCTION__, "Exp:     {}", exp.toHexString());     // (x*u)+a
    eventlog(eventlog_level_debug, __FUNCTION__, "S:       {}", S.toHexString());

    return S;
}

BigInt
BnetSRP3::getServerSecret(BigInt& A, BigInt& v)
{
    // 1. 先计算 B 和 u (这是之前缺失的部分)
    BigInt B = getServerSessionPublicKey(v);
    BigInt u = getScrambler(B);

    // 2. 拆解公式: S = ((A * v^u) % N)^b % N

    // v^u % N
    BigInt v_pow_u = v.powm(u, N);

    // A * (v^u)
    BigInt base_unmod = A * v_pow_u;

    // (A * v^u) % N
    BigInt base = base_unmod % N;

    // S = base^b % N
    BigInt S = base.powm(b, N);

    // 3. 打印详细日志
    eventlog(eventlog_level_error, __FUNCTION__, "=== [服务端 S 计算细节] ===");
    eventlog(eventlog_level_error, __FUNCTION__, "A:       {}", A.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "v:       {}", v.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "B:       {}", B.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "u:       {}", u.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "b:       {}", b.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "v^u%N:   {}", v_pow_u.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "A*v^u:   {}", base_unmod.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "Base:    {}", base.toHexString());
    eventlog(eventlog_level_error, __FUNCTION__, "S (Result): {}", S.toHexString());

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
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 计算出的会话密钥 K (BigInt): {}", K.toHexString());

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
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 更新 BigInt 盐值 s: {}", s.toHexString());
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 更新原始盐值 (小端序/LE): {}", debug_buf_to_hex(raw_salt, 32));
}

BigInt
BnetSRP3::getClientSessionPublicKey() const
{
    BigInt A = g.powm(a, N);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 步骤 1.1] 客户端公钥 A (BigInt): {}", A.toHexString());
    return A;
}

BigInt
BnetSRP3::getServerSessionPublicKey(BigInt& v)
{
    if (!B) {
        // B = (v + g^b) % N
        B = new BigInt((v + g.powm(b, N)) % N);
        eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 步骤 2.2] 服务端公钥 B (BigInt): {}", B->toHexString());
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

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 开始计算 M1 证明...");

    little_endian_sha1_hash(&usernameHash, username_length, username);

    I.getData(&proofData[0], 20, 4, false);
    std::memcpy(&proofData[20], usernameHash, 20);

    // LOG DETAILS FOR DEBUGGING M1
    eventlog(eventlog_level_debug, __FUNCTION__, "  > I (Buffer):        {}", debug_buf_to_hex(&proofData[0], 20));
    eventlog(eventlog_level_debug, __FUNCTION__, "  > H(U) (Buffer):     {}", debug_buf_to_hex(&proofData[20], 20));

    s.getData(&proofData[40], 32);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > 盐值 (小端序/LE):   {}", debug_buf_to_hex(&proofData[40], 32));

    A.getData(&proofData[72], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > A (小端序/LE):     {}", debug_buf_to_hex(&proofData[72], 32));

    B.getData(&proofData[104], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > B (小端序/LE):     {}", debug_buf_to_hex(&proofData[104], 32));

    K.getData(&proofData[136], 40, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > K (小端序/LE):     {}", debug_buf_to_hex(&proofData[136], 40));

    little_endian_sha1_hash(&proofHash, 176, proofData);

    BigInt M1((unsigned char*)proofHash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] M1 结果 (BigInt): {}", M1.toHexString());

    return M1;
}

BigInt
BnetSRP3::getServerPasswordProof(BigInt& A, BigInt& M, BigInt& K) const
{
    unsigned char proofData[92];
    t_hash proofHash;

    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] 开始计算 M2 证明...");

    A.getData(&proofData[0], 32, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > A (小端序/LE): {}", debug_buf_to_hex(&proofData[0], 32));

    M.getData(&proofData[32], 20, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > M1 (小端序/LE): {}", debug_buf_to_hex(&proofData[32], 20));

    K.getData(&proofData[52], 40, 4, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "  > K (小端序/LE): {}", debug_buf_to_hex(&proofData[52], 40));

    little_endian_sha1_hash(&proofHash, 92, proofData);

    BigInt M2((unsigned char*)proofHash, 20, 1, false);
    eventlog(eventlog_level_debug, __FUNCTION__, "[SRP 内部] M2 结果 (BigInt): {}", M2.toHexString());

    return M2;
}

}
