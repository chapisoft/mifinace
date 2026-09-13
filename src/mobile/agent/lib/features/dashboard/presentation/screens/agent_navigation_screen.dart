import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../centers/presentation/screens/centers_screen.dart';
import '../../../origination/presentation/screens/loan_application_screen.dart';
import '../../../savings/presentation/screens/agent_saving_screen.dart';
import '../widgets/agent_drawer.dart';
import 'dashboard_screen.dart';
import 'officer_account_screen.dart';

/// Main Navigation Container for BMF Field Officer App hosting 5 Bottom Tabs and AgentDrawer.
class AgentNavigationScreen extends StatefulWidget {
  final int initialTabIndex;

  const AgentNavigationScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AgentNavigationScreen> createState() => _AgentNavigationScreenState();
}

class _AgentNavigationScreenState extends State<AgentNavigationScreen> {
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AgentDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onOpenDrawer: _openDrawer,
            onNavigateTab: _setTabIndex,
          ),
          const CentersScreen(),
          const LoanApplicationScreen(
            centerCode: 'C001',
            groupCode: 'G001',
          ),
          const AgentSavingScreen(),
          OfficerAccountScreen(
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
            selectedItemColor: AppTheme.primaryNavy,
            unselectedItemColor: AppTheme.textSecondary,
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
                  child: Icon(Icons.home_rounded, size: 23, color: AppTheme.primaryNavy),
                ),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.groups_outlined, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.groups_rounded, size: 23, color: AppTheme.primaryNavy),
                ),
                label: l10n.navCenters,
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentEmerald.withAlpha(90),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withAlpha(90),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                ),
                label: l10n.navNewLoan,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.account_balance_wallet_outlined, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.account_balance_wallet_rounded, size: 23, color: AppTheme.primaryNavy),
                ),
                label: l10n.navSavingsCash,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.person_outline_rounded, size: 23),
                ),
                activeIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Icon(Icons.person_rounded, size: 23, color: AppTheme.primaryNavy),
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
