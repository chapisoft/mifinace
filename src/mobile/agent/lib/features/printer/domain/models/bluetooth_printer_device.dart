import 'package:equatable/equatable.dart';

/// Paper width supported by portable Bluetooth thermal printers.
enum PrinterPaperWidth {
  mm58(dotsPerLine: 384, name: '58mm (384 dots)'),
  mm80(dotsPerLine: 576, name: '80mm (576 dots)');

  final int dotsPerLine;
  final String name;

  const PrinterPaperWidth({
    required this.dotsPerLine,
    required this.name,
  });
}

/// Status of the Bluetooth printer connection.
enum PrinterConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Entity representing a Bluetooth Thermal Printer device.
class BluetoothPrinterDevice extends Equatable {
  final String name;
  final String address;
  final bool isConnected;
  final PrinterPaperWidth paperWidth;

  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.paperWidth = PrinterPaperWidth.mm58,
  });

  BluetoothPrinterDevice copyWith({
    String? name,
    String? address,
    bool? isConnected,
    PrinterPaperWidth? paperWidth,
  }) {
    return BluetoothPrinterDevice(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      paperWidth: paperWidth ?? this.paperWidth,
    );
  }

  @override
  List<Object?> get props => [name, address, isConnected, paperWidth];
}
