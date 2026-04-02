package com.meetlog.meetlog

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.telephony.TelephonyManager
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.security.KeyFactory
import java.security.MessageDigest
import java.security.PublicKey
import java.security.Signature
import java.security.spec.MGF1ParameterSpec
import java.security.spec.PSSParameterSpec
import java.security.spec.X509EncodedKeySpec
import java.util.Base64
import javax.crypto.Cipher
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val channelName = "com.meetlog.meetlog/license"
    private val externalLinkChannelName = "com.meetlog.meetlog/external_link"

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getDeviceIdentity" -> {
                        result.success(getDeviceIdentity())
                    }

                    "buildActivationRequest" -> {
                        val appId = call.argument<String>("appId")
                        val publicKeyPem = call.argument<String>("publicKeyPem")
                        if (appId.isNullOrBlank() || publicKeyPem.isNullOrBlank()) {
                            result.error("invalid_args", "缺少激活请求参数", null)
                            return@setMethodCallHandler
                        }
                        result.success(buildActivationRequest(appId, publicKeyPem))
                    }

                    "verifyLicense" -> {
                        val license = call.argument<String>("license")
                        val appId = call.argument<String>("appId")
                        val publicKeyPem = call.argument<String>("publicKeyPem")
                        if (license.isNullOrBlank() || appId.isNullOrBlank() || publicKeyPem.isNullOrBlank()) {
                            result.error("invalid_args", "缺少许可证校验参数", null)
                            return@setMethodCallHandler
                        }
                        result.success(verifyLicense(license, appId, publicKeyPem))
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("license_error", e.message, null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            externalLinkChannelName,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "openExternalUrl" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrBlank()) {
                            result.error("invalid_args", "缺少下载链接", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("external_link_error", e.message, null)
            }
        }
    }

    private fun getDeviceIdentity(): Map<String, String> {
        val rawIdentity = resolveRawDeviceId()
        return mapOf(
            "deviceIdType" to rawIdentity.first,
            "maskedDeviceId" to maskValue(rawIdentity.second),
            "deviceFingerprint" to fingerprintFor("meetlog.pro", rawIdentity.first, rawIdentity.second),
        )
    }

    private fun buildActivationRequest(appId: String, publicKeyPem: String): String {
        val rawIdentity = resolveRawDeviceId()
        val payload = JSONObject(
            mapOf(
                "a" to appId,
                "d" to rawIdentity.second,
                "t" to rawIdentity.first,
                "i" to System.currentTimeMillis(),
            ),
        ).toString()

        val encrypted = rsaEncrypt(payload.toByteArray(Charsets.UTF_8), publicKeyPem)
        return Base64.getUrlEncoder().withoutPadding().encodeToString(encrypted)
    }

    private fun verifyLicense(
        license: String,
        appId: String,
        publicKeyPem: String,
    ): Map<String, Any?> {
        val parts = license.trim().split(".")
        if (parts.size != 2) {
            return invalidLicense("激活码格式错误")
        }

        val payloadBytes = decodeUrlBase64(parts[0]) ?: return invalidLicense("激活码载荷无效")
        val signatureBytes = decodeUrlBase64(parts[1]) ?: return invalidLicense("激活码签名无效")
        val verified = rsaVerify(payloadBytes, signatureBytes, publicKeyPem)
        if (!verified) {
            return invalidLicense("签名校验失败")
        }

        val payloadJson = JSONObject(String(payloadBytes, Charsets.UTF_8))
        val payloadAppId = payloadJson.optString("a")
        if (payloadAppId != appId) {
            return invalidLicense("激活码不属于当前应用")
        }

        val expectedFingerprint = payloadJson.optString("f")
        if (expectedFingerprint.isBlank()) {
            return invalidLicense("激活码缺少设备指纹")
        }

        val rawIdentity = resolveRawDeviceId()
        val currentFingerprint = fingerprintFor(appId, rawIdentity.first, rawIdentity.second)
        if (expectedFingerprint != currentFingerprint) {
            return invalidLicense("激活码与当前设备不匹配")
        }

        if (payloadJson.has("e") && !payloadJson.isNull("e")) {
            val expiresAt = payloadJson.optLong("e")
            if (expiresAt > 0 && System.currentTimeMillis() > expiresAt) {
                return invalidLicense("激活码已过期")
            }
        }

        return mapOf(
            "valid" to true,
            "reason" to "ok",
            "payload" to payloadJson.toMap(),
        )
    }

    private fun invalidLicense(reason: String): Map<String, Any?> {
        return mapOf(
            "valid" to false,
            "reason" to reason,
            "payload" to null,
        )
    }

    @SuppressLint("HardwareIds")
    private fun resolveRawDeviceId(): Pair<String, String> {
        val imei = tryReadImei()
        if (!imei.isNullOrBlank()) {
            return "imei" to imei
        }

        val serial = tryReadSerial()
        if (!serial.isNullOrBlank()) {
            return "serial" to serial
        }

        val androidId = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ANDROID_ID,
        )
        if (!androidId.isNullOrBlank()) {
            return "android_id" to androidId
        }

        return "build_fingerprint" to (Build.FINGERPRINT ?: Build.ID ?: "unknown_device")
    }

    @SuppressLint("HardwareIds", "MissingPermission")
    private fun tryReadImei(): String? {
        return try {
            val telephonyManager = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
            when {
                telephonyManager == null -> null
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> telephonyManager.imei
                else -> telephonyManager.deviceId
            }
        } catch (_: Exception) {
            null
        }
    }

    @SuppressLint("HardwareIds")
    private fun tryReadSerial(): String? {
        return try {
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                    val serial = Build.getSerial()
                    if (serial == Build.UNKNOWN) null else serial
                }

                else -> {
                    val serial = Build.SERIAL
                    if (serial == Build.UNKNOWN) null else serial
                }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun fingerprintFor(appId: String, type: String, rawValue: String): String {
        return sha256Hex("$appId|$type|$rawValue")
    }

    private fun sha256Hex(input: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        return digest.digest(input.toByteArray(Charsets.UTF_8)).joinToString("") {
            "%02x".format(it)
        }
    }

    private fun maskValue(value: String): String {
        if (value.length <= 8) {
            return value
        }
        return "${value.take(4)}****${value.takeLast(4)}"
    }

    private fun parseRsaPublicKey(publicKeyPem: String): PublicKey {
        if (publicKeyPem.contains("REPLACE_WITH_")) {
            throw IllegalArgumentException("尚未配置 RSA 公钥，请先替换应用内的 PEM 常量")
        }
        val sanitized = publicKeyPem
            .replace("-----BEGIN PUBLIC KEY-----", "")
            .replace("-----END PUBLIC KEY-----", "")
            .replace("\\s".toRegex(), "")
        val keyBytes = Base64.getDecoder().decode(sanitized)
        val spec = X509EncodedKeySpec(keyBytes)
        return KeyFactory.getInstance("RSA").generatePublic(spec)
    }

    private fun rsaEncrypt(content: ByteArray, publicKeyPem: String): ByteArray {
        val cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding")
        cipher.init(Cipher.ENCRYPT_MODE, parseRsaPublicKey(publicKeyPem))
        return cipher.doFinal(content)
    }

    private fun rsaVerify(
        payloadBytes: ByteArray,
        signatureBytes: ByteArray,
        publicKeyPem: String,
    ): Boolean {
        val publicKey = parseRsaPublicKey(publicKeyPem)

        val pkcs1 = try {
            val signature = Signature.getInstance("SHA256withRSA")
            signature.initVerify(publicKey)
            signature.update(payloadBytes)
            signature.verify(signatureBytes)
        } catch (_: Exception) {
            false
        }
        if (pkcs1) {
            return true
        }

        return try {
            val signature = Signature.getInstance("RSASSA-PSS")
            signature.setParameter(
                PSSParameterSpec(
                    "SHA-256",
                    "MGF1",
                    MGF1ParameterSpec.SHA256,
                    32,
                    1,
                ),
            )
            signature.initVerify(publicKey)
            signature.update(payloadBytes)
            signature.verify(signatureBytes)
        } catch (_: Exception) {
            false
        }
    }

    private fun decodeUrlBase64(value: String): ByteArray? {
        return try {
            val normalized = when (value.length % 4) {
                2 -> "$value=="
                3 -> "$value="
                else -> value
            }
            Base64.getUrlDecoder().decode(normalized)
        } catch (_: Exception) {
            null
        }
    }

    private fun JSONObject.toMap(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        val iterator = keys()
        while (iterator.hasNext()) {
            val key = iterator.next()
            result[key] = if (isNull(key)) null else get(key)
        }
        return result
    }
}
