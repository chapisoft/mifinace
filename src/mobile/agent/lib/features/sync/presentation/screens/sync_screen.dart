import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';

/// Screen managing two-way offline synchronization status and manual triggers.
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(const LoadSyncSummaryRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offlineSyncTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SyncBloc>().add(const LoadSyncSummaryRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.syncSuccess),
                backgroundColor: AppTheme.accentTeal,
              ),
            );
          } else if (state is SyncFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppTheme.accentCrimson,
              ),
            );
          }
        },
        builder: (context, state) {
          final summary = state.summary;
          final isSyncing = state is SyncInProgressState;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sync Engine Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryNavy.withAlpha(25),
                            child: const Icon(Icons.sync_alt, color: AppTheme.primaryNavy),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.syncStatusTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  summary?.isOnline == true ? l10n.networkOnline : l10n.networkOffline,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: summary?.isOnline == true ? AppTheme.accentTeal : AppTheme.accentAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SyncStatBox(
                            label: l10n.syncPending,
                            count: summary?.pendingCount ?? 0,
                            color: (summary?.pendingCount ?? 0) > 0 ? AppTheme.accentAmber : AppTheme.textSecondary,
                          ),
                          Container(width: 1, height: 40, color: AppTheme.borderSubtle),
                          _SyncStatBox(
                            label: l10n.statSynced,
                            count: summary?.syncedCount ?? 0,
                            color: AppTheme.accentTeal,
                          ),
                          Container(width: 1, height: 40, color: AppTheme.borderSubtle),
                          _SyncStatBox(
                            label: l10n.statFailed,
                            count: summary?.failedCount ?? 0,
                            color: (summary?.failedCount ?? 0) > 0 ? AppTheme.accentCrimson : AppTheme.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (summary?.lastSyncTime != null)
                        Center(
                          child: Text(
                            '${l10n.lastSyncTime}: ${summary!.lastSyncTime!.toIso8601String().replaceAll("T", " ").substring(0, 19)}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sync Now Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync, size: 20),
                label: Text(
                  isSyncing ? l10n.syncInProgress : l10n.syncNow,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: isSyncing
                    ? null
                    : () {
                        context.read<SyncBloc>().add(const TriggerManualSyncRequested());
                      },
              ),

              const SizedBox(height: 24),

              // Offline Guidance Notes
              Card(
                color: AppTheme.backgroundLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryNavy),
                          const SizedBox(width: 8),
                          Text(
                            l10n.offlineGuidelinesTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.offlineGuidelinesText,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SyncStatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SyncStatBox({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
