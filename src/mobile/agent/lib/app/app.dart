import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/bloc/language/language_cubit.dart';
import '../core/bloc/language/language_state.dart';
import '../core/enums/app_language.dart';
import '../core/l10n/app_localizations.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/cash/presentation/bloc/cash_bloc.dart';
import '../features/centers/presentation/bloc/center_bloc.dart';
import '../features/collection/presentation/bloc/collection_bloc.dart';
import '../features/insurance/presentation/bloc/insurance_claim_bloc.dart';
import '../features/origination/presentation/bloc/origination_bloc.dart';
import '../features/printer/domain/services/bluetooth_printer_service.dart';
import '../features/printer/presentation/bloc/printer_bloc.dart';
import '../features/savings/presentation/bloc/saving_bloc.dart';
import '../features/sync/presentation/bloc/sync_bloc.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root Widget for BMF Agent Mobile Application.
class BmfAgentApp extends StatelessWidget {
  final LanguageCubit languageCubit;
  final AuthBloc? authBloc;
  final CenterBloc? centerBloc;
  final CollectionBloc? collectionBloc;
  final PrinterBloc? printerBloc;
  final SyncBloc? syncBloc;
  final OriginationBloc? originationBloc;
  final SavingBloc? savingBloc;
  final InsuranceClaimBloc? insuranceClaimBloc;
  final CashBloc? cashBloc;
  final BluetoothPrinterService? printerService;

  const BmfAgentApp({
    super.key,
    required this.languageCubit,
    this.authBloc,
    this.centerBloc,
    this.collectionBloc,
    this.printerBloc,
    this.syncBloc,
    this.originationBloc,
    this.savingBloc,
    this.insuranceClaimBloc,
    this.cashBloc,
    this.printerService,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: languageCubit),
        if (authBloc != null) BlocProvider.value(value: authBloc!),
        if (centerBloc != null) BlocProvider.value(value: centerBloc!),
        if (collectionBloc != null) BlocProvider.value(value: collectionBloc!),
        if (printerBloc != null) BlocProvider.value(value: printerBloc!),
        if (syncBloc != null) BlocProvider.value(value: syncBloc!),
        if (originationBloc != null) BlocProvider.value(value: originationBloc!),
        if (savingBloc != null) BlocProvider.value(value: savingBloc!),
        if (insuranceClaimBloc != null) BlocProvider.value(value: insuranceClaimBloc!),
        if (cashBloc != null) BlocProvider.value(value: cashBloc!),
      ],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'BMF Agent',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            locale: state.currentLanguage.locale,
            supportedLocales: AppLanguage.values.map((l) => l.locale).toList(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );

    if (printerService != null) {
      content = RepositoryProvider<BluetoothPrinterService>.value(
        value: printerService!,
        child: content,
      );
    }

    return content;
  }
}
