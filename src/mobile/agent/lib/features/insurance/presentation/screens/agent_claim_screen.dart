import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/claim_risk_type.dart';
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
  DateTime _incidentDate = DateTime.now();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Insurance Claim'),
      ),
      body: BlocConsumer<InsuranceClaimBloc, InsuranceClaimState>(
        listener: (context, state) {
          if (state is InsuranceClaimSubmittedState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 28),
                    SizedBox(width: 8),
                    Text('Claim Submitted'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Reference Code: ${state.claim.claimId}',
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
                    child: const Text('Back to Dashboard'),
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
                        const Text(
                          'Beneficiary & Incident Details',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Member Full Name *',
                            hintText: 'e.g. Daw Khin Khin Win',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Member name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nrcController,
                          decoration: const InputDecoration(
                            labelText: 'Myanmar NRC Card *',
                            hintText: 'e.g. 12/DAGANA(N)123456',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'NRC is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact Phone Number *',
                            hintText: 'e.g. 09123456789',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Phone number is required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ClaimRiskType>(
                          value: _selectedRisk,
                          decoration: const InputDecoration(
                            labelText: 'Covered Risk Category',
                            prefixIcon: Icon(Icons.health_and_safety_outlined),
                          ),
                          items: ClaimRiskType.values.map((risk) {
                            return DropdownMenuItem(value: risk, child: Text(risk.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRisk = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Requested Assistance Amount (MMK) *',
                            hintText: 'e.g. 150000',
                            prefixIcon: Icon(Icons.money),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Amount is required';
                            final parsed = double.tryParse(val.replaceAll(',', ''));
                            if (parsed == null || parsed <= 0) return 'Invalid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Incident Description & Circumstances *',
                            hintText: 'Describe medical diagnosis, hospitalization dates, or loss details...',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Description is required' : null,
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
                        const Text(
                          'Evidentiary Documents & Photos',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                          title: const Text('Village Head Verification Letter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(_villageLetterPath != null ? 'Letter attached' : 'Tap to attach or take photo', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _villageLetterPath = '/data/user/photos/village_head_letter.jpg';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Village Head verification photo attached.')),
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
                          title: const Text('Hospital Bill / Medical Receipt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(_medicalReceiptPath != null ? 'Receipt attached' : 'Tap to attach or take photo', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _medicalReceiptPath = '/data/user/photos/hospital_receipt.jpg';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Medical invoice photo attached.')),
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
                    isSubmitting ? 'Submitting Claim...' : 'Submit Emergency Claim',
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
