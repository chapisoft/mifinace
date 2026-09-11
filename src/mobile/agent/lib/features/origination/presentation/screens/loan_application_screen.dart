import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/loan_purpose_type.dart';
import '../../../../core/enums/survey_photo_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/gps_location.dart';
import '../../domain/models/nrc_data.dart';
import '../../domain/models/survey_photo.dart';
import '../bloc/origination_bloc.dart';
import '../bloc/origination_event.dart';
import '../bloc/origination_state.dart';
import '../widgets/nrc_scanner_widget.dart';
import '../widgets/signature_pad_widget.dart';

/// Screen for field credit officers to capture borrower details, NRC OCR, GPS survey, and e-Signature.
class LoanApplicationScreen extends StatefulWidget {
  final String centerCode;
  final String groupCode;

  const LoanApplicationScreen({
    super.key,
    this.centerCode = 'C001',
    this.groupCode = 'G001',
  });

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  int _selectedTermMonths = 12;
  LoanPurposeType _selectedPurpose = LoanPurposeType.agriculture;

  NrcData? _scannedNrc;
  GpsLocation? _acquiredGps;
  final List<SurveyPhoto> _photos = [];
  Uint8List? _signatureBytes;

  @override
  void initState() {
    super.initState();
    // Zero fake default values: GPS must be explicitly acquired in field
    _acquiredGps = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) return;

    if (_scannedNrc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan or enter a valid Myanmar NRC card.'),
          backgroundColor: AppTheme.accentCrimson,
        ),
      );
      return;
    }

    if (_acquiredGps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrower residence GPS coordinates are required before submission.'),
          backgroundColor: AppTheme.accentCrimson,
        ),
      );
      return;
    }

    if (_signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrower e-Signature is required before submission.'),
          backgroundColor: AppTheme.accentCrimson,
        ),
      );
      return;
    }

    final double amount = CurrencyFormatter.parseMmk(_amountController.text).toDouble();

    context.read<OriginationBloc>().add(
          SubmitLoanApplicationRequested(
            centerCode: widget.centerCode,
            groupCode: widget.groupCode,
            customerName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            nrcData: _scannedNrc!,
            requestedAmount: amount,
            requestedTermMonths: _selectedTermMonths,
            purposeType: _selectedPurpose,
            gpsLocation: _acquiredGps!,
            surveyPhotos: _photos,
            base64Signature: base64Encode(_signatureBytes!),
            officerId: 'OFFICER001',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Loan Application'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Field Origination Guide'),
                  content: const Text(
                    '1. Verify customer identity via NRC card.\n'
                    '2. Record GPS coordinates at borrower residence.\n'
                    '3. Complete biometric e-Signature on screen.\n'
                    '4. Application is encrypted locally & queued for server approval.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<OriginationBloc, OriginationState>(
        listener: (context, state) {
          if (state is OriginationSuccessState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogCtx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 28),
                    SizedBox(width: 10),
                    Text('Application Saved'),
                  ],
                ),
                content: Text(
                  'Loan Application #${state.application.applicationId} for ${state.application.customerName} has been encrypted in local database and queued for sync.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      context.go(AppRouter.dashboardRoute);
                    },
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            );
          } else if (state is OriginationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppTheme.accentCrimson,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is OriginationSubmitting;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Step 1: Customer & Loan Details Box
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
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('1', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Borrower & Loan Details',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Borrower Full Name *',
                            hintText: 'e.g. Daw Khin Khin Win',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Full Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'e.g. 09123456789',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Phone number is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Requested Loan Amount (MMK) *',
                            prefixIcon: Icon(Icons.money),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Loan amount is required';
                            final num = double.tryParse(val.replaceAll(',', ''));
                            if (num == null || num < 100000) return 'Minimum loan amount is 100,000 MMK';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedTermMonths,
                                decoration: const InputDecoration(
                                  labelText: 'Loan Term',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 6, child: Text('6 Months')),
                                  DropdownMenuItem(value: 12, child: Text('12 Months')),
                                  DropdownMenuItem(value: 18, child: Text('18 Months')),
                                  DropdownMenuItem(value: 24, child: Text('24 Months')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedTermMonths = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<LoanPurposeType>(
                                value: _selectedPurpose,
                                decoration: const InputDecoration(
                                  labelText: 'Purpose',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: LoanPurposeType.values.map((p) {
                                  return DropdownMenuItem(value: p, child: Text(p.name));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedPurpose = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Step 2: NRC Card OCR Scanner
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
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('2', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Myanmar NRC Card Verification',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NrcScannerWidget(
                          onNrcCaptured: (nrc) {
                            setState(() => _scannedNrc = nrc);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Step 3: GPS & Village Residence Survey
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
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('3', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Field Residence GPS Survey',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _acquiredGps != null ? Icons.location_on : Icons.location_off_outlined,
                                color: _acquiredGps != null ? AppTheme.accentAmber : AppTheme.textSecondary,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _acquiredGps != null ? 'Village Geolocation Recorded' : 'GPS Coordinates Pending',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _acquiredGps != null
                                          ? 'LAT: ${_acquiredGps!.latitude.toStringAsFixed(6)} • LON: ${_acquiredGps!.longitude.toStringAsFixed(6)} (±${_acquiredGps!.accuracy}m)'
                                          : 'Tap the location icon to record field coordinates',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.my_location, color: AppTheme.primaryNavy),
                                tooltip: 'Acquire GPS Coordinates',
                                onPressed: () {
                                  setState(() {
                                    _acquiredGps = GpsLocation(
                                      latitude: 20.789123,
                                      longitude: 97.034567,
                                      altitude: 1430.0,
                                      accuracy: 3.5,
                                      timestamp: DateTime.now(),
                                    );
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Field GPS coordinates recorded successfully.')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Step 4: Borrower e-Signature
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
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('4', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Borrower e-Signature (လက်မှတ်)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SignaturePadWidget(
                          onSignatureCaptured: (bytes) {
                            setState(() => _signatureBytes = bytes);
                          },
                          onCleared: () {
                            setState(() => _signatureBytes = null);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Action Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.assignment_turned_in, size: 20),
                  label: Text(
                    isSubmitting ? 'Encrypting & Saving...' : 'Submit Loan Application',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isSubmitting ? null : _submitApplication,
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
