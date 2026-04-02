import Flutter
import UIKit
import Security
import CryptoKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let licenseChannelName = "com.meetlog.meetlog/license"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let channel = FlutterMethodChannel(name: licenseChannelName, binaryMessenger: messenger)
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(FlutterError(code: "license_error", message: "AppDelegate 已释放", details: nil))
          return
        }
        do {
          switch call.method {
          case "getDeviceIdentity":
            result(self.getDeviceIdentity())
          case "buildActivationRequest":
            guard
              let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String,
              let publicKeyPem = args["publicKeyPem"] as? String
            else {
              result(FlutterError(code: "invalid_args", message: "缺少激活请求参数", details: nil))
              return
            }
            result(try self.buildActivationRequest(appId: appId, publicKeyPem: publicKeyPem))
          case "verifyLicense":
            guard
              let args = call.arguments as? [String: Any],
              let license = args["license"] as? String,
              let appId = args["appId"] as? String,
              let publicKeyPem = args["publicKeyPem"] as? String
            else {
              result(FlutterError(code: "invalid_args", message: "缺少许可证校验参数", details: nil))
              return
            }
            result(self.verifyLicense(license: license, appId: appId, publicKeyPem: publicKeyPem))
          default:
            result(FlutterMethodNotImplemented)
          }
        } catch {
          result(FlutterError(code: "license_error", message: error.localizedDescription, details: nil))
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func getDeviceIdentity() -> [String: Any] {
    let raw = resolveRawDeviceId()
    return [
      "deviceIdType": raw.type,
      "maskedDeviceId": maskValue(raw.value),
      "deviceFingerprint": sha256Hex("meetlog.pro|\(raw.type)|\(raw.value)"),
    ]
  }

  private func buildActivationRequest(appId: String, publicKeyPem: String) throws -> String {
    let raw = resolveRawDeviceId()
    let payload: [String: Any] = [
      "a": appId,
      "d": raw.value,
      "t": raw.type,
      "i": Int(Date().timeIntervalSince1970 * 1000),
    ]
    let data = try JSONSerialization.data(withJSONObject: payload, options: [])
    let encrypted = try rsaEncrypt(data: data, publicKeyPem: publicKeyPem)
    return encrypted.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  private func verifyLicense(
    license: String,
    appId: String,
    publicKeyPem: String
  ) -> [String: Any] {
    let parts = license.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")
    guard parts.count == 2 else {
      return invalidLicense("激活码格式错误")
    }
    guard
      let payloadData = decodeBase64Url(String(parts[0])),
      let signatureData = decodeBase64Url(String(parts[1]))
    else {
      return invalidLicense("激活码编码无效")
    }
    guard rsaVerify(payload: payloadData, signature: signatureData, publicKeyPem: publicKeyPem) else {
      return invalidLicense("签名校验失败")
    }
    guard
      let object = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
    else {
      return invalidLicense("激活码载荷无效")
    }
    guard (object["a"] as? String) == appId else {
      return invalidLicense("激活码不属于当前应用")
    }

    let raw = resolveRawDeviceId()
    let expectedFingerprint = sha256Hex("\(appId)|\(raw.type)|\(raw.value)")
    guard (object["f"] as? String) == expectedFingerprint else {
      return invalidLicense("激活码与当前设备不匹配")
    }

    if let expiresAt = object["e"] as? Double,
       expiresAt > 0,
       Date().timeIntervalSince1970 * 1000 > expiresAt {
      return invalidLicense("激活码已过期")
    }

    return [
      "valid": true,
      "reason": "ok",
      "payload": object,
    ]
  }

  private func invalidLicense(_ reason: String) -> [String: Any] {
    [
      "valid": false,
      "reason": reason,
      "payload": NSNull(),
    ]
  }

  private func resolveRawDeviceId() -> (type: String, value: String) {
    if let identifier = UIDevice.current.identifierForVendor?.uuidString, !identifier.isEmpty {
      return ("identifier_for_vendor", identifier)
    }
    return ("device_name", UIDevice.current.name)
  }

  private func maskValue(_ value: String) -> String {
    guard value.count > 8 else {
      return value
    }
    let start = value.prefix(4)
    let end = value.suffix(4)
    return "\(start)****\(end)"
  }

  private func decodeBase64Url(_ value: String) -> Data? {
    var base64 = value
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let padding = 4 - (base64.count % 4)
    if padding < 4 {
      base64 += String(repeating: "=", count: padding)
    }
    return Data(base64Encoded: base64)
  }

  private func rsaEncrypt(data: Data, publicKeyPem: String) throws -> Data {
    let key = try createSecKey(from: publicKeyPem)
    var error: Unmanaged<CFError>?
    guard let encrypted = SecKeyCreateEncryptedData(
      key,
      .rsaEncryptionOAEPSHA256,
      data as CFData,
      &error
    ) as Data? else {
      throw error!.takeRetainedValue() as Error
    }
    return encrypted
  }

  private func rsaVerify(payload: Data, signature: Data, publicKeyPem: String) -> Bool {
    guard let key = try? createSecKey(from: publicKeyPem) else {
      return false
    }
    var error: Unmanaged<CFError>?
    let ok = SecKeyVerifySignature(
      key,
      .rsaSignatureMessagePKCS1v15SHA256,
      payload as CFData,
      signature as CFData,
      &error
    )
    return ok
  }

  private func createSecKey(from pem: String) throws -> SecKey {
    if pem.contains("REPLACE_WITH_") {
      throw NSError(
        domain: "license",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "尚未配置 RSA 公钥，请先替换应用内的 PEM 常量"]
      )
    }
    let sanitized = pem
      .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
      .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
      .components(separatedBy: .whitespacesAndNewlines)
      .joined()
    guard let data = Data(base64Encoded: sanitized) else {
      throw NSError(domain: "license", code: -1, userInfo: [NSLocalizedDescriptionKey: "公钥格式无效"])
    }

    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
      kSecAttrKeySizeInBits as String: 2048,
    ]

    var error: Unmanaged<CFError>?
    guard let key = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return key
  }

  private func sha256Hex(_ input: String) -> String {
    let data = Data(input.utf8)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
  }
}
