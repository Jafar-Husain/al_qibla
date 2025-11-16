// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:provider/provider.dart';

class NewCalendarScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool local;
  final String? cityName;

  const NewCalendarScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.local,
    this.cityName,
  });

  @override
  State<NewCalendarScreen> createState() => _NewCalendarScreenState();
}

class _NewCalendarScreenState extends State<NewCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<DateTime> prayersList = [
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
  ];

  @override
  void initState() {
    super.initState();
    _initializePrayerList();
  }

  Future<void> _initializePrayerList() async {
    if (!mounted) return;

    PrayerTimes prayerT = await Provider.of<AppProvider>(context, listen: false)
        .calculatePrayerTimes(
            widget.latitude,
            widget.longitude,
            Provider.of<AppProvider>(context, listen: false).getMethod(),
            Provider.of<AppProvider>(context, listen: false).getMadhab(),
            Provider.of<AppProvider>(context, listen: false)
                .getHighLatitudeRule(),
            _selectedDay);

    List<DateTime> prayersList2;
    if (widget.local == true) {
      prayersList2 = await Provider.of<AppProvider>(context, listen: false)
          .calculatePrayerTimeFromPrayerTimes(prayerT);
    } else {
      prayersList2 = await Provider.of<AppProvider>(context, listen: false)
          .calculateCityPrayerTimeFromPrayerTimes(
              prayerT, widget.latitude, widget.longitude);
    }

    if (mounted) {
      setState(() {
        prayersList = prayersList2;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
    _initializePrayerList();
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<AppProvider>(context).getIsDarkMode();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.getCurrentBackgroundColor(isDarkMode),
        appBar: CustomAppBar(
          title: "Calendar",
          backgroundColor: Colors.transparent,
          foregroundColor: isDarkMode ? Colors.white : AppTheme.primaryColor,
          showBackButton: true,
        ),
        body: SafeArea(
          child: _buildCalendarContent(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Calendar widget
          Container(
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
                _buildCalendarGrid(isDarkMode),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Selected date and prayer times
          _buildPrayerTimesCard(isDarkMode),

          SizedBox(height: 24),
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

  Widget _buildCalendarGrid(bool isDarkMode) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate the actual number of weeks needed for this month
    final totalCells = firstWeekday + daysInMonth;
    final numberOfWeeks = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
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

        // Calendar days grid
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

  Widget _buildPrayerTimesCard(bool isDarkMode) {
    DateFormat customDateFormat =
        Provider.of<AppProvider>(context).getTimeFormat24()
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');

    // Resolve city's timezone once for formatting
    tzdata.initializeTimeZones();
    final cityTzName =
        tzmap.latLngToTimezoneString(widget.latitude, widget.longitude);
    final cityLocation = tz.getLocation(cityTzName);

    DateTime toCity(DateTime dt) {
      final utc = dt.isUtc ? dt : dt.toUtc();
      return tz.TZDateTime.from(utc, cityLocation);
    }

    List<String> prayerNames = ["Fajr", "Duhr", "Asr", "Maghrib", "Isha"];
    List<int> prayerIndices = [0, 2, 3, 4, 5]; // Skip sunrise (index 1)

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
            widget.cityName != null
                ? '${DateFormat('EEE MMM d yyyy').format(widget.local ? _selectedDay : toCity(_selectedDay))} - ${widget.cityName}'
                : DateFormat('EEE MMM d yyyy').format(widget.local ? _selectedDay : toCity(_selectedDay)),
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
                    customDateFormat.format(widget.local
                        ? prayersList[index]
                        : toCity(prayersList[index])),
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
}
