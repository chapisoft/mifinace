import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bmf_agent_app/core/utils/app_logger.dart';

/// SSL Certificate Fingerprint Configuration for BMF Gateway.
class CertConfig {
  CertConfig._();

  /// Primary Gateway SHA-256 Certificate Fingerprint (Hex uppercase, without colons).
  static const String primaryFingerprint =
      '4B7C9D1E8F2A3B4C5D6E7F8091A2B3C4D5E6F708192A3B4C5D6E7F8091A2B3C4';

  /// Backup Gateway SHA-256 Fingerprint for certificate rollover.
  static const String backupFingerprint =
      'A1B2C3D4E5F60718293A4B5C6D7E8F90A1B2C3D4E5F60718293A4B5C6D7E8F90';

  static final Set<String> trustedFingerprints = {
    primaryFingerprint.toUpperCase().replaceAll(':', ''),
    backupFingerprint.toUpperCase().replaceAll(':', ''),
  };
}

/// Factory utility configuring strict SSL Certificate Pinning on Dio HTTP Client.
class SslPinningClient {
  SslPinningClient._();

  /// Validates a raw X509 certificate against the configured SHA-256 fingerprints.
  static bool validateCertificate(X509Certificate cert) {
    try {
      final certDer = cert.der;
      final sha256Digest = sha256.convert(certDer);
      final hashHex = sha256Digest.toString().toUpperCase();

      final isTrusted = CertConfig.trustedFingerprints.contains(hashHex);
      if (isTrusted) {
        AppLogger.i('SSL certificate fingerprint matched: $hashHex', tag: 'SslPinning');
        return true;
      } else {
        AppLogger.e(
          'SSL Pinning Mismatch! Expected one of ${CertConfig.trustedFingerprints}, but received $hashHex',
          tag: 'SslPinning',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.e('Failed to validate certificate: $e', tag: 'SslPinning', stackTrace: stack);
      return false;
    }
  }

  /// Applies strict certificate pinning security to a given [Dio] instance.
  static void applyCertificatePinning(Dio dio) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(context: SecurityContext(withTrustedRoots: true));
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return validateCertificate(cert);
        };
        return client;
      },
      validateCertificate: (cert, host, port) {
        if (cert == null) return false;
        return validateCertificate(cert);
      },
    );
    AppLogger.i('Strict SSL Pinning applied to Agent Dio HTTP Client.', tag: 'SslPinning');
  }
}
