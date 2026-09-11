import 'dart:io';
import 'package:bmf_agent_app/core/utils/app_logger.dart';

/// Represents security audit findings for mobile runtime environment.
class DeviceSecurityStatus {
  final bool isSecure;
  final bool isRootedOrJailbroken;
  final bool isFridaDetected;
  final List<String> threatDetails;

  const DeviceSecurityStatus({
    required this.isSecure,
    required this.isRootedOrJailbroken,
    required this.isFridaDetected,
    required this.threatDetails,
  });

  factory DeviceSecurityStatus.safe() {
    return const DeviceSecurityStatus(
      isSecure: true,
      isRootedOrJailbroken: false,
      isFridaDetected: false,
      threatDetails: [],
    );
  }
}

/// Service detecting root, jailbreak, and dynamic instrumentation hooks (Frida, Xposed).
class AntiTamperService {
  static const List<String> _knownRootBinaries = [
    '/system/bin/su',
    '/system/xbin/su',
    '/sbin/su',
    '/system/app/Superuser.apk',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/su',
    '/Applications/Cydia.app',
    '/Library/MobileSubstrate/MobileSubstrate.dylib',
    '/bin/bash',
    '/usr/sbin/sshd',
    '/etc/apt',
  ];

  static const List<String> _knownFridaArtifacts = [
    '/data/local/tmp/frida-server',
    '/data/local/tmp/re.frida.server',
  ];

  /// Performs offline environmental integrity audit.
  static Future<DeviceSecurityStatus> auditDeviceIntegrity() async {
    final threats = <String>[];
    bool rooted = false;
    bool frida = false;

    for (final path in _knownRootBinaries) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          rooted = true;
          threats.add('Root/Jailbreak artifact detected: $path');
        }
      } catch (_) {}
    }

    for (final path in _knownFridaArtifacts) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          frida = true;
          threats.add('Dynamic instrumentation hook artifact: $path');
        }
      } catch (_) {}
    }

    final isSafe = threats.isEmpty;
    if (!isSafe) {
      AppLogger.w('Security Alert! Root/Tampering detected: $threats', tag: 'AntiTamper');
    } else {
      AppLogger.i('Agent device runtime integrity verified. Safe.', tag: 'AntiTamper');
    }

    return DeviceSecurityStatus(
      isSecure: isSafe,
      isRootedOrJailbroken: rooted,
      isFridaDetected: frida,
      threatDetails: threats,
    );
  }

  /// Verifies safety and throws an exception if the device is compromised.
  static Future<void> assertEnvironmentSafe() async {
    final status = await auditDeviceIntegrity();
    if (!status.isSecure) {
      throw SecurityException(
        'Agent App execution prohibited on rooted/tampered devices: ${status.threatDetails.join("; ")}',
      );
    }
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
