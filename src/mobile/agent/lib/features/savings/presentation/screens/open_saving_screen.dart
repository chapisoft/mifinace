import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/saving_product_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/saving_account.dart';
import '../bloc/saving_bloc.dart';
import '../bloc/saving_event.dart';
import '../bloc/saving_state.dart';

/// Screen for opening a new village savings passbook account directly in the field.
class OpenSavingScreen extends StatefulWidget {
  final String centerCode;
  final String groupCode;

  const OpenSavingScreen({
    super.key,
    this.centerCode = 'C001',
    this.groupCode = 'G001',
  });

  @override
  State<OpenSavingScreen> createState() => _OpenSavingScreenState();
}

class _OpenSavingScreenState extends State<OpenSavingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Zero fake default values: controllers initialized empty
  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _phoneController = TextEditingController();
  final _initialDepositController = TextEditingController();

  final _nomineeNameController = TextEditingController();
  final _nomineeNrcController = TextEditingController();
  final _nomineeRelationController = TextEditingController();

  SavingProductType _selectedProduct = SavingProductType.voluntary;

  @override
  void dispose() {
    _nameController.dispose();
    _nrcController.dispose();
    _phoneController.dispose();
    _initialDepositController.dispose();
    _nomineeNameController.dispose();
    _nomineeNrcController.dispose();
    _nomineeRelationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final double initialDeposit = _initialDepositController.text.trim().isNotEmpty
        ? CurrencyFormatter.parseMmk(_initialDepositController.text).toDouble()
        : 0.0;

    final accountNo = 'SAV-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final accountId = 'SA-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    final newAccount = SavingAccount(
      accountId: accountId,
      accountNumber: accountNo,
      centerCode: widget.centerCode,
      groupCode: widget.groupCode,
      customerName: _nameController.text.trim(),
      nrcFormatted: _nrcController.text.trim(),
      phone: _phoneController.text.trim(),
      productType: _selectedProduct,
      balanceMmk: initialDeposit,
      interestRateAnnual: _selectedProduct == SavingProductType.fixedTerm ? 14.0 : 10.0,
      openedDate: DateTime.now(),
      nomineeName: _nomineeNameController.text.trim().isNotEmpty ? _nomineeNameController.text.trim() : null,
      nomineeNrc: _nomineeNrcController.text.trim().isNotEmpty ? _nomineeNrcController.text.trim() : null,
      nomineeRelation: _nomineeRelationController.text.trim().isNotEmpty ? _nomineeRelationController.text.trim() : null,
    );

    context.read<SavingBloc>().add(
          OpenSavingAccountRequested(
            account: newAccount,
            initialDepositMmk: initialDeposit,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openSavingsPassbookTitle),
      ),
      body: BlocListener<SavingBloc, SavingState>(
        listener: (context, state) {
          if (state is SavingOpenSuccessState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 28),
                    const SizedBox(width: 8),
                    Text(l10n.passbookCreatedTitle),
                  ],
                ),
                content: Text(
                  'Savings Passbook #${state.account.accountNumber} for ${state.account.customerName} has been opened successfully and queued for synchronization.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                    },
                    child: Text(l10n.doneButton),
                  ),
                ],
              ),
            );
          } else if (state is SavingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppTheme.accentCrimson),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1: Member Information
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.memberAccountHolder,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.borrowerFullName,
                          hintText: l10n.borrowerFullNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? l10n.borrowerFullNameRequired : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nrcController,
                        decoration: InputDecoration(
                          labelText: l10n.nrcInputLabel,
                          hintText: l10n.nrcInputHint,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? l10n.nrcRequiredValidation : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          hintText: l10n.phoneNumberHint,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? l10n.phoneNumberRequired : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SavingProductType>(
                        initialValue: _selectedProduct,
                        decoration: InputDecoration(
                          labelText: l10n.savingsProductPackage,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: SavingProductType.values.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p.localizedName(l10n)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProduct = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _initialDepositController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.initialCashDeposit,
                          hintText: l10n.initialDepositHint,
                          prefixIcon: const Icon(Icons.money),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Nominee & Beneficiary Information
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.legalNominee,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nomineeNameController,
                        decoration: InputDecoration(
                          labelText: l10n.nomineeFullName,
                          hintText: 'e.g. U Mg Mg',
                          prefixIcon: const Icon(Icons.person_pin_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomineeNrcController,
                        decoration: InputDecoration(
                          labelText: l10n.nomineeNrc,
                          hintText: 'e.g. 12/DAGANA(N)654321',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomineeRelationController,
                        decoration: InputDecoration(
                          labelText: l10n.nomineeRelation,
                          hintText: 'e.g. Spouse / Son / Daughter',
                          prefixIcon: const Icon(Icons.family_restroom_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  l10n.confirmOpenPassbook,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
