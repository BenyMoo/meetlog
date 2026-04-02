import java.io.FileInputStream;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.Signature;
import java.util.Base64;
import javax.crypto.Cipher;

public class IssueLicense {
  public static void main(String[] args) throws Exception {
    if (args.length < 3 || args.length > 4) {
      throw new IllegalArgumentException(
          "usage: IssueLicense <requestCiphertext> <orderNo> <licenseType> [expiresAtMillis]");
    }

    String requestCiphertext = args[0];
    String orderNo = args[1];
    String licenseType = args[2];
    String expiresAt = args.length == 4 ? args[3] : null;

    String requestJson =
        decryptRequest(
            ".devkeys/request_keystore.p12",
            "meetlog123",
            "request",
            "meetlog123",
            requestCiphertext);

    String appId = jsonValue(requestJson, "a");
    String deviceId = jsonValue(requestJson, "d");
    String deviceType = jsonValue(requestJson, "t");
    String fingerprint = sha256Hex(appId + "|" + deviceType + "|" + deviceId);
    long issuedAt = System.currentTimeMillis();

    String payload =
        "{"
            + "\"a\":\""
            + escape(appId)
            + "\","
            + "\"f\":\""
            + fingerprint
            + "\","
            + "\"l\":\""
            + escape(licenseType)
            + "\","
            + "\"n\":\""
            + escape(orderNo)
            + "\","
            + "\"i\":"
            + issuedAt
            + (expiresAt != null ? ",\"e\":" + expiresAt : "")
            + "}";

    byte[] signature =
        signPayload(".devkeys/license_keystore.p12", "meetlog123", "license", "meetlog123", payload);

    String token =
        base64Url(payload.getBytes(StandardCharsets.UTF_8))
            + "."
            + base64Url(signature);

    System.out.println(token);
  }

  private static String decryptRequest(
      String keystorePath,
      String storePass,
      String alias,
      String keyPass,
      String ciphertext)
      throws Exception {
    PrivateKey privateKey = loadPrivateKey(keystorePath, storePass, alias, keyPass);
    Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
    cipher.init(Cipher.DECRYPT_MODE, privateKey);
    byte[] encrypted = Base64.getUrlDecoder().decode(normalizeBase64Url(ciphertext));
    byte[] plain = cipher.doFinal(encrypted);
    return new String(plain, StandardCharsets.UTF_8);
  }

  private static byte[] signPayload(
      String keystorePath,
      String storePass,
      String alias,
      String keyPass,
      String payload)
      throws Exception {
    PrivateKey privateKey = loadPrivateKey(keystorePath, storePass, alias, keyPass);
    Signature signature = Signature.getInstance("SHA256withRSA");
    signature.initSign(privateKey);
    signature.update(payload.getBytes(StandardCharsets.UTF_8));
    return signature.sign();
  }

  private static PrivateKey loadPrivateKey(
      String keystorePath,
      String storePass,
      String alias,
      String keyPass)
      throws Exception {
    KeyStore keyStore = KeyStore.getInstance("PKCS12");
    try (FileInputStream input = new FileInputStream(keystorePath)) {
      keyStore.load(input, storePass.toCharArray());
    }
    Key key = keyStore.getKey(alias, keyPass.toCharArray());
    if (!(key instanceof PrivateKey)) {
      throw new IllegalStateException("private key not found: " + alias);
    }
    return (PrivateKey) key;
  }

  private static String jsonValue(String json, String key) {
    String pattern = "\"" + key + "\":\"";
    int start = json.indexOf(pattern);
    if (start < 0) {
      throw new IllegalArgumentException("missing key: " + key);
    }
    start += pattern.length();
    int end = json.indexOf('"', start);
    if (end < 0) {
      throw new IllegalArgumentException("invalid json for key: " + key);
    }
    return json.substring(start, end);
  }

  private static String sha256Hex(String input) throws Exception {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");
    byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
    StringBuilder builder = new StringBuilder();
    for (byte b : hash) {
      builder.append(String.format("%02x", b));
    }
    return builder.toString();
  }

  private static String base64Url(byte[] data) {
    return Base64.getUrlEncoder().withoutPadding().encodeToString(data);
  }

  private static byte[] normalizeBase64Url(String value) {
    int mod = value.length() % 4;
    if (mod == 2) {
      value += "==";
    } else if (mod == 3) {
      value += "=";
    }
    return value.getBytes(StandardCharsets.UTF_8);
  }

  private static String escape(String value) {
    return value.replace("\\", "\\\\").replace("\"", "\\\"");
  }
}
