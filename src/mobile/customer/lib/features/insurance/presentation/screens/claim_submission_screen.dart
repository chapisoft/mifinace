import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';

/// Screen allowing borrowers to file mutual-aid insurance claim online.
class ClaimSubmissionScreen extends StatefulWidget {
  final String memberNrc;

  const ClaimSubmissionScreen({super.key, required this.memberNrc});

  @override
  State<ClaimSubmissionScreen> createState() => _ClaimSubmissionScreenState();
}

class _ClaimSubmissionScreenState extends State<ClaimSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _daysController = TextEditingController(text: '3');
  int _selectedIncidentIndex = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    final incidentOptions = [
      l10n.illnessRisk,
      l10n.accidentRisk,
      l10n.naturalDisasterRisk,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mutualAidClaimTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Benefit Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: CustomerTheme.primaryNavy, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.medicalBenefitTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CustomerTheme.primaryNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.medicalBenefitDesc,
                            style: const TextStyle(fontSize: 11.5, color: CustomerTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                initialValue: _selectedIncidentIndex,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.menuInsuranceTitle,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: List.generate(incidentOptions.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      incidentOptions[i],
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedIncidentIndex = v);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: l10n.attachMedicalDocument,
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  hintText: 'Township General Hospital',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.inputIdentifierRequired : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.period,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  hintText: '3',
                ),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? '1+' : null,
              ),
              const SizedBox(height: 20),

              // Upload Medical Documents
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: CustomerTheme.borderSubtle),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 36, color: CustomerTheme.primaryNavy),
                    const SizedBox(height: 8),
                    Text(l10n.attachMedicalDocument, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Text(l10n.documentAttachedSimulated, style: const TextStyle(fontSize: 11, color: CustomerTheme.statusCurrent)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitClaim(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.submitInsuranceClaim, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitClaim(CustomerLocalizations l10n) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.claimFiledSuccess, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Text(
              '${l10n.referenceNo}: CLM-2026-0891.\n${l10n.medicalBenefitDesc}',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy, foregroundColor: Colors.white),
                child: Text(l10n.done),
              ),
            ],
          ),
        );
      });
    }
  }
}
