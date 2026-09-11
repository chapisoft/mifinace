import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';

enum IncidentType {
  hospitalization(label: 'Hospitalization / Medical Treatment', allowanceDailyMmk: 10000),
  naturalDisaster(label: 'Flood / Fire / Natural Disaster', allowanceDailyMmk: 150000),
  lossOfLife(label: 'Bereavement / Mutual Relief', allowanceDailyMmk: 300000);

  final String label;
  final double allowanceDailyMmk;

  const IncidentType({required this.label, required this.allowanceDailyMmk});
}

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
  IncidentType _selectedIncident = IncidentType.hospitalization;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Aid Claim'),
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
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety, color: CustomerTheme.primaryNavy, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BMF Mutual Welfare Protection',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CustomerTheme.primaryNavy),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Compulsory coverage covers hospital allowance and disaster relief for all active borrowers.',
                            style: TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Incident Type',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<IncidentType>(
                value: _selectedIncident,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: IncidentType.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedIncident = v);
                },
              ),
              const SizedBox(height: 18),

              const Text(
                'Hospital / Clinic Name',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                  hintText: 'e.g. Township General Hospital',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 18),

              const Text(
                'Duration of Hospitalization (Days)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  hintText: 'e.g. 3',
                  suffixText: 'Days',
                ),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Minimum 1 day' : null,
              ),
              const SizedBox(height: 24),

              // Upload Medical Documents Mock
              const Text(
                'Medical Proof / Village Leader Signature',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: CustomerTheme.borderSubtle, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 40, color: CustomerTheme.primaryNavy),
                    const SizedBox(height: 8),
                    const Text('Attach Medical Record or Discharge Slip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('1 document attached (simulated)', style: TextStyle(fontSize: 11, color: CustomerTheme.statusCurrent)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primaryNavy,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Insurance Claim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitClaim() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Claim Filed Successfully'),
            content: const Text(
              'Your mutual welfare claim reference is CLM-2026-0891. The township credit officer will review and disburse allowance within 48 hours.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primaryNavy),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      });
    }
  }
}
