import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import '../../data/services/branch_service.dart';

/// Model representing a Financial Branch or Village Service Point.
class BranchPoint {
  final String code;
  final String name;
  final String type; // MAIN_BRANCH, SUB_BRANCH, VILLAGE_POINT, AGENT
  final String region; // Yangon, Mandalay, Bago, Ayeyarwady, Naypyidaw
  final String township;
  final String address;
  final String phone;
  final String workingHours;
  final double distanceKm;
  final bool isOpenNow;
  final List<String> services;

  const BranchPoint({
    required this.code,
    required this.name,
    required this.type,
    required this.region,
    required this.township,
    required this.address,
    required this.phone,
    required this.workingHours,
    required this.distanceKm,
    required this.isOpenNow,
    required this.services,
  });

  factory BranchPoint.fromJson(Map<String, dynamic> json) {
    return BranchPoint(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'MAIN_BRANCH',
      region: json['region']?.toString() ?? '',
      township: json['township']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      workingHours: json['workingHours']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      isOpenNow: json['isOpenNow'] as bool? ?? true,
      services: (json['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'type': type,
      'region': region,
      'township': township,
      'address': address,
      'phone': phone,
      'workingHours': workingHours,
      'distanceKm': distanceKm,
      'isOpenNow': isOpenNow,
      'services': services,
    };
  }
}

/// Dedicated Screen displaying Network of Branches & Transaction Points with minimalist UI.
class BranchNetworkScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const BranchNetworkScreen({super.key, this.onOpenDrawer});

  @override
  State<BranchNetworkScreen> createState() => _BranchNetworkScreenState();
}

class _BranchNetworkScreenState extends State<BranchNetworkScreen> {
  List<BranchPoint> _branches = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await BranchDirectoryService().getBranchPoints();
      if (mounted) {
        setState(() {
          _branches = branches;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _searchQuery = '';
  String _selectedRegion = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    final filtered = _branches.where((b) {
      if (_selectedRegion != 'ALL' && b.region != _selectedRegion) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return b.name.toLowerCase().contains(q) ||
            b.township.toLowerCase().contains(q) ||
            b.address.toLowerCase().contains(q) ||
            b.phone.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onOpenDrawer,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        title: Text(
          l10n.branchNetwork,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchPlaceholder,
                  hintStyle: const TextStyle(fontSize: 12.5, color: CustomerTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, size: 20, color: CustomerTheme.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  filled: true,
                  fillColor: CustomerTheme.backgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            // 2. Region Pills
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    _buildRegionPill('ALL', l10n.filterAll),
                    const SizedBox(width: 8),
                    _buildRegionPill('Yangon', 'Yangon'),
                    const SizedBox(width: 8),
                    _buildRegionPill('Mandalay', 'Mandalay'),
                    const SizedBox(width: 8),
                    _buildRegionPill('Bago', 'Bago'),
                    const SizedBox(width: 8),
                    _buildRegionPill('Ayeyarwady', 'Ayeyarwady'),
                    const SizedBox(width: 8),
                    _buildRegionPill('Naypyidaw', 'Naypyidaw'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: CustomerTheme.borderSubtle),

            // 3. Branches List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_off_outlined, size: 52, color: CustomerTheme.textSecondary.withAlpha(80)),
                                const SizedBox(height: 12),
                                Text(l10n.noMatchingTransactions, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                const SizedBox(height: 4),
                                Text(l10n.tryDifferentFilter, style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 11.5)),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final branch = filtered[index];
                            return _buildBranchCard(branch, l10n);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionPill(String key, String label) {
    final isSelected = _selectedRegion == key;
    return InkWell(
      onTap: () => setState(() => _selectedRegion = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.backgroundLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : CustomerTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard(BranchPoint branch, CustomerLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomerTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CustomerTheme.primaryNavy.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded, color: CustomerTheme.primaryNavy, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      branch.address,
                      style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (branch.distanceKm > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${branch.distanceKm < 10 ? branch.distanceKm.toStringAsFixed(1) : branch.distanceKm.toInt()} km',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 13, color: CustomerTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    branch.phone,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CustomerTheme.primaryNavy),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: CustomerTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    branch.workingHours,
                    style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
