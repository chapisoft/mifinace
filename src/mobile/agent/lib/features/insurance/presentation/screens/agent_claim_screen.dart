import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/claim_risk_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/insurance_claim_bloc.dart';
import '../bloc/insurance_claim_event.dart';
import '../bloc/insurance_claim_state.dart';

/// Screen for field credit officers to capture and submit mutual micro-insurance emergency claims.
class AgentClaimScreen extends StatefulWidget {
  final String centerCode;
  final String groupCode;

  const AgentClaimScreen({
    super.key,
    this.centerCode = 'C001',
    this.groupCode = 'G001',
  });

  @override
  State<AgentClaimScreen> createState() => _AgentClaimScreenState();
}

class _AgentClaimScreenState extends State<AgentClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  // Zero fake default values: controllers initialized empty
  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  ClaimRiskType _selectedRisk = ClaimRiskType.illness;
  final DateTime _incidentDate = DateTime.now();
  String? _villageLetterPath;
  String? _medicalReceiptPath;

  @override
  void dispose() {
    _nameController.dispose();
    _nrcController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitClaim() {
    if (!_formKey.currentState!.validate()) return;

    final double requestedAmount = CurrencyFormatter.parseMmk(_amountController.text).toDouble();

    context.read<InsuranceClaimBloc>().add(
          SubmitClaimRequested(
            memberNrc: _nrcController.text.trim(),
            memberName: _nameController.text.trim(),
            centerCode: widget.centerCode,
            groupCode: widget.groupCode,
            phone: _phoneController.text.trim(),
            riskType: _selectedRisk,
            incidentDate: _incidentDate,
            description: _descController.text.trim(),
            requestedAmountMmk: requestedAmount,
            villageHeadLetterPhotoPath: _villageLetterPath,
            medicalReceiptPhotoPath: _medicalReceiptPath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insuranceClaimTitle),
      ),
      body: BlocConsumer<InsuranceClaimBloc, InsuranceClaimState>(
        listener: (context, state) {
          if (state is InsuranceClaimSubmittedState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 28),
                    const SizedBox(width: 8),
                    Text(l10n.claimSubmittedTitle),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.claimReferenceCode}: ${state.claim.claimId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'Emergency assistance claim for ${state.claim.memberName} (${CurrencyFormatter.formatMmk(state.claim.requestedAmountMmk)}) has been enqueued locally and forwarded to Township branch for payout approval.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRouter.dashboardRoute);
                    },
                    child: Text(l10n.backToDashboard),
                  ),
                ],
              ),
            );
          } else if (state is InsuranceClaimError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppTheme.accentCrimson),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is InsuranceClaimLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section 1: Member & Incident Type
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
                          l10n.beneficiaryIncidentDetails,
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
                        DropdownButtonFormField<ClaimRiskType>(
                          isExpanded: true,
                          initialValue: _selectedRisk,
                          decoration: InputDecoration(
                            labelText: l10n.coveredRiskCategory,
                            prefixIcon: const Icon(Icons.health_and_safety_outlined),
                          ),
                          items: ClaimRiskType.values.map((risk) {
                            return DropdownMenuItem(
                              value: risk,
                              child: Text(
                                risk.localizedName(l10n),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRisk = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.requestedAssistanceAmount,
                            hintText: 'e.g. 150000',
                            prefixIcon: const Icon(Icons.money),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return l10n.claimAmountRequired;
                            final parsed = double.tryParse(val.replaceAll(',', ''));
                            if (parsed == null || parsed <= 0) return l10n.invalidAmountValidation;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.incidentDescription,
                            hintText: l10n.incidentDescriptionHint,
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? l10n.incidentDescriptionRequired : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Section 2: Evidentiary Documents
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
                          l10n.evidentiaryDocuments,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _villageLetterPath != null ? AppTheme.accentTeal.withAlpha(25) : AppTheme.backgroundLight,
                            child: Icon(
                              _villageLetterPath != null ? Icons.check : Icons.camera_alt_outlined,
                              color: _villageLetterPath != null ? AppTheme.accentTeal : AppTheme.textSecondary,
                            ),
                          ),
                          title: Text(l10n.villageHeadLetter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(_villageLetterPath != null ? l10n.letterAttached : l10n.tapToAttachLetter, style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _villageLetterPath = '/data/user/photos/village_head_letter.jpg';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.letterAttachedToast)),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _medicalReceiptPath != null ? AppTheme.accentTeal.withAlpha(25) : AppTheme.backgroundLight,
                            child: Icon(
                              _medicalReceiptPath != null ? Icons.check : Icons.receipt_long_outlined,
                              color: _medicalReceiptPath != null ? AppTheme.accentTeal : AppTheme.textSecondary,
                            ),
                          ),
                          title: Text(l10n.medicalReceipt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(_medicalReceiptPath != null ? l10n.receiptAttached : l10n.tapToAttachReceipt, style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _medicalReceiptPath = '/data/user/photos/hospital_receipt.jpg';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.receiptAttachedToast)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCrimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_outlined, size: 20),
                  label: Text(
                    isSubmitting ? l10n.submittingClaim : l10n.submitEmergencyClaim,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isSubmitting ? null : _submitClaim,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
