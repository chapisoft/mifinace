import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/models/bluetooth_printer_device.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

/// Screen for scanning, pairing, and managing Bluetooth Thermal Printers.
class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(const ScanPrintersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bluetoothPrinterTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.scanPrinters,
            onPressed: () {
              context.read<PrinterBloc>().add(const ScanPrintersRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<PrinterBloc, PrinterState>(
        listener: (context, state) {
          if (state is PrintSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.accentTeal,
              ),
            );
          } else if (state is PrinterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.accentCrimson,
              ),
            );
          }
        },
        builder: (context, state) {
          final isConnected = state.connectedDevice != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connected Printer Status Banner
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isConnected ? AppTheme.accentTeal : AppTheme.borderSubtle,
                    width: isConnected ? 1.5 : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isConnected
                                ? AppTheme.accentTeal.withAlpha(25)
                                : AppTheme.textSecondary.withAlpha(25),
                            child: Icon(
                              Icons.print,
                              color: isConnected ? AppTheme.accentTeal : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected ? state.connectedDevice!.name : l10n.printerDisconnected,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isConnected
                                      ? '${state.connectedDevice!.address} • ${state.connectedDevice!.paperWidth.name}'
                                      : 'No active Bluetooth link established',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConnected ? AppTheme.accentTeal : AppTheme.textSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isConnected ? l10n.printerConnected : l10n.printerDisconnected,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (isConnected) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.receipt_long, size: 16),
                                label: const Text('Print Test Receipt', style: TextStyle(fontSize: 13)),
                                onPressed: state is PrinterPrinting
                                    ? null
                                    : () {
                                        context.read<PrinterBloc>().add(const PrintTestReceiptRequested());
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.link_off, color: AppTheme.accentCrimson),
                              tooltip: l10n.disconnectPrinter,
                              onPressed: () {
                                context.read<PrinterBloc>().add(const DisconnectPrinterRequested());
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Available Printers Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Bluetooth Devices (${state.availableDevices.length})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  if (state is PrinterScanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Devices List
              if (state.availableDevices.isEmpty && state is! PrinterScanning)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.bluetooth_searching, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noPrintersFound,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search, size: 16),
                          label: Text(l10n.scanPrinters),
                          onPressed: () {
                            context.read<PrinterBloc>().add(const ScanPrintersRequested());
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...state.availableDevices.map((device) {
                  final isThisConnected = state.connectedDevice?.address == device.address;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth, color: AppTheme.primaryNavy),
                      title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('${device.address} • ${device.paperWidth.name}', style: const TextStyle(fontSize: 12)),
                      trailing: isThisConnected
                          ? const Icon(Icons.check_circle, color: AppTheme.accentTeal)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                backgroundColor: AppTheme.primaryNavy,
                              ),
                              onPressed: () {
                                context.read<PrinterBloc>().add(ConnectPrinterRequested(device));
                              },
                              child: Text(l10n.connectPrinter, style: const TextStyle(fontSize: 12)),
                            ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
