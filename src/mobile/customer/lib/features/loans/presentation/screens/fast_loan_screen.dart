import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/core/utils/currency_formatter.dart';

/// Model representing a Fast Loan Product package.
class FastLoanProduct {
  final String id;
  final String title;
  final String description;
  final double minAmount;
  final double maxAmount;
  final double monthlyRatePercent;
  final List<int> availableTermsMonths;
  final IconData icon;
  final Color color;

  const FastLoanProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.minAmount,
    required this.maxAmount,
    required this.monthlyRatePercent,
    required this.availableTermsMonths,
    required this.icon,
    required this.color,
  });
}

/// Model representing a submitted Quick Loan Application.
class LoanApplicationItem {
  final String applicationCode;
  final String productTitle;
  final double requestedAmount;
  final int termMonths;
  final String frequency;
  final String disbursementMethod;
  final String status; // PENDING, APPROVED, DISBURSED, REJECTED
  final int progressStep; // 1 to 4
  final DateTime createdAt;
  final String? note;

  const LoanApplicationItem({
    required this.applicationCode,
    required this.productTitle,
    required this.requestedAmount,
    required this.termMonths,
    required this.frequency,
    required this.disbursementMethod,
    required this.status,
    required this.progressStep,
    required this.createdAt,
    this.note,
  });
}

/// Dedicated Fast Loan & Quick Application Screen with Interactive Calculator and Tracking.
class FastLoanScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const FastLoanScreen({super.key, this.onOpenDrawer});

  @override
  State<FastLoanScreen> createState() => _FastLoanScreenState();
}

