import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/core/l10n/customer_localizations.dart';
import 'package:bmf_customer/features/account/presentation/screens/account_screen.dart';
import 'package:bmf_customer/features/home/presentation/screens/home_screen.dart';
import 'package:bmf_customer/features/home/presentation/widgets/member_drawer.dart';
import 'package:bmf_customer/features/loans/presentation/screens/loan_list_screen.dart';
import 'package:bmf_customer/features/payments/presentation/screens/payment_qr_screen.dart';
import 'package:bmf_customer/features/payments/presentation/screens/transaction_history_screen.dart';

/// Main navigation screen hosting the 5-tab Bottom Navigation Bar and Member Drawer.
class MainNavigationScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigationScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _setTabIndex(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = CustomerLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MemberDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onOpenDrawer: _openDrawer,
            onNavigateTab: _setTabIndex,
          ),
          LoanListScreen(
            onOpenDrawer: _openDrawer,
          ),
          PaymentQrScreen(
            onOpenDrawer: _openDrawer,
          ),
          TransactionHistoryScreen(
            onOpenDrawer: _openDrawer,
          ),
          AccountScreen(
            onOpenDrawer: _openDrawer,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _setTabIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: CustomerTheme.primaryNavy,
            unselectedItemColor: CustomerTheme.textSecondary,
            selectedFontSize: 11.5,
            unselectedFontSize: 11.0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 1.4),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.home_outlined, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.home_rounded, size: 23, color: CustomerTheme.primaryNavy),
                ),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.account_balance_wallet_outlined, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.account_balance_wallet_rounded, size: 23, color: CustomerTheme.primaryNavy),
                ),
                label: l10n.navLoans,
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    color: CustomerTheme.accentTeal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CustomerTheme.accentTeal.withAlpha(90),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    color: CustomerTheme.primaryNavy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CustomerTheme.primaryNavy.withAlpha(90),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                ),
                label: l10n.navScanQr,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.receipt_long_outlined, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.receipt_long_rounded, size: 23, color: CustomerTheme.primaryNavy),
                ),
                label: l10n.navHistory,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.person_outline_rounded, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.person_rounded, size: 23, color: CustomerTheme.primaryNavy),
                ),
                label: l10n.navAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
