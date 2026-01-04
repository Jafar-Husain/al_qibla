import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/home_screen.dart';
import 'package:al_qibla/screens/settings_screen.dart';
import 'package:al_qibla/screens/missedPrayer_screen.dart';
import 'package:al_qibla/screens/new_calendar_screen.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:provider/provider.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int selectedIndex;
  final bool useGlassmorphism;

  const BottomNavigationWidget({
    super.key,
    this.selectedIndex = 0,
    this.useGlassmorphism = false,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Navigation items container
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: widget.useGlassmorphism
                  ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: widget.useGlassmorphism
                      ? Colors.white.withOpacity(0.15)
                      : (isDarkMode
                          ? AppTheme.darkSmallContainer
                          : Colors.white),
                  borderRadius: BorderRadius.circular(50),
                  border: widget.useGlassmorphism
                      ? Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1)
                      : null,
                  boxShadow: widget.useGlassmorphism
                      ? null
                      : [
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
                    const SizedBox(width: 4),
                    // Calendar Screen
                    _buildNavigationItem(
                      icon: Icons.calendar_month_outlined,
                      selectedIcon: Icons.calendar_month,
                      isSelected: widget.selectedIndex == 1,
                      onTap: () {
                        if (widget.selectedIndex != 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewCalendarScreen(
                                latitude: appProvider.getLatitude(),
                                longitude: appProvider.getLongitude(),
                                local: true,
                              ),
                            ),
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 4),
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
                                  const HomeScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 4),
                    // Missed Prayers Screen
                    _buildNavigationItem(
                      icon: Icons.history_outlined,
                      selectedIcon: Icons.history,
                      isSelected: widget.selectedIndex == 3,
                      onTap: () {
                        if (widget.selectedIndex != 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MissedPrayerScreen(),
                            ),
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 4),
                    // Settings Screen
                    _buildNavigationItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      isSelected: widget.selectedIndex == 4,
                      onTap: () {
                        if (widget.selectedIndex != 4) {
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
    final useGlass = widget.useGlassmorphism;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isSelected
              ? (useGlass
                  ? Colors.white.withOpacity(0.25)
                  : (isDarkMode
                      ? AppTheme.getCurrentPrimaryColor(isDarkMode)
                          .withValues(alpha: 0.2)
                      : AppTheme.smallContainer))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? (selectedIcon ?? icon) : icon,
          color: isSelected
              ? (useGlass
                  ? Colors.white
                  : (isDarkMode
                      ? AppTheme.getCurrentPrimaryColor(isDarkMode)
                      : AppTheme.primaryColor))
              : (useGlass
                  ? Colors.white70
                  : (isDarkMode ? Colors.white54 : AppTheme.secondaryColor)),
          size: 24,
        ),
      ),
    );
  }
}
