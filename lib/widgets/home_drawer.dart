import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/screens/home_screen.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/new_calendar_screen.dart';
import 'package:al_qibla/screens/missedPrayer_screen.dart';
import 'package:al_qibla/screens/citites_screen.dart';
import 'package:al_qibla/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  final int selectedIndex;

  const HomeDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);

    return Drawer(
      backgroundColor: isDarkMode ? AppTheme.darkBigContainer : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with app name
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Al Qibla',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appProvider.getCityName(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    isSelected: selectedIndex == 0,
                    isDarkMode: isDarkMode,
                    onTap: () => _navigateTo(context, const HomeScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.explore_rounded,
                    title: 'Qibla Compass',
                    isSelected: selectedIndex == 1,
                    isDarkMode: isDarkMode,
                    onTap: () => _navigateTo(context, const QiblaScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Calendar',
                    isSelected: selectedIndex == 2,
                    isDarkMode: isDarkMode,
                    onTap: () => _navigateTo(
                      context,
                      NewCalendarScreen(
                        latitude: appProvider.getLatitude(),
                        longitude: appProvider.getLongitude(),
                        local: true,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    title: 'Missed Prayers',
                    isSelected: selectedIndex == 3,
                    isDarkMode: isDarkMode,
                    onTap: () =>
                        _navigateTo(context, const MissedPrayerScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.location_city_rounded,
                    title: 'Cities',
                    isSelected: selectedIndex == 4,
                    isDarkMode: isDarkMode,
                    onTap: () async {
                      await appProvider.setMyCityCities();
                      if (context.mounted) {
                        _navigateTo(context, const CitiesScreen());
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    isSelected: selectedIndex == 5,
                    isDarkMode: isDarkMode,
                    onTap: () => _navigateTo(context, const SettingScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor)
              : (isDarkMode ? Colors.white60 : Colors.black54),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor)
                : (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
        selected: isSelected,
        selectedTileColor: isDarkMode
            ? AppTheme.accentColor.withOpacity(0.1)
            : AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
