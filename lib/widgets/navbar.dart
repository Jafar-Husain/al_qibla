import 'package:flutter/material.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/citites_screen.dart';
import 'package:al_qibla/screens/new_homescreen/homescreen.dart';
import 'package:al_qibla/screens/settings_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int selectedIndex;

  const BottomNavigationWidget({super.key, this.selectedIndex = 0});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Navigation items container
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSmallContainer : Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                // Qibla Screen
                _buildNavigationItem(
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                  isSelected: widget.selectedIndex == 0,
                  onTap: () {
                    if (widget.selectedIndex != 0) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const QiblaScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 8),
                // Cities Screen
                _buildNavigationItem(
                  icon: Icons.location_city_outlined,
                  selectedIcon: Icons.location_city,
                  isSelected: widget.selectedIndex == 1,
                  onTap: () {
                    if (widget.selectedIndex != 1) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const CitiesScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 8),
                // Home Screen
                _buildNavigationItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  isSelected: widget.selectedIndex == 2,
                  onTap: () {
                    if (widget.selectedIndex != 2) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const NewHomeScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 8),
                // Settings Screen
                _buildNavigationItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  isSelected: widget.selectedIndex == 3,
                  onTap: () {
                    if (widget.selectedIndex != 3) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const SettingScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    IconData? selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? AppTheme.getCurrentPrimaryColor(isDarkMode)
                      .withValues(alpha: 0.2)
                  : AppTheme.smallContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? (selectedIcon ?? icon) : icon,
          color: isSelected
              ? (isDarkMode
                  ? AppTheme.getCurrentPrimaryColor(isDarkMode)
                  : AppTheme.primaryColor)
              : (isDarkMode ? Colors.white54 : AppTheme.secondaryColor),
          size: 24,
        ),
      ),
    );
  }
}
