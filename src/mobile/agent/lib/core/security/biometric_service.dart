import 'package:local_auth/local_auth.dart';
import '../utils/app_logger.dart';

/// Biometric Authentication Service (Fingerprint & FaceID) for Mobile Security.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  /// Check if the physical hardware supports biometric authentication.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final available = canCheck || isSupported;
      AppLogger.info('Checked biometric hardware availability: $available', tag: 'BiometricService');
      return available;
    } catch (e, stack) {
      AppLogger.error('Failed to check biometric availability: $e', tag: 'BiometricService', stackTrace: stack);
      return false;
    }
  }

  /// Get list of available biometrics (Fingerprint, FaceID, Iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.warn('Failed to retrieve available biometrics list: $e', tag: 'BiometricService');
      return const [];
    }
  }

  /// Trigger biometric authentication prompt.
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      AppLogger.info('Biometric authentication result: $authenticated', tag: 'BiometricService');
      return authenticated;
    } catch (e, stack) {
      AppLogger.error('Biometric authentication failed or was cancelled: $e', tag: 'BiometricService', stackTrace: stack);
      return false;
    }
  }

  /// Cancel ongoing authentication prompt.
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}
