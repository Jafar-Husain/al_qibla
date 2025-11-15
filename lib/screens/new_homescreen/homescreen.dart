import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'widgets/appbar.dart';
import 'widgets/home_menu_button_row.dart';
import 'widgets/home_top_info.dart';
import 'widgets/prayer_container.dart';

import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/navbar.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with WidgetsBindingObserver {
  HomeMenuTab _selectedTab = HomeMenuTab.prayerTimes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize prayer data similar to legacy HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).initStateHomePage();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<AppProvider>(context, listen: false)
          .getPrayerTimes(refresh: true);
    }
  }

  Widget _buildTabContent(AppProvider appProvider, bool isDarkMode) {
    switch (_selectedTab) {
      case HomeMenuTab.prayerTimes:
        return _buildPrayerTimesContent(appProvider, isDarkMode);
      case HomeMenuTab.calendar:
        return _buildPlaceholderContent('Calendar', isDarkMode);
      case HomeMenuTab.information:
        return _buildPlaceholderContent('Missed Prayers', isDarkMode);
      case HomeMenuTab.events:
        return _buildPlaceholderContent('Events', isDarkMode);
    }
  }

  Widget _buildPrayerTimesContent(
    AppProvider appProvider,
    bool isDarkMode,
  ) {
    // Build from AppProvider.prayerTimesList
    final times = appProvider.prayerTimesList;
    final is24h = appProvider.getTimeFormat24();
    final timeFmt = is24h ? DateFormat('HH:mm') : DateFormat('h:mm a');

    String fmt(int index) {
      if (times.isEmpty || index < 0 || index >= times.length) return '--:--';
      final dt = times[index];
      if (dt is DateTime) return timeFmt.format(dt);
      try {
        return timeFmt.format((dt) as DateTime);
      } catch (_) {
        return '--:--';
      }
    }

    bool isNext(String name) {
      final next = (appProvider.nextPrayerName ?? '').toString().toLowerCase();
      return next == name.toLowerCase();
    }

    const double tileHeight = 108;
    if (times.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // Only the list scrolls
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Fajr',
            prayerTime: fmt(0),
            isCurrentPrayer: isNext('fajr'),
            notificationEnabled: appProvider.getFajrNotification(),
            onNotificationToggle: (value) {
              appProvider.togglePrayerNotification('Fajr', value);
            },
          ),
        ),
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Sunrise',
            prayerTime: fmt(1),
            isCurrentPrayer: isNext('sunrise'),
            // No notification for sunrise
          ),
        ),
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Dhuhr',
            prayerTime: fmt(2),
            isCurrentPrayer: isNext('dhuhr'),
            notificationEnabled: appProvider.getDhuhrNotification(),
            onNotificationToggle: (value) {
              appProvider.togglePrayerNotification('Dhuhr', value);
            },
          ),
        ),
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Asr',
            prayerTime: fmt(3),
            isCurrentPrayer: isNext('asr'),
            notificationEnabled: appProvider.getAsrNotification(),
            onNotificationToggle: (value) {
              appProvider.togglePrayerNotification('Asr', value);
            },
          ),
        ),
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Maghrib',
            prayerTime: fmt(4),
            isCurrentPrayer: isNext('maghrib'),
            notificationEnabled: appProvider.getMaghribNotification(),
            onNotificationToggle: (value) {
              appProvider.togglePrayerNotification('Maghrib', value);
            },
          ),
        ),
        SizedBox(
          height: tileHeight,
          child: PrayerContainer(
            prayerName: 'Isha',
            prayerTime: fmt(5),
            isCurrentPrayer: isNext('isha'),
            notificationEnabled: appProvider.getIshaNotification(),
            onNotificationToggle: (value) {
              appProvider.togglePrayerNotification('Isha', value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent(String title, bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: isDarkMode ? Colors.white30 : Colors.black26,
              ),
              const SizedBox(height: 16),
              Text(
                '$title Coming Soon',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This feature is under development',
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Reserve space for nav bar
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppTheme.getCurrentBackgroundColor(isDarkMode);
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: [
              // Main content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // App Bar
                    HomeAppBar(isDarkMode: isDarkMode),
                    SizedBox(height: 10),

                    // Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_selectedTab == HomeMenuTab.prayerTimes) ...[
                              HomeTopInfo(isDarkMode: isDarkMode),
                              const SizedBox(height: 10),
                            ],
                            HomeMenuButtonRow(
                              isDarkMode: isDarkMode,
                              selectedTab: _selectedTab,
                              onTabSelected: (HomeMenuTab tab) {
                                setState(() {
                                  _selectedTab = tab;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            // Only content area scrolls when needed
                            Expanded(
                              child: _buildTabContent(
                                appProvider,
                                isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: BottomNavigationWidget(selectedIndex: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
