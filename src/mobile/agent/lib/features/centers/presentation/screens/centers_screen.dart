import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/center_item.dart';
import '../../domain/entities/group_item.dart';
import '../bloc/center_bloc.dart';
import '../bloc/center_event.dart';
import '../bloc/center_state.dart';

/// Screen listing Centers & Groups assigned to the Field Officer.
class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CenterBloc>().add(const LoadCentersRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.centersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CenterBloc>().add(const LoadCentersRequested(forceRefresh: true));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCenterHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
          ),

          // Centers List Content
          Expanded(
            child: BlocBuilder<CenterBloc, CenterState>(
              builder: (context, state) {
                if (state is CenterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CenterError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.accentCrimson),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CenterBloc>().add(const LoadCentersRequested(forceRefresh: true));
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CenterLoaded) {
                  final filteredCenters = state.centers.where((center) {
                    if (_searchQuery.isEmpty) return true;
                    return center.centerCode.toLowerCase().contains(_searchQuery) ||
                        center.centerName.toLowerCase().contains(_searchQuery) ||
                        center.townshipCode.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredCenters.isEmpty) {
                    return Center(
                      child: Text(
                        'No centers match "$_searchQuery"',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CenterBloc>().add(const LoadCentersRequested(forceRefresh: true));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredCenters.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final center = filteredCenters[index];
                        final isSelected = state.selectedCenter?.centerCode == center.centerCode;

                        return _CenterCard(
                          center: center,
                          isSelected: isSelected,
                          groups: isSelected ? state.groups : const [],
                          onSelect: () {
                            context.read<CenterBloc>().add(SelectCenterRequested(center.centerCode));
                          },
                          onOpenCollection: () {
                            context.push('${AppRouter.collectionRoute}?centerCode=${center.centerCode}&centerName=${Uri.encodeComponent(center.centerName)}');
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final CenterItem center;
  final bool isSelected;
  final List<GroupItem> groups;
  final VoidCallback onSelect;
  final VoidCallback onOpenCollection;

  const _CenterCard({
    required this.center,
    required this.isSelected,
    required this.groups,
    required this.onSelect,
    required this.onOpenCollection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.borderSubtle,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          center.centerCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          center.centerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaInfo(icon: Icons.calendar_today, label: '${l10n.meetingDayLabel}: ${center.meetingDay}'),
                      const SizedBox(width: 16),
                      _MetaInfo(icon: Icons.access_time, label: center.meetingTime),
                      const Spacer(),
                      _MetaInfo(icon: Icons.location_on_outlined, label: center.townshipCode),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppTheme.backgroundLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.groupCountLabel}: ${groups.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          backgroundColor: AppTheme.primaryNavy,
                        ),
                        icon: const Icon(Icons.table_chart, size: 16),
                        label: Text(l10n.collectionSheetTitle, style: const TextStyle(fontSize: 13)),
                        onPressed: onOpenCollection,
                      ),
                    ],
                  ),
                  if (groups.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: groups.map((g) {
                        return Chip(
                          label: Text('${g.groupCode} - ${g.groupName} (${g.leaderName})'),
                          labelStyle: const TextStyle(fontSize: 11),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
