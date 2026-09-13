import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_customer/features/payments/domain/models/customer_transaction.dart';
import 'package:bmf_customer/features/payments/domain/repositories/payment_repository.dart';

/// Clean, Minimalist Transaction History Screen with Single-Row Filter Tabs and 100% i18n.
class TransactionHistoryScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const TransactionHistoryScreen({super.key, this.onOpenDrawer});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<CustomerTransaction> _transactions = [];
  bool _isLoading = false;

  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  String _selectedPeriod = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    final authState = context.read<CustomerAuthBloc>().state;
    final customerCode = authState is AuthAuthenticated ? authState.profile.customerCode : '';
    try {
      if (customerCode.isNotEmpty) {
        final txs = await context.read<PaymentRepository>().getCustomerTransactions(customerCode);
        if (mounted) {
          setState(() {
            _transactions = txs;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    // Apply Filters
    final filteredTransactions = _transactions.where((tx) {
      if (_selectedCategory == 'REPAYMENT') {
        if (!tx.paymentMethod.toUpperCase().contains('MMQR') && !tx.paymentMethod.toUpperCase().contains('CASH')) return false;
      } else if (_selectedCategory == 'SAVING') {
        if (tx.compulsorySavingMmk <= 0) return false;
      } else if (_selectedCategory == 'INSURANCE') {
        if (tx.insuranceFeeMmk <= 0) return false;
      }

      if (_selectedPeriod == 'THIS_MONTH') {
        final now = DateTime.now();
        if (tx.transactionTime.month != now.month || tx.transactionTime.year != now.year) return false;
      } else if (_selectedPeriod == 'LAST_3_MONTHS') {
        final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
        if (tx.transactionTime.isBefore(threeMonthsAgo)) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return tx.transactionId.toLowerCase().contains(q) ||
            tx.contractCode.toLowerCase().contains(q) ||
            tx.paymentMethod.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    double totalPaid = 0;
    for (var tx in filteredTransactions) {
      totalPaid += tx.totalAmountMmk;
    }

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
          l10n.navHistory,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar & Time Filter Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(
                children: [
                  Expanded(
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
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showPeriodFilterModal(l10n),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _selectedPeriod != 'ALL' ? CustomerTheme.primaryNavy.withAlpha(20) : CustomerTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedPeriod != 'ALL' ? CustomerTheme.primaryNavy : CustomerTheme.borderSubtle,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: _selectedPeriod != 'ALL' ? CustomerTheme.primaryNavy : CustomerTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Single-Row Minimalist Category Selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    _buildTabPill('ALL', l10n.filterAll),
                    const SizedBox(width: 8),
                    _buildTabPill('REPAYMENT', l10n.filterRepayment),
                    const SizedBox(width: 8),
                    _buildTabPill('SAVING', l10n.filterSavings),
                    const SizedBox(width: 8),
                    _buildTabPill('INSURANCE', l10n.filterInsurance),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: CustomerTheme.borderSubtle),

            // 3. Compact Summary Row (Only when items exist)
            if (filteredTransactions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredTransactions.length} ${l10n.navHistory.toLowerCase()}',
                      style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${l10n.totalPaidAmountLabel}: ${CurrencyFormatter.formatMmk(totalPaid)}',
                      style: const TextStyle(fontSize: 12, color: CustomerTheme.primaryNavy, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // 4. Transactions List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: CustomerTheme.primaryNavy))
                  : filteredTransactions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 52, color: CustomerTheme.textSecondary.withAlpha(80)),
                                const SizedBox(height: 12),
                                Text(l10n.noMatchingTransactions, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.tryDifferentFilter,
                                  style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 11.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchTransactions,
                          color: CustomerTheme.primaryNavy,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final tx = filteredTransactions[index];
                              return _buildTransactionCard(tx, l10n);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String key, String label) {
    final isSelected = _selectedCategory == key;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = key),
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

  void _showPeriodFilterModal(CustomerLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filterModalTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(l10n.allTime, style: const TextStyle(fontSize: 13.5)),
                  trailing: _selectedPeriod == 'ALL' ? const Icon(Icons.check, color: CustomerTheme.primaryNavy) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'ALL');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text(l10n.thisMonth, style: const TextStyle(fontSize: 13.5)),
                  trailing: _selectedPeriod == 'THIS_MONTH' ? const Icon(Icons.check, color: CustomerTheme.primaryNavy) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'THIS_MONTH');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text(l10n.last3Months, style: const TextStyle(fontSize: 13.5)),
                  trailing: _selectedPeriod == 'LAST_3_MONTHS' ? const Icon(Icons.check, color: CustomerTheme.primaryNavy) : null,
                  onTap: () {
                    setState(() => _selectedPeriod = 'LAST_3_MONTHS');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(CustomerTransaction tx, CustomerLocalizations l10n) {
    final isMmqr = tx.paymentMethod.toUpperCase().contains('MMQR');

    return InkWell(
      onTap: () => _showReceiptModal(tx, l10n),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomerTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMmqr ? CustomerTheme.primaryNavy.withAlpha(15) : CustomerTheme.statusCurrent.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isMmqr ? Icons.qr_code_2_rounded : Icons.account_balance_wallet_rounded,
                color: isMmqr ? CustomerTheme.primaryNavy : CustomerTheme.statusCurrent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.transactionId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CustomerTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.contractCode} • ${tx.paymentMethod}',
                    style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${tx.transactionTime.day.toString().padLeft(2, '0')}/${tx.transactionTime.month.toString().padLeft(2, '0')}/${tx.transactionTime.year} ${tx.transactionTime.hour.toString().padLeft(2, '0')}:${tx.transactionTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, color: CustomerTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${CurrencyFormatter.formatMmk(tx.totalAmountMmk)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CustomerTheme.statusCurrent),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.status == 'SETTLED' ? l10n.statusPaid : tx.status,
                  style: const TextStyle(color: CustomerTheme.statusCurrent, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(CustomerTransaction tx, CustomerLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: CustomerTheme.borderSubtle, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFD1FAE5),
                child: Icon(Icons.check_circle_rounded, color: CustomerTheme.statusCurrent, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.electronicReceipt,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.transactionRefLabel}: ${tx.transactionId}',
                style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CustomerTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomerTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(l10n.totalPaidAmountLabel, CurrencyFormatter.formatMmk(tx.totalAmountMmk), isBold: true, highlight: true),
                    const Divider(height: 14),
                    _buildReceiptRow(l10n.principal, CurrencyFormatter.formatMmk(tx.principalAmountMmk)),
                    _buildReceiptRow(l10n.interest, CurrencyFormatter.formatMmk(tx.interestAmountMmk)),
                    if (tx.compulsorySavingMmk > 0)
                      _buildReceiptRow(l10n.compulsorySaving, CurrencyFormatter.formatMmk(tx.compulsorySavingMmk)),
                    if (tx.insuranceFeeMmk > 0)
                      _buildReceiptRow(l10n.insuranceFee, CurrencyFormatter.formatMmk(tx.insuranceFeeMmk)),
                    const Divider(height: 14),
                    _buildReceiptRow(l10n.contractCodeLabel, tx.contractCode),
                    _buildReceiptRow(l10n.paymentChannelLabel, tx.paymentMethod),
                    _buildReceiptRow(
                      l10n.settledDateLabel,
                      '${tx.transactionTime.day}/${tx.transactionTime.month}/${tx.transactionTime.year} ${tx.transactionTime.hour}:${tx.transactionTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.savingReceiptPdf)),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: Text(l10n.savePdf),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomerTheme.primaryNavy,
                        side: const BorderSide(color: CustomerTheme.primaryNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.sharingReceipt)),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: Text(l10n.share),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomerTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 14 : 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: highlight ? CustomerTheme.primaryNavy : CustomerTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
