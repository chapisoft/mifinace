import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_agent_app/core/security/anti_tamper_service.dart';
import 'package:bmf_agent_app/core/security/screen_protection_service.dart';
import 'package:bmf_agent_app/core/security/ssl_pinning_client.dart';

class MockX509Certificate extends Mock implements X509Certificate {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Agent Mobile Security & Hardening Tests (TASK-SEC-01)', () {
    test('CertConfig trusted fingerprints must be valid 64-char uppercase SHA-256 hex strings', () {
      for (final fp in CertConfig.trustedFingerprints) {
        expect(fp.length, 64);
        expect(RegExp(r'^[0-9A-F]{64}$').hasMatch(fp), isTrue);
      }
    });

    test('SslPinningClient validates trusted certificate der bytes matching fingerprint', () {
      final mockCert = MockX509Certificate();

      final certBytes = Uint8List.fromList([10, 20, 30, 40, 50]);
      final actualHash = sha256.convert(certBytes).toString().toUpperCase();

      CertConfig.trustedFingerprints.add(actualHash);

      when(() => mockCert.der).thenReturn(certBytes);

      final isValid = SslPinningClient.validateCertificate(mockCert);
      expect(isValid, isTrue);

      CertConfig.trustedFingerprints.remove(actualHash);
    });

    test('SslPinningClient rejects untrusted rogue/proxy certificate (Burp / Charles Proxy)', () {
      final mockRogueCert = MockX509Certificate();
      when(() => mockRogueCert.der).thenReturn(Uint8List.fromList([1, 1, 1, 1]));

      final isValid = SslPinningClient.validateCertificate(mockRogueCert);
      expect(isValid, isFalse);
    });

    test('AntiTamperService audits environment and returns DeviceSecurityStatus', () async {
      final status = await AntiTamperService.auditDeviceIntegrity();
      expect(status, isA<DeviceSecurityStatus>());
      expect(status.threatDetails, isA<List<String>>());
    });

    test('ScreenProtectionService toggles security state and handles lifecycle events', () async {
      final protectionService = ScreenProtectionService();
      expect(protectionService.isProtectionActive, isFalse);

      await protectionService.enableScreenSecurity();
      expect(protectionService.isProtectionActive, isTrue);

      await protectionService.disableScreenSecurity();
      expect(protectionService.isProtectionActive, isFalse);
    });
  });
}