class _FastLoanScreenState extends State<FastLoanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Catalog products
  final List<FastLoanProduct> _products = const [
    FastLoanProduct(
      id: 'PROD-AGRI',
      title: 'Vay Nông nghiệp mùa vụ',
      description: 'Hỗ trợ giống cây trồng, phân bón & vật tư nông nghiệp',
      minAmount: 300000,
      maxAmount: 3000000,
      monthlyRatePercent: 1.25,
      availableTermsMonths: [3, 6, 9, 12],
      icon: Icons.agriculture_rounded,
      color: CustomerTheme.accentTeal,
    ),
    FastLoanProduct(
      id: 'PROD-BIZ',
      title: 'Vay Kinh doanh tiểu thương',
      description: 'Bổ sung vốn lưu động sạp chợ, cửa hàng tạp hóa',
      minAmount: 500000,
      maxAmount: 5000000,
      monthlyRatePercent: 1.45,
      availableTermsMonths: [6, 12, 18],
      icon: Icons.storefront_rounded,
      color: CustomerTheme.primaryNavy,
    ),
    FastLoanProduct(
      id: 'PROD-CONSUMER',
      title: 'Vay Tiêu dùng gia đình',
      description: 'Trang trải học phí, sửa chữa nhà ở, mua sắm thiết bị',
      minAmount: 200000,
      maxAmount: 2000000,
      monthlyRatePercent: 1.50,
      availableTermsMonths: [3, 6, 9],
      icon: Icons.family_restroom_rounded,
      color: CustomerTheme.primaryCyan,
    ),
    FastLoanProduct(
      id: 'PROD-EMERGENCY',
      title: 'Vay Khẩn cấp 24/7',
      description: 'Giải ngân siêu tốc 15 phút qua ví điện tử cho sự cố y tế',
      minAmount: 100000,
      maxAmount: 1000000,
      monthlyRatePercent: 1.50,
      availableTermsMonths: [3, 6],
      icon: Icons.flash_on_rounded,
      color: CustomerTheme.secondaryAmber,
    ),
  ];

  late FastLoanProduct _selectedProduct;
  double _requestedAmount = 1000000;
  int _selectedTermMonths = 6;
  String _repaymentFrequency = 'MONTHLY'; // MONTHLY, BIWEEKLY, WEEKLY
  String _disbursementMethod = 'KBZPAY'; // KBZPAY, WAVEPAY, BANK, CASH
  final TextEditingController _purposeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<LoanApplicationItem> _myApplications = [
    LoanApplicationItem(
      applicationCode: 'APP-2026-0891',
      productTitle: 'Vay Kinh doanh tiểu thương',
      requestedAmount: 1500000,
      termMonths: 6,
      frequency: 'MONTHLY',
      disbursementMethod: 'KBZPAY',
      status: 'APPROVED',
      progressStep: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Hạn mức 1.500.000 MMK đã được duyệt.',
    ),
    LoanApplicationItem(
      applicationCode: 'APP-2026-0744',
      productTitle: 'Vay Nông nghiệp mùa vụ',
      requestedAmount: 2000000,
      termMonths: 12,
      frequency: 'MONTHLY',
      disbursementMethod: 'BANK',
      status: 'DISBURSED',
      progressStep: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      note: 'Đã giải ngân thành công.',
    ),
    LoanApplicationItem(
      applicationCode: 'APP-2026-0902',
      productTitle: 'Vay Khẩn cấp 24/7',
      requestedAmount: 500000,
      termMonths: 3,
      frequency: 'WEEKLY',
      disbursementMethod: 'WAVEPAY',
      status: 'PENDING',
      progressStep: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      note: 'Đang thẩm định hồ sơ.',
    ),
  ];

  String _statusFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedProduct = _products[1];
    _selectedTermMonths = _selectedProduct.availableTermsMonths.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Financial Estimation calculations
  double get _monthlyInterestAmount => _requestedAmount * (_selectedProduct.monthlyRatePercent / 100);
  double get _totalPrincipalPerMonth => _requestedAmount / _selectedTermMonths;
  double get _estimatedMonthlyPayment => _totalPrincipalPerMonth + _monthlyInterestAmount;
  double get _insuranceFeeAmount => _requestedAmount * 0.005;

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomerTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.onOpenDrawer,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        title: Text(
          l10n.applyLoanTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CustomerTheme.secondaryAmber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(icon: const Icon(Icons.calculate_outlined, size: 18), text: l10n.tabApplyLoan),
            Tab(icon: const Icon(Icons.assignment_outlined, size: 18), text: l10n.tabTrackApplications),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplyTab(context, l10n),
          _buildTrackingTab(context, l10n),
        ],
      ),
    );
  }

  // ==================== TAB 1: APPLY LOAN ====================
  Widget _buildApplyTab(BuildContext context, CustomerLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Selection
            Text(
              l10n.selectLoanPackage,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prod = _products[index];
                  final isSelected = prod.id == _selectedProduct.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedProduct = prod;
                        if (_requestedAmount < prod.minAmount) _requestedAmount = prod.minAmount;
                        if (_requestedAmount > prod.maxAmount) _requestedAmount = prod.maxAmount;
                        if (!prod.availableTermsMonths.contains(_selectedTermMonths)) {
                          _selectedTermMonths = prod.availableTermsMonths.first;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 155,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? prod.color.withAlpha(15) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? prod.color : CustomerTheme.borderSubtle,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: prod.color.withAlpha(25),
                                child: Icon(prod.icon, size: 15, color: prod.color),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, size: 15, color: prod.color),
                            ],
                          ),
                          Text(
                            prod.title,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? prod.color : CustomerTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${prod.monthlyRatePercent}% / ${l10n.interestPerMonth}',
                            style: const TextStyle(fontSize: 10.5, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // 2. Amount Slider Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CustomerTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.loanAmountToBorrow,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: CustomerTheme.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.formatMmk(_requestedAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CustomerTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _requestedAmount.clamp(_selectedProduct.minAmount, _selectedProduct.maxAmount),
                    min: _selectedProduct.minAmount,
                    max: _selectedProduct.maxAmount,
                    divisions: ((_selectedProduct.maxAmount - _selectedProduct.minAmount) / 50000).round().clamp(1, 100),
                    activeColor: CustomerTheme.primaryNavy,
                    inactiveColor: CustomerTheme.borderSubtle,
                    onChanged: (val) {
                      setState(() {
                        _requestedAmount = val;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.minAmountLabel}: ${CurrencyFormatter.formatMmk(_selectedProduct.minAmount)}',
                        style: const TextStyle(fontSize: 10.5, color: CustomerTheme.textSecondary),
                      ),
                      Text(
                        '${l10n.maxAmountLabel}: ${CurrencyFormatter.formatMmk(_selectedProduct.maxAmount)}',
                        style: const TextStyle(fontSize: 10.5, color: CustomerTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Term & Frequency
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.loanTerm,
                          style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedTermMonths,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                          items: _selectedProduct.availableTermsMonths.map((m) {
                            return DropdownMenuItem(value: m, child: Text('$m ${l10n.monthsTerm}', style: const TextStyle(fontSize: 12.5)));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedTermMonths = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CustomerTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.repaymentFrequency,
                          style: const TextStyle(fontSize: 11, color: CustomerTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: _repaymentFrequency,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                          items: [
                            DropdownMenuItem(value: 'MONTHLY', child: Text(l10n.monthly, style: const TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'BIWEEKLY', child: Text(l10n.biweekly, style: const TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'WEEKLY', child: Text(l10n.weekly, style: const TextStyle(fontSize: 12.5))),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _repaymentFrequency = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 4. Live Calculation Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CustomerTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.estimatedMonthlyRepayment,
                        style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.formatMmk(_estimatedMonthlyPayment),
                        style: const TextStyle(
                          color: CustomerTheme.primaryNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 14, color: CustomerTheme.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.monthlyPrincipal}:', style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 11.5)),
                      Text(CurrencyFormatter.formatMmk(_totalPrincipalPerMonth), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.monthlyInterest} (${_selectedProduct.monthlyRatePercent}%):', style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 11.5)),
                      Text(CurrencyFormatter.formatMmk(_monthlyInterestAmount), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.welfareInsuranceFee}:', style: const TextStyle(color: CustomerTheme.textSecondary, fontSize: 11.5)),
                      Text(CurrencyFormatter.formatMmk(_insuranceFeeAmount), style: const TextStyle(color: CustomerTheme.statusCurrent, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Disbursement Channel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CustomerTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.disbursementMethod,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  _buildDisbursementItem('KBZPAY', 'KBZPay', Icons.account_balance_wallet_rounded),
                  _buildDisbursementItem('WAVEPAY', 'WavePay', Icons.waves_rounded),
                  _buildDisbursementItem('BANK', 'AYA / CB / KBZ Bank', Icons.account_balance_rounded),
                  _buildDisbursementItem('CASH', 'Cash / Chi nhánh', Icons.storefront_rounded),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 6. Loan Purpose
            TextFormField(
              controller: _purposeController,
              decoration: InputDecoration(
                labelText: l10n.loanPurpose,
                hintText: l10n.loanPurposeHint,
                hintStyle: const TextStyle(fontSize: 11.5),
                prefixIcon: const Icon(Icons.edit_note, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: CustomerTheme.borderSubtle)),
              ),
            ),

            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: () => _submitApplication(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerTheme.primaryNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n.submitLoanApplication, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisbursementItem(String val, String title, IconData icon) {
    final isSelected = _disbursementMethod == val;
    return InkWell(
      onTap: () => setState(() => _disbursementMethod = val),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.textSecondary,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 18, color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.textSecondary),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 12.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _submitApplication(CustomerLocalizations l10n) {
    final code = 'APP-2026-${(1000 + _myApplications.length).toString()}';
    final newApp = LoanApplicationItem(
      applicationCode: code,
      productTitle: _selectedProduct.title,
      requestedAmount: _requestedAmount,
      termMonths: _selectedTermMonths,
      frequency: _repaymentFrequency,
      disbursementMethod: _disbursementMethod,
      status: 'PENDING',
      progressStep: 1,
      createdAt: DateTime.now(),
      note: l10n.appStatusUnderReview,
    );

    setState(() {
      _myApplications.insert(0, newApp);
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: CustomerTheme.statusCurrent, size: 24),
            const SizedBox(width: 8),
            Text(l10n.applicationSubmittedSuccess, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.referenceNo}: $code', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('${_selectedProduct.title} • ${CurrencyFormatter.formatMmk(_requestedAmount)}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tabController.animateTo(1);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
            child: Text(l10n.viewProgress),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: APPLICATION TRACKING LIST ====================
  Widget _buildTrackingTab(BuildContext context, CustomerLocalizations l10n) {
    final filtered = _myApplications.where((app) {
      if (_statusFilter != 'ALL' && app.status != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return app.applicationCode.toLowerCase().contains(query) || app.productTitle.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchApplicationPlaceholder,
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  filled: true,
                  fillColor: CustomerTheme.backgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPill('ALL', '${l10n.filterAll} (${_myApplications.length})'),
                    const SizedBox(width: 6),
                    _buildPill('PENDING', l10n.appStatusUnderReview),
                    const SizedBox(width: 6),
                    _buildPill('APPROVED', l10n.appStatusApproved),
                    const SizedBox(width: 6),
                    _buildPill('DISBURSED', l10n.appStatusDisbursed),
                    const SizedBox(width: 6),
                    _buildPill('REJECTED', l10n.appStatusRejected),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: CustomerTheme.borderSubtle),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 52, color: CustomerTheme.textSecondary.withAlpha(80)),
                        const SizedBox(height: 12),
                        Text(l10n.noNotificationsFound, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final app = filtered[index];
                    return _buildApplicationCard(app, l10n);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPill(String key, String label) {
    final isSelected = _statusFilter == key;
    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? CustomerTheme.primaryNavy : CustomerTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : CustomerTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(LoanApplicationItem app, CustomerLocalizations l10n) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (app.status) {
      case 'APPROVED':
        statusColor = CustomerTheme.statusCurrent;
        statusLabel = l10n.appStatusApproved;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'DISBURSED':
        statusColor = CustomerTheme.primaryNavy;
        statusLabel = l10n.appStatusDisbursed;
        statusIcon = Icons.task_alt_rounded;
        break;
      case 'REJECTED':
        statusColor = CustomerTheme.accentCrimson;
        statusLabel = l10n.appStatusRejected;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'PENDING':
      default:
        statusColor = CustomerTheme.secondaryAmber;
        statusLabel = l10n.appStatusUnderReview;
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomerTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                app.applicationCode,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: CustomerTheme.primaryNavy),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            app.productTitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatMmk(app.requestedAmount),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: CustomerTheme.primaryNavy),
              ),
              Text('${app.termMonths} ${l10n.monthsTerm}', style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
