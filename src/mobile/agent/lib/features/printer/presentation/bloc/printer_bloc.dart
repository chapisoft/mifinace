import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/repayment_method.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../collection/domain/entities/repayment_receipt.dart';
import '../../domain/services/bluetooth_printer_service.dart';
import '../../domain/services/receipt_renderer.dart';
import 'printer_event.dart';
import 'printer_state.dart';

/// Bloc managing Bluetooth Thermal Printer discovery, connection, and Myanmar receipt rendering & printing.
class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final BluetoothPrinterService _printerService;

  PrinterBloc({required BluetoothPrinterService printerService})
      : _printerService = printerService,
        super(const PrinterInitial()) {
    on<ScanPrintersRequested>(_onScanPrinters);
    on<ConnectPrinterRequested>(_onConnectPrinter);
    on<DisconnectPrinterRequested>(_onDisconnectPrinter);
    on<PrintReceiptRequested>(_onPrintReceipt);
    on<PrintTestReceiptRequested>(_onPrintTestReceipt);
  }

  Future<void> _onScanPrinters(ScanPrintersRequested event, Emitter<PrinterState> emit) async {
    emit(PrinterScanning(
      availableDevices: state.availableDevices,
      connectedDevice: state.connectedDevice,
    ));
    try {
      final devices = await _printerService.scanDevices();
      AppLogger.info('Discovered ${devices.length} Bluetooth printers', tag: 'PrinterBloc');
      if (_printerService.isConnected && _printerService.connectedDevice != null) {
        emit(PrinterConnected(
          connectedDevice: _printerService.connectedDevice!,
          availableDevices: devices,
        ));
      } else {
        emit(PrinterDisconnected(availableDevices: devices));
      }
    } catch (e, stack) {
      AppLogger.error('Failed to scan for Bluetooth printers: $e', tag: 'PrinterBloc', stackTrace: stack);
      emit(PrinterError(
        message: e.toString(),
        availableDevices: state.availableDevices,
        connectedDevice: state.connectedDevice,
      ));
    }
  }

  Future<void> _onConnectPrinter(ConnectPrinterRequested event, Emitter<PrinterState> emit) async {
    emit(PrinterConnecting(
      targetDevice: event.device,
      availableDevices: state.availableDevices,
      connectedDevice: state.connectedDevice,
    ));
    try {
      final success = await _printerService.connect(event.device);
      if (success && _printerService.connectedDevice != null) {
        AppLogger.info('Connected to printer: ${event.device.name}', tag: 'PrinterBloc');
        emit(PrinterConnected(
          connectedDevice: _printerService.connectedDevice!,
          availableDevices: state.availableDevices,
        ));
      } else {
        emit(PrinterError(
          message: 'Failed to establish Bluetooth connection to ${event.device.name}',
          availableDevices: state.availableDevices,
          connectedDevice: null,
        ));
      }
    } catch (e, stack) {
      AppLogger.error('Error connecting to printer: $e', tag: 'PrinterBloc', stackTrace: stack);
      emit(PrinterError(
        message: e.toString(),
        availableDevices: state.availableDevices,
        connectedDevice: null,
      ));
    }
  }

  Future<void> _onDisconnectPrinter(DisconnectPrinterRequested event, Emitter<PrinterState> emit) async {
    await _printerService.disconnect();
    emit(PrinterDisconnected(availableDevices: state.availableDevices));
  }

  Future<void> _onPrintReceipt(PrintReceiptRequested event, Emitter<PrinterState> emit) async {
    if (!_printerService.isConnected || _printerService.connectedDevice == null) {
      emit(PrinterError(
        message: 'No printer connected. Please connect a Bluetooth printer first.',
        availableDevices: state.availableDevices,
        connectedDevice: null,
      ));
      return;
    }

    emit(PrinterPrinting(
      availableDevices: state.availableDevices,
      connectedDevice: state.connectedDevice,
    ));

    try {
      final bytes = await MyanmarReceiptRenderer.renderReceiptToEscPosBytes(
        receipt: event.receipt,
        paperWidth: _printerService.connectedDevice!.paperWidth,
      );

      final printed = await _printerService.sendBytes(bytes);
      if (printed) {
        emit(PrintSuccess(
          message: 'Receipt printed successfully (${event.receipt.receiptNumber})',
          availableDevices: state.availableDevices,
          connectedDevice: state.connectedDevice,
        ));
      } else {
        emit(PrinterError(
          message: 'Failed to transmit ESC/POS print job to printer.',
          availableDevices: state.availableDevices,
          connectedDevice: state.connectedDevice,
        ));
      }
    } catch (e, stack) {
      AppLogger.error('Receipt print failed: $e', tag: 'PrinterBloc', stackTrace: stack);
      emit(PrinterError(
        message: 'Printing failed: $e',
        availableDevices: state.availableDevices,
        connectedDevice: state.connectedDevice,
      ));
    }
  }

  Future<void> _onPrintTestReceipt(PrintTestReceiptRequested event, Emitter<PrinterState> emit) async {
    final testReceipt = RepaymentReceipt(
      transactionId: 'TEST-TXN-001',
      contractCode: 'BMF-TEST-2026',
      periodNumber: 1,
      customerCode: 'CUST-DEMO',
      customerName: 'Daw Aye Aye Myint',
      principalAmount: 50000.0,
      interestAmount: 5000.0,
      insuranceFee: 1000.0,
      compulsorySaving: 2000.0,
      totalAmount: 58000.0,
      paymentMethod: RepaymentMethod.cash,
      receiptNumber: 'RCPT-TEST-001',
      collectorId: 'OFFICER001',
      collectedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      idempotencyKey: 'IDEMP-TEST-001',
    );

    add(PrintReceiptRequested(testReceipt));
  }
}
