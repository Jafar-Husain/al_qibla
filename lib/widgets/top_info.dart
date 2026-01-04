import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class topInfo extends StatefulWidget {
  topInfo({super.key});

  @override
  State<topInfo> createState() => _topInfoState();
}

class _topInfoState extends State<topInfo> {
  Timer? _timer;
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    _updateDate();
    // Update every minute to keep date current
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateDate();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDate() {
    final now = DateTime.now();
    setState(() {
      _dateString = DateFormat('EEE dd MMM').format(now);
    });
  }

  String _displayPrayerName(AppProvider appProvider) {
    final n = (appProvider.nextPrayerName ?? '').toString();
    if (n.isEmpty) return '';
    switch (n.toLowerCase()) {
      case 'fajr':
        return 'Fajr';
      case 'fajrafter':
        return 'Fajr';
      case 'sunrise':
        return 'Sunrise';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      default:
        return n;
    }
  }

  String _nextPrayerTimeFormatted(AppProvider appProvider) {
    try {
      final next = appProvider.nextPrayerTime as DateTime?;
      if (next == null) return '--:--';

      // Use 24h or 12h format based on user preference
      if (appProvider.getTimeFormat24()) {
        return DateFormat('HH:mm').format(next);
      } else {
        return DateFormat('h:mm a').format(next);
      }
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Column(
              children: [
                // App bar row with menu and refresh buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child:
                          const Icon(Icons.menu_rounded, color: Colors.white),
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    Text(
                      _displayPrayerName(appProvider),
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                      ),
                    ),
                    InkWell(
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                      onTap: () async {
                        bool serviceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          await Geolocator.openLocationSettings();
                          return;
                        }
                        appProvider.getPrayerTimes(refresh: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Next prayer time
                Text(
                  _nextPrayerTimeFormatted(appProvider),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 5),
                // Date and city
                Text(
                  '$_dateString • ${appProvider.getCityName()}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
