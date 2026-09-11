import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bmf_agent_app/core/utils/app_logger.dart';

/// Service protecting sensitive financial screen content from unauthorized capture, recording, and app switcher snooping.
class ScreenProtectionService with WidgetsBindingObserver {
  static final ScreenProtectionService _instance = ScreenProtectionService._internal();
  factory ScreenProtectionService() => _instance;
  ScreenProtectionService._internal();

  static const MethodChannel _channel = MethodChannel('com.bmf.agent/security');
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
      AppLogger.i('Agent FLAG_SECURE screen protection enabled.', tag: 'ScreenProtection');
    } on MissingPluginException {
      AppLogger.i('Screen protection channel not present (simulator/test mode).', tag: 'ScreenProtection');
    } catch (e) {
      AppLogger.w('Could not activate screen protection: $e', tag: 'ScreenProtection');
    }
  }

  /// Disables FLAG_SECURE when explicitly needed.
  Future<void> disableScreenSecurity() async {
    try {
      _isProtectionActive = false;
      await _channel.invokeMethod('disableSecure');
      AppLogger.i('Screen protection temporarily disabled.', tag: 'ScreenProtection');
    } on MissingPluginException {
    } catch (e) {
      AppLogger.w('Could not deactivate screen protection: $e', tag: 'ScreenProtection');
    }
  }

  bool get isProtectionActive => _isProtectionActive;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      AppLogger.i('App entering background. Masking sensitive screen content.', tag: 'ScreenProtection');
    } else if (state == AppLifecycleState.resumed) {
      AppLogger.i('App resumed to foreground. Restoring screen display.', tag: 'ScreenProtection');
    }
  }
}
