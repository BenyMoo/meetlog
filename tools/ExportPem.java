import java.io.FileInputStream;
import java.security.Key;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.util.Base64;

public class ExportPem {
  public static void main(String[] args) throws Exception {
    if (args.length != 5) {
      throw new IllegalArgumentException("usage: ExportPem <keystore> <storePass> <alias> <keyPass> <public|private>");
    }

    String keystorePath = args[0];
    char[] storePass = args[1].toCharArray();
    String alias = args[2];
    char[] keyPass = args[3].toCharArray();
    String mode = args[4];

    KeyStore keyStore = KeyStore.getInstance("PKCS12");
    try (FileInputStream input = new FileInputStream(keystorePath)) {
      keyStore.load(input, storePass);
    }

    byte[] encoded;
    String begin;
    String end;

    if ("public".equals(mode)) {
      Certificate certificate = keyStore.getCertificate(alias);
      if (certificate == null) {
        throw new IllegalArgumentException("certificate not found for alias: " + alias);
      }
      encoded = certificate.getPublicKey().getEncoded();
      begin = "-----BEGIN PUBLIC KEY-----";
      end = "-----END PUBLIC KEY-----";
    } else if ("private".equals(mode)) {
      Key key = keyStore.getKey(alias, keyPass);
      if (key == null) {
        throw new IllegalArgumentException("private key not found for alias: " + alias);
      }
      encoded = key.getEncoded();
      begin = "-----BEGIN PRIVATE KEY-----";
      end = "-----END PRIVATE KEY-----";
    } else {
      throw new IllegalArgumentException("mode must be public or private");
    }

    String base64 = Base64.getMimeEncoder(64, "\n".getBytes()).encodeToString(encoded);
    System.out.println(begin);
    System.out.println(base64);
    System.out.println(end);
  }
}
