import 'package:equatable/equatable.dart';
import '../../../collection/domain/entities/repayment_receipt.dart';
import '../../domain/models/bluetooth_printer_device.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object?> get props => [];
}

class ScanPrintersRequested extends PrinterEvent {
  const ScanPrintersRequested();
}

class ConnectPrinterRequested extends PrinterEvent {
  final BluetoothPrinterDevice device;

  const ConnectPrinterRequested(this.device);

  @override
  List<Object?> get props => [device];
}

class DisconnectPrinterRequested extends PrinterEvent {
  const DisconnectPrinterRequested();
}

class PrintReceiptRequested extends PrinterEvent {
  final RepaymentReceipt receipt;

  const PrintReceiptRequested(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class PrintTestReceiptRequested extends PrinterEvent {
  const PrintTestReceiptRequested();
}
