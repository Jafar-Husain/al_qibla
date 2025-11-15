import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

import 'widgets/appbar.dart';
import 'widgets/home_menu_button_row.dart';
import 'widgets/home_top_info.dart';
import 'widgets/prayer_container.dart';

import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/navbar.dart';
import 'package:al_qibla/widgets/missed_prayer_container.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with WidgetsBindingObserver {
  HomeMenuTab _selectedTab = HomeMenuTab.prayerTimes;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<DateTime> _calendarPrayersList = List.generate(6, (_) => DateTime.now());

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
        return _buildCalendarContent(appProvider, isDarkMode);
      case HomeMenuTab.information:
        return _buildMissedPrayersContent(appProvider, isDarkMode);
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
      final current =
          (appProvider.currentPrayerName ?? '').toString().toLowerCase();
      return current == name.toLowerCase();
    }

    const double tileHeight = 108;
    if (times.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // Only the list scrolls
    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
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

  Widget _buildMissedPrayersContent(
    AppProvider appProvider,
    bool isDarkMode,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
      children: [
        MissedContainer(
          prayerName: "Fajr",
          missedNumber: appProvider.fajrMissed(),
          Color1: appProvider.firstGrad[0],
          Color2: appProvider.secondGrad[0],
          onClickAction: () {
            appProvider.setFajrMissed(appProvider.fajrMissed() + 1);
          },
          onClickMinus: () {
            appProvider.setFajrMissed(appProvider.fajrMissed() - 1);
          },
          onClickEdit: () {
            _showInputDialog(context, appProvider, 0);
          },
        ),
        MissedContainer(
          prayerName: "Dhuhr",
          missedNumber: appProvider.dhuhrMissed(),
          Color1: appProvider.firstGrad[2],
          Color2: appProvider.secondGrad[2],
          onClickAction: () {
            appProvider.setDhuhrMissed(appProvider.dhuhrMissed() + 1);
          },
          onClickMinus: () {
            appProvider.setDhuhrMissed(appProvider.dhuhrMissed() - 1);
          },
          onClickEdit: () {
            _showInputDialog(context, appProvider, 1);
          },
        ),
        MissedContainer(
          prayerName: "Asr",
          missedNumber: appProvider.asrMissed(),
          Color1: appProvider.firstGrad[3],
          Color2: appProvider.secondGrad[3],
          onClickAction: () {
            appProvider.setAsrMissed(appProvider.asrMissed() + 1);
          },
          onClickMinus: () {
            appProvider.setAsrMissed(appProvider.asrMissed() - 1);
          },
          onClickEdit: () {
            _showInputDialog(context, appProvider, 2);
          },
        ),
        MissedContainer(
          prayerName: "Maghrib",
          missedNumber: appProvider.maghribMissed(),
          Color1: appProvider.firstGrad[4],
          Color2: appProvider.secondGrad[4],
          onClickAction: () {
            appProvider.setMaghribMissed(appProvider.maghribMissed() + 1);
          },
          onClickMinus: () {
            appProvider.setMaghribMissed(appProvider.maghribMissed() - 1);
          },
          onClickEdit: () {
            _showInputDialog(context, appProvider, 3);
          },
        ),
        MissedContainer(
          prayerName: "Isha",
          missedNumber: appProvider.ishaMissed(),
          Color1: appProvider.firstGrad[5],
          Color2: appProvider.secondGrad[5],
          onClickAction: () {
            appProvider.setIshaMissed(appProvider.ishaMissed() + 1);
          },
          onClickMinus: () {
            appProvider.setIshaMissed(appProvider.ishaMissed() - 1);
          },
          onClickEdit: () {
            _showInputDialog(context, appProvider, 4);
          },
        ),
      ],
    );
  }

  Future<void> _showInputDialog(
      BuildContext context, AppProvider appProvider, int prayerInt) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String inputValue = '';

    // Set the default value based on the prayerInt
    int defaultValue;
    if (prayerInt == 0) {
      defaultValue = appProvider.fajrMissed();
    } else if (prayerInt == 1) {
      defaultValue = appProvider.dhuhrMissed();
    } else if (prayerInt == 2) {
      defaultValue = appProvider.asrMissed();
    } else if (prayerInt == 3) {
      defaultValue = appProvider.maghribMissed();
    } else {
      defaultValue = appProvider.ishaMissed();
    }

    // Initialize the TextEditingController with the default value
    final TextEditingController textController =
        TextEditingController(text: defaultValue.toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? AppTheme.darkBigContainer
              : AppTheme.getCurrentBackgroundColor(isDarkMode),
          title: Text(
            'Enter Value',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.primaryColor,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              inputValue = value;
            },
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Set',
                style: TextStyle(
                  color:
                      isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor,
                ),
              ),
              onPressed: () {
                inputValue =
                    inputValue.isEmpty ? defaultValue.toString() : inputValue;

                if (prayerInt == 0) {
                  appProvider.setFajrMissed(int.parse(inputValue));
                } else if (prayerInt == 1) {
                  appProvider.setDhuhrMissed(int.parse(inputValue));
                } else if (prayerInt == 2) {
                  appProvider.setAsrMissed(int.parse(inputValue));
                } else if (prayerInt == 3) {
                  appProvider.setMaghribMissed(int.parse(inputValue));
                } else if (prayerInt == 4) {
                  appProvider.setIshaMissed(int.parse(inputValue));
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarContent(AppProvider appProvider, bool isDarkMode) {
    return FutureBuilder<List<DateTime>>(
      future: _loadPrayerTimesForSelectedDay(appProvider),
      builder: (context, snapshot) {
        final prayerTimes = snapshot.data ?? _calendarPrayersList;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120, left: 20, right: 20),
          child: Column(
            children: [
              SizedBox(height: 10),
              _buildCalendarWidget(isDarkMode),
              SizedBox(height: 24),
              _buildPrayerTimesCard(appProvider, prayerTimes, isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Future<List<DateTime>> _loadPrayerTimesForSelectedDay(AppProvider appProvider) async {
    final prayerT = await appProvider.calculatePrayerTimes(
      appProvider.getLatitude(),
      appProvider.getLongitude(),
      appProvider.getMethod(),
      appProvider.getMadhab(),
      appProvider.getHighLatitudeRule(),
      _selectedDay,
    );

    final times = await appProvider.calculatePrayerTimeFromPrayerTimes(prayerT);
    setState(() {
      _calendarPrayersList = times;
    });
    return times;
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  Widget _buildCalendarWidget(bool isDarkMode) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSmallContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(isDarkMode),
          SizedBox(height: 12),
          _buildCalendarGrid(isDarkMode, firstWeekday, daysInMonth),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(
            Icons.chevron_left,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(bool isDarkMode, int firstWeekday, int daysInMonth) {
    // Calculate the actual number of weeks needed for this month
    final totalCells = firstWeekday + daysInMonth;
    final numberOfWeeks = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 8),
        ...List.generate(numberOfWeeks, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Expanded(child: SizedBox(height: 36));
                }

                final date = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                final isSelected = date.year == _selectedDay.year &&
                    date.month == _selectedDay.month &&
                    date.day == _selectedDay.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDaySelected(date),
                    child: Container(
                      height: 36,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
                            : isToday
                                ? (isDarkMode
                                    ? AppTheme.darkPrimaryColor.withOpacity(0.2)
                                    : AppTheme.primaryColor.withOpacity(0.1))
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: isDarkMode
                                    ? AppTheme.darkPrimaryColor
                                    : AppTheme.primaryColor,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? (isDarkMode ? Colors.black : Colors.white)
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPrayerTimesCard(AppProvider appProvider, List<DateTime> prayerTimes, bool isDarkMode) {
    DateFormat customDateFormat = appProvider.getTimeFormat24()
        ? DateFormat('HH:mm')
        : DateFormat('h:mm a');

    List<String> prayerNames = ["Fajr", "Duhr", "Asr", "Maghrib", "Isha"];
    List<int> prayerIndices = [0, 2, 3, 4, 5];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSmallContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE MMM d yyyy').format(_selectedDay),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(prayerNames.length, (i) {
              final index = prayerIndices[i];
              return Column(
                children: [
                  Text(
                    prayerNames[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    customDateFormat.format(prayerTimes[index]),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
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
