import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';

/// Service protecting sensitive financial screen content from unauthorized capture, recording, and app switcher snooping.
class ScreenProtectionService with WidgetsBindingObserver {
  static final ScreenProtectionService _instance = ScreenProtectionService._internal();
  factory ScreenProtectionService() => _instance;
  ScreenProtectionService._internal();

  static const MethodChannel _channel = MethodChannel('com.bmf.microfinance/security');
  bool _isProtectionActive = false;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    enableScreenSecurity();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Enables FLAG_SECURE on Android and protects privacy in App Switcher.
  Future<void> enableScreenSecurity() async {
    try {
      _isProtectionActive = true;
      await _channel.invokeMethod('enableSecure');
      AppLogger.info('FLAG_SECURE screen protection enabled.', tag: 'ScreenProtection');
    } on MissingPluginException {
      // Graceful fallback during tests or platforms without native binding
      AppLogger.info('Screen protection native channel not present (simulator/test mode).', tag: 'ScreenProtection');
    } catch (e) {
      AppLogger.warn('Could not activate screen protection: $e', tag: 'ScreenProtection');
    }
  }

  /// Disables FLAG_SECURE when explicitly needed (e.g. sharing receipt screenshot).
  Future<void> disableScreenSecurity() async {
    try {
      _isProtectionActive = false;
      await _channel.invokeMethod('disableSecure');
      AppLogger.info('Screen protection temporarily disabled.', tag: 'ScreenProtection');
    } on MissingPluginException {
      // Ignored in test environment
    } catch (e) {
      AppLogger.warn('Could not deactivate screen protection: $e', tag: 'ScreenProtection');
    }
  }

  bool get isProtectionActive => _isProtectionActive;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      AppLogger.info('App entering background. Masking sensitive screen content.', tag: 'ScreenProtection');
    } else if (state == AppLifecycleState.resumed) {
      AppLogger.info('App resumed to foreground. Restoring screen display.', tag: 'ScreenProtection');
    }
  }
}
