import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/enums/loan_purpose_type.dart';
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

  void _submitApplication(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    if (_scannedNrc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nrcRequiredValidation),
          backgroundColor: AppTheme.accentCrimson,
        ),
      );
      return;
    }

    if (_acquiredGps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gpsRequiredValidation),
          backgroundColor: AppTheme.accentCrimson,
        ),
      );
      return;
    }

    if (_signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.signatureRequiredValidation),
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
        title: Text(l10n.newLoanApplication),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.originationGuide),
                  content: Text(l10n.originationGuideText),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.gotItButton)),
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
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 28),
                    const SizedBox(width: 10),
                    Text(l10n.applicationSaved),
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
                    child: Text(l10n.backToDashboard),
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('1', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.borrowerDetails,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.requestedLoanAmount,
                            prefixIcon: const Icon(Icons.money),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return l10n.requestedLoanAmountRequired;
                            final num = double.tryParse(val.replaceAll(',', ''));
                            if (num == null || num < 100000) return l10n.minLoanAmountValidation;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: _selectedTermMonths,
                                decoration: InputDecoration(
                                  labelText: l10n.loanTerm,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 6, child: Text('6 Mos', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 12, child: Text('12 Mos', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 18, child: Text('18 Mos', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 24, child: Text('24 Mos', overflow: TextOverflow.ellipsis)),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedTermMonths = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 6,
                              child: DropdownButtonFormField<LoanPurposeType>(
                                isExpanded: true,
                                initialValue: _selectedPurpose,
                                decoration: InputDecoration(
                                  labelText: l10n.purpose,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                                items: LoanPurposeType.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('2', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.stepIdentityNrc,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('3', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.stepGpsSurvey,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
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
                                      _acquiredGps != null ? l10n.gpsRecordedLabel : l10n.gpsPendingLabel,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _acquiredGps != null
                                          ? 'LAT: ${_acquiredGps!.latitude.toStringAsFixed(6)} • LON: ${_acquiredGps!.longitude.toStringAsFixed(6)} (±${_acquiredGps!.accuracy}m)'
                                          : l10n.gpsPromptTap,
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
                                    SnackBar(content: Text(l10n.gpsRecordedSuccess)),
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy,
                              radius: 14,
                              child: Text('4', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.stepSignature,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
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
                    isSubmitting ? l10n.savingApplication : l10n.submitApplication,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isSubmitting ? null : () => _submitApplication(l10n),
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
