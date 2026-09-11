import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bmf_customer/app/router/app_router.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/bloc/language/language_cubit.dart';
import 'package:bmf_customer/core/bloc/language/language_state.dart';
import 'package:bmf_customer/core/enums/app_language.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';
import 'package:bmf_customer/features/home/presentation/widgets/due_loan_alert_card.dart';
import 'package:bmf_customer/features/home/presentation/widgets/member_card.dart';
import 'package:bmf_customer/features/home/presentation/widgets/quick_services_grid.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_event.dart';
import 'package:bmf_customer/features/loans/presentation/bloc/loan_state.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/loan_card.dart';

/// Main Customer Dashboard screen with Member Card, Due Loan Alerts and Quick Services.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final authState = context.read<CustomerAuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CustomerLoanBloc>().add(
            LoadActiveLoansRequested(authState.profile.nrcFormatted),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomerTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: CustomerTheme.secondaryAmber, size: 24),
            SizedBox(width: 8),
            Text(
              'BMF Customer Portal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Notifications Center Button
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRouter.notificationsRoute),
          ),
          // Language Switcher Button
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              final lang = langState.currentLanguage;
              return TextButton.icon(
                onPressed: () => _showLanguageDialog(context),
                icon: const Icon(Icons.language, color: Colors.white, size: 18),
                label: Text(
                  lang.code.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final member = authState.profile;

          return RefreshIndicator(
            color: CustomerTheme.primaryNavy,
            onRefresh: () async => _refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Digital ID Member Card
                  MemberCard(
                    member: member,
                    onQrTap: () => _showMemberQrModal(context, member),
                  ),

                  // Due Loan Alert Banner (if any loan has installment due soon)
                  BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
                    builder: (context, loanState) {
                      if (loanState is LoanListLoaded) {
                        final dueLoans = loanState.loans.where((l) => l.isDueSoon).toList();
                        if (dueLoans.isNotEmpty) {
                          return DueLoanAlertCard(
                            loan: dueLoans.first,
                            onPayNow: () => _navigateToPayment(context, dueLoans.first),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Quick Action Services Grid
                  QuickServicesGrid(
                    onMmqrPay: () => _onMmqrPayTap(context),
                    onLoanSchedule: () => context.push(AppRouter.loansRoute, extra: member.nrcFormatted),
                    onSavings: () => context.push(AppRouter.savingsRoute, extra: member.nrcFormatted),
                    onInsurance: () => context.push(AppRouter.insuranceClaimRoute, extra: member.nrcFormatted),
                  ),

                  const SizedBox(height: 12),

                  // Active Loans Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Loans',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CustomerTheme.textPrimary),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRouter.loansRoute, extra: member.nrcFormatted),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: CustomerTheme.primaryNavy, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loans List
                  BlocBuilder<CustomerLoanBloc, CustomerLoanState>(
                    builder: (context, loanState) {
                      if (loanState is LoanLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (loanState is LoanListLoaded) {
                        final loans = loanState.loans;
                        if (loans.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No active loan contracts.',
                                style: TextStyle(color: CustomerTheme.textSecondary),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: loans.length,
                          itemBuilder: (context, index) {
                            final loan = loans[index];
                            return LoanCard(
                              loan: loan,
                              onViewSchedule: () => context.push(AppRouter.loanScheduleRoute, extra: loan),
                              onPayNow: () => _navigateToPayment(context, loan),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToPayment(BuildContext context, CustomerLoan loan) {
    context.push(
      AppRouter.paymentQrRoute,
      extra: {
        'contractCode': loan.contractCode,
        'amountMmk': loan.nextDueAmountMmk > 0 ? loan.nextDueAmountMmk : 48000.0,
      },
    );
  }

  void _onMmqrPayTap(BuildContext context) {
    final loanState = context.read<CustomerLoanBloc>().state;
    if (loanState is LoanListLoaded && loanState.loans.isNotEmpty) {
      _navigateToPayment(context, loanState.loans.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active loan available for repayment')),
      );
    }
  }

  void _showMemberQrModal(BuildContext context, MemberProfile member) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Member QR Code', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: CustomerTheme.primaryNavy, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 140, color: CustomerTheme.primaryNavy),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.fullName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'NRC: ${member.nrcFormatted}',
                style: const TextStyle(fontSize: 12, color: CustomerTheme.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Language / ဘာသာစကား'),
          children: AppLanguage.values.map((lang) {
            return SimpleDialogOption(
              onPressed: () {
                context.read<LanguageCubit>().changeLanguage(lang);
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${lang.nativeName} (${lang.englishName})', style: const TextStyle(fontSize: 15)),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out from BMF Customer Portal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<CustomerAuthBloc>().add(const LogoutRequested());
                context.go(AppRouter.loginPinRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerTheme.accentCrimson,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
