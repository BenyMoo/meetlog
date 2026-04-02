# Pro 离线激活方案

## 目标

- App 端可以离线激活 Pro。
- 用户只需要复制一段“设备激活请求”到外部系统，拿回一段“激活码”粘贴进 App。
- 外部系统持有私钥，App 仅内置公钥。

## 设备激活请求

App 端会生成一个 RSA-OAEP 加密后的 Base64URL 字符串。

加密前的明文 JSON 结构：

```json
{
  "a": "meetlog.pro",
  "d": "raw-device-id",
  "t": "imei|serial|android_id|identifier_for_vendor|build_fingerprint",
  "i": 1770000000000
}
```

字段说明：

- `a`: appId
- `d`: 设备原始标识
- `t`: 标识类型
- `i`: 请求时间戳，毫秒

## 服务端处理流程

1. 使用“请求解密私钥”解密设备激活请求。
2. 解析得到 `a/d/t/i`。
3. 生成设备指纹：

```txt
fingerprint = sha256_hex("{appId}|{type}|{deviceId}")
```

4. 组装许可证 payload：

```json
{
  "a": "meetlog.pro",
  "f": "device-fingerprint-hex",
  "l": "pro",
  "n": "order-or-license-no",
  "i": 1770000000000,
  "e": null
}
```

建议字段：

- `a`: appId
- `f`: 设备指纹
- `l`: 许可证类型，固定 `pro`
- `n`: 订单号或许可证编号
- `i`: 签发时间
- `e`: 过期时间，毫秒时间戳；永久许可证可不传或传 `null`

5. 对 payload 原始 JSON 字节做 `SHA256withRSA` 签名。
6. 返回激活码：

```txt
base64url(payloadJsonBytes).base64url(signatureBytes)
```

## App 端验证规则

1. 用内置“许可证验签公钥”校验签名。
2. 校验 `a == meetlog.pro`。
3. 重新计算当前设备指纹，要求与 payload 中的 `f` 一致。
4. 若存在 `e`，要求当前时间未超过 `e`。
5. 校验通过后，把整段激活码保存到本地；下次启动重新离线验签。

## 服务端 API 建议

### 1. 解密预览接口

`POST /api/licenses/preview`

请求：

```json
{
  "requestCiphertext": "..."
}
```

返回：

```json
{
  "appId": "meetlog.pro",
  "deviceIdType": "android_id",
  "maskedDeviceId": "a1b2****z9y8",
  "fingerprint": "..."
}
```

### 2. 发码接口

`POST /api/licenses/issue`

请求：

```json
{
  "requestCiphertext": "...",
  "orderNo": "ORDER_123456",
  "licenseType": "pro",
  "expiresAt": null
}
```

返回：

```json
{
  "licenseCode": "payload.signature"
}
```

## 当前仓库的本地联调材料

当前已经在本地生成了一套开发密钥，只用于联调：

- 请求解密公钥已写入 App：`proRequestPublicKeyPem`
- 许可证验签公钥已写入 App：`proLicenseVerifyPublicKeyPem`
- 本地密钥目录：`.devkeys/`
- 已加入 `.gitignore`，不会被提交

本地文件：

- `.devkeys/request_keystore.p12`
- `.devkeys/license_keystore.p12`
- `.devkeys/request_private.pem`
- `.devkeys/license_private.pem`

当前联调密码：

- keystore 密码：`meetlog123`
- key 密码：`meetlog123`

## 本地手工发码

App 里复制出“设备激活请求”后，可先在本地直接签一张测试许可证：

```bash
java -cp .devkeys IssueLicense "<requestCiphertext>" "ORDER_001" "pro"
```

带过期时间：

```bash
java -cp .devkeys IssueLicense "<requestCiphertext>" "ORDER_001" "pro" 1893456000000
```

说明：

- 第一个参数：App 复制出来的激活请求密文
- 第二个参数：订单号或许可证编号
- 第三个参数：许可证类型，当前可直接传 `pro`
- 第四个参数：可选，到期时间戳，毫秒

## 风险和现实约束

- Android 新版本通常拿不到真实 IMEI，序列号也常被限制，因此 App 端实现为“优先尝试 IMEI/Serial，失败回退到平台可用稳定标识”。
- 如果你准备面向换机续用，设备绑定会天然限制一机一激活；这不是 bug，而是方案选择。
- 当前代码里的 PEM 公钥占位符必须替换成真实公钥，否则运行时会报错，无法生成请求和验签。
