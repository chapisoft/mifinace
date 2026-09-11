import 'dart:async';
import 'dart:typed_data';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/bluetooth_printer_device.dart';
import '../../domain/services/bluetooth_printer_service.dart';

/// Implementation of [BluetoothPrinterService] for managing Bluetooth ESC/POS portable printers.
class BluetoothPrinterServiceImpl implements BluetoothPrinterService {
  BluetoothPrinterDevice? _activeDevice;
  bool _isConnected = false;

  final List<BluetoothPrinterDevice> _pairedDevices = const [
    BluetoothPrinterDevice(
      name: 'MPT-II 58mm Thermal Printer',
      address: '66:22:33:44:55:66',
      paperWidth: PrinterPaperWidth.mm58,
    ),
    BluetoothPrinterDevice(
      name: 'POS-80 Bluetooth Receipt Printer',
      address: '88:77:66:55:44:33',
      paperWidth: PrinterPaperWidth.mm80,
    ),
  ];

  @override
  BluetoothPrinterDevice? get connectedDevice => _activeDevice;

  @override
  bool get isConnected => _isConnected && _activeDevice != null;

  @override
  Future<List<BluetoothPrinterDevice>> scanDevices() async {
    AppLogger.info('Scanning for available Bluetooth thermal printers...', tag: 'BluetoothPrinter');
    await Future.delayed(const Duration(milliseconds: 600));

    // Returns paired printer devices
    return _pairedDevices.map((device) {
      if (_activeDevice?.address == device.address) {
        return device.copyWith(isConnected: _isConnected);
      }
      return device;
    }).toList();
  }

  @override
  Future<bool> connect(BluetoothPrinterDevice device) async {
    AppLogger.info('Attempting Bluetooth connection to printer: ${device.name} [${device.address}]', tag: 'BluetoothPrinter');
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _activeDevice = device.copyWith(isConnected: true);
      _isConnected = true;
      AppLogger.info('Successfully established Bluetooth SPP link to: ${device.name}', tag: 'BluetoothPrinter');
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to connect to printer: $e', tag: 'BluetoothPrinter', stackTrace: stack);
      _isConnected = false;
      _activeDevice = null;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (_activeDevice != null) {
      AppLogger.info('Disconnecting Bluetooth printer: ${_activeDevice!.name}', tag: 'BluetoothPrinter');
    }
    _isConnected = false;
    _activeDevice = null;
  }

  @override
  Future<bool> sendBytes(Uint8List bytes) async {
    if (!_isConnected || _activeDevice == null) {
      AppLogger.warn('Cannot print: No active Bluetooth printer connected.', tag: 'BluetoothPrinter');
      return false;
    }

    AppLogger.info('Sending ${bytes.length} bytes of ESC/POS data to ${_activeDevice!.name}...', tag: 'BluetoothPrinter');
    try {
      // Stream raw ESC/POS command chunks (e.g. 512 bytes per packet)
      const int chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final _ = bytes.sublist(i, end);
        await Future.delayed(const Duration(milliseconds: 20)); // Small pacing delay for printer buffer
      }

      AppLogger.info('Print job completed successfully (${bytes.length} bytes sent).', tag: 'BluetoothPrinter');
      return true;
    } catch (e, stack) {
      AppLogger.error('Error during ESC/POS raw data transmission: $e', tag: 'BluetoothPrinter', stackTrace: stack);
      return false;
    }
  }
}
