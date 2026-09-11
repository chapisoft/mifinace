import 'dart:typed_data';
import '../models/bluetooth_printer_device.dart';

/// Service interface for Bluetooth Thermal Printer device scanning, connection, and raw data transmission.
abstract class BluetoothPrinterService {
  /// Scans for nearby or paired Bluetooth printers.
  Future<List<BluetoothPrinterDevice>> scanDevices();

  /// Connects to a specific printer by its hardware MAC address or UUID.
  Future<bool> connect(BluetoothPrinterDevice device);

  /// Disconnects from the current active printer.
  Future<void> disconnect();

  /// Returns the current active connected printer or null if disconnected.
  BluetoothPrinterDevice? get connectedDevice;

  /// Returns true if currently connected to a printer.
  bool get isConnected;

  /// Sends raw ESC/POS bytes to the connected printer.
  Future<bool> sendBytes(Uint8List bytes);
}
