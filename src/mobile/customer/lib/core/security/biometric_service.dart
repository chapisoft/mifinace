import 'package:local_auth/local_auth.dart';
import '../utils/app_logger.dart';

/// Biometric Authentication Service supporting Fingerprint and Face Unlock on Android & iOS.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      AppLogger.warn('Failed to check biometric hardware: $e', tag: 'BiometricService');
      return false;
    }
  }

  Future<bool> authenticate({String localizedReason = 'Authenticate to access your BMF account'}) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      AppLogger.info('Biometric authentication result: $authenticated', tag: 'BiometricService');
      return authenticated;
    } catch (e) {
      AppLogger.error('Biometric authentication failed: $e', tag: 'BiometricService');
      return false;
    }
  }
}
