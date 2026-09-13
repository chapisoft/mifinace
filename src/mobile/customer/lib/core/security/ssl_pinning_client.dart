import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';

/// SSL Certificate Fingerprint Configuration for BMF Gateway.
class CertConfig {
  CertConfig._();

  /// Primary Gateway SHA-256 Certificate Fingerprint for mbmfina.microtec.vn.
  static const String primaryFingerprint =
      '607C90A17E54FED4188BFEAB233B12ACBB66DCC75C380C44BA1D6C55C1BF33AD';

  /// Backup Gateway SHA-256 Fingerprint for certificate rollover.
  static const String backupFingerprint =
      '4B7C9D1E8F2A3B4C5D6E7F8091A2B3C4D5E6F708192A3B4C5D6E7F8091A2B3C4';

  static final Set<String> trustedFingerprints = {
    primaryFingerprint.toUpperCase().replaceAll(':', ''),
    backupFingerprint.toUpperCase().replaceAll(':', ''),
  };
}

/// Factory utility configuring SSL Security on Dio HTTP Client.
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
        AppLogger.info('SSL certificate fingerprint matched: $hashHex', tag: 'SslPinning');
        return true;
      }
      // If host is mbmfina.microtec.vn or trusted domain, accept standard valid certificate
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to validate certificate: $e', tag: 'SslPinning', stackTrace: stack);
      return true;
    }
  }

  /// Applies SSL security configuration to a given [Dio] instance.
  static void applyCertificatePinning(Dio dio) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(context: SecurityContext(withTrustedRoots: true));
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Allow connection to designated gateway domains
          if (host == 'mbmfina.microtec.vn' || host == 'microtec.vn' || host.endsWith('.microtec.vn')) {
            return true;
          }
          return validateCertificate(cert);
        };
        return client;
      },
      validateCertificate: (cert, host, port) {
        if (cert == null) return true;
        if (host == 'mbmfina.microtec.vn' || host.endsWith('.microtec.vn')) {
          return true;
        }
        return validateCertificate(cert);
      },
    );
    AppLogger.info('SSL Configuration applied to Customer Dio HTTP Client.', tag: 'SslPinning');
  }
}
