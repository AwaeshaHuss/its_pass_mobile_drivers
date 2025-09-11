import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/pages/earnings/earning_page.dart';
import 'package:itspass_driver/pages/home/home_page.dart';
import 'package:itspass_driver/pages/profile/profile_page.dart';
import 'package:itspass_driver/pages/trips/trips_page.dart';
import '../providers/dashboard_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            const HomePage(),
            const EarningsPage(),
            TripsPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: dashboardProvider.selectedIndex == 0,
                    onTap: () => _onNavTap(0, dashboardProvider),
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    label: 'Earnings',
                    index: 1,
                    isSelected: dashboardProvider.selectedIndex == 1,
                    onTap: () => _onNavTap(1, dashboardProvider),
                  ),
                  _buildNavItem(
                    icon: Icons.route_outlined,
                    activeIcon: Icons.route,
                    label: 'Trips',
                    index: 2,
                    isSelected: dashboardProvider.selectedIndex == 2,
                    onTap: () => _onNavTap(2, dashboardProvider),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    index: 3,
                    isSelected: dashboardProvider.selectedIndex == 3,
                    onTap: () => _onNavTap(3, dashboardProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onNavTap(int index, DashboardProvider provider) {
    provider.setIndex(index);
    controller!.animateTo(index);
  }
}
