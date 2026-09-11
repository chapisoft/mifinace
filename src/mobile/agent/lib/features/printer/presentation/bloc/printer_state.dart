import 'package:equatable/equatable.dart';
import '../../domain/models/bluetooth_printer_device.dart';

abstract class PrinterState extends Equatable {
  final List<BluetoothPrinterDevice> availableDevices;
  final BluetoothPrinterDevice? connectedDevice;

  const PrinterState({
    this.availableDevices = const [],
    this.connectedDevice,
  });

  @override
  List<Object?> get props => [availableDevices, connectedDevice];
}

class PrinterInitial extends PrinterState {
  const PrinterInitial() : super();
}

class PrinterScanning extends PrinterState {
  const PrinterScanning({
    super.availableDevices,
    super.connectedDevice,
  });
}

class PrinterConnecting extends PrinterState {
  final BluetoothPrinterDevice targetDevice;

  const PrinterConnecting({
    required this.targetDevice,
    super.availableDevices,
    super.connectedDevice,
  });

  @override
  List<Object?> get props => [targetDevice, availableDevices, connectedDevice];
}

class PrinterConnected extends PrinterState {
  const PrinterConnected({
    required BluetoothPrinterDevice connectedDevice,
    super.availableDevices,
  }) : super(connectedDevice: connectedDevice);
}

class PrinterDisconnected extends PrinterState {
  const PrinterDisconnected({
    super.availableDevices,
  }) : super(connectedDevice: null);
}

class PrinterPrinting extends PrinterState {
  const PrinterPrinting({
    super.availableDevices,
    super.connectedDevice,
  });
}

class PrintSuccess extends PrinterState {
  final String message;

  const PrintSuccess({
    required this.message,
    super.availableDevices,
    super.connectedDevice,
  });

  @override
  List<Object?> get props => [message, availableDevices, connectedDevice];
}

class PrinterError extends PrinterState {
  final String message;

  const PrinterError({
    required this.message,
    super.availableDevices,
    super.connectedDevice,
  });

  @override
  List<Object?> get props => [message, availableDevices, connectedDevice];
}
