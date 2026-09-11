import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/repayment_method.dart';
import 'package:bmf_agent_app/core/enums/sync_status.dart';
import 'package:bmf_agent_app/features/collection/domain/entities/repayment_receipt.dart';
import 'package:bmf_agent_app/features/printer/domain/models/bluetooth_printer_device.dart';
import 'package:bmf_agent_app/features/printer/domain/services/bluetooth_printer_service.dart';
import 'package:bmf_agent_app/features/printer/presentation/bloc/printer_bloc.dart';
import 'package:bmf_agent_app/features/printer/presentation/bloc/printer_event.dart';
import 'package:bmf_agent_app/features/printer/presentation/bloc/printer_state.dart';

class MockBluetoothPrinterService implements BluetoothPrinterService {
  bool _isConnected = false;
  BluetoothPrinterDevice? _device;
  bool shouldFailConnect = false;
  bool shouldFailSend = false;

  final List<BluetoothPrinterDevice> mockDevices = const [
    BluetoothPrinterDevice(
      name: 'MPT-II 58mm Printer',
      address: 'AA:BB:CC:DD:EE:FF',
      paperWidth: PrinterPaperWidth.mm58,
    ),
  ];

  @override
  BluetoothPrinterDevice? get connectedDevice => _device;

  @override
  bool get isConnected => _isConnected && _device != null;

  @override
  Future<List<BluetoothPrinterDevice>> scanDevices() async => mockDevices;

  @override
  Future<bool> connect(BluetoothPrinterDevice device) async {
    if (shouldFailConnect) return false;
    _isConnected = true;
    _device = device.copyWith(isConnected: true);
    return true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _device = null;
  }

  @override
  Future<bool> sendBytes(Uint8List bytes) async {
    if (shouldFailSend) return false;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrinterBloc Tests (TASK-AGENT-05)', () {
    late MockBluetoothPrinterService mockPrinterService;
    late PrinterBloc printerBloc;

    setUp(() {
      mockPrinterService = MockBluetoothPrinterService();
      printerBloc = PrinterBloc(printerService: mockPrinterService);
    });

    tearDown(() {
      printerBloc.close();
    });

    test('Initial state is PrinterInitial', () {
      expect(printerBloc.state, equals(const PrinterInitial()));
    });

    test('ScanPrintersRequested discovers printers and emits PrinterDisconnected', () async {
      final expectedStates = [
        isA<PrinterScanning>(),
        isA<PrinterDisconnected>().having((s) => s.availableDevices.length, 'devices count', 1),
      ];

      expectLater(printerBloc.stream, emitsInOrder(expectedStates));

      printerBloc.add(const ScanPrintersRequested());
    });

    test('ConnectPrinterRequested connects to device and emits PrinterConnected', () async {
      final device = mockPrinterService.mockDevices.first;

      final expectedStates = [
        isA<PrinterConnecting>().having((s) => s.targetDevice.address, 'address', device.address),
        isA<PrinterConnected>().having((s) => s.connectedDevice?.name, 'device name', device.name),
      ];

      expectLater(printerBloc.stream, emitsInOrder(expectedStates));

      printerBloc.add(ConnectPrinterRequested(device));
    });

    test('DisconnectPrinterRequested resets connection and emits PrinterDisconnected', () async {
      await mockPrinterService.connect(mockPrinterService.mockDevices.first);

      final expectedStates = [
        isA<PrinterDisconnected>().having((s) => s.connectedDevice, 'connectedDevice', isNull),
      ];

      expectLater(printerBloc.stream, emitsInOrder(expectedStates));

      printerBloc.add(const DisconnectPrinterRequested());
    });

    test('PrintReceiptRequested emits PrinterError when no printer is connected', () async {
      final dummyReceipt = RepaymentReceipt(
        transactionId: 'TXN-001',
        contractCode: 'CON-001',
        periodNumber: 1,
        customerCode: 'CUST-001',
        customerName: 'Daw Khin',
        principalAmount: 10000,
        interestAmount: 1000,
        insuranceFee: 200,
        compulsorySaving: 500,
        totalAmount: 11700,
        paymentMethod: RepaymentMethod.cash,
        receiptNumber: 'RCPT-001',
        collectorId: 'OFFICER-001',
        collectedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        idempotencyKey: 'IDEMP-001',
      );

      final expectedStates = [
        isA<PrinterError>().having((s) => s.message, 'message', contains('No printer connected')),
      ];

      expectLater(printerBloc.stream, emitsInOrder(expectedStates));

      printerBloc.add(PrintReceiptRequested(dummyReceipt));
    });
  });
}
