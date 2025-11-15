import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:al_qibla/provider/app_provider.dart';

class HomeTopInfo extends StatefulWidget {
  const HomeTopInfo({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  State<HomeTopInfo> createState() => _HomeTopInfoState();
}

class _HomeTopInfoState extends State<HomeTopInfo> {
  Timer? _timer;
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    // Load initial date
    _updateDate();

    // Update every minute to keep the countdown and date accurate
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

  String _formatDate() {
    return _dateString;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        String displayPrayerName() {
          final n = (appProvider.nextPrayerName ?? '').toString();
          if (n.isEmpty) return '';
          switch (n.toLowerCase()) {
            case 'fajr':
              return 'Fajr';
            case 'fajrafter':
              return 'Fajr tomorrow';
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

        String timeRemaining() {
          try {
            final now = DateTime.now();
            final next = appProvider.nextPrayerTime as DateTime?;
            if (next == null) return '--:--';
            Duration d = next.difference(now);
            if (d.isNegative) d = Duration.zero;
            final totalMinutes = d.inMinutes;
            final hours = totalMinutes ~/ 60;
            final minutes = totalMinutes % 60;
            // Always show HH:MM, no seconds
            return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
          } catch (_) {
            return '--:--';
          }
        }

        return SizedBox(
          child: Column(
            children: [
              Text(
                "${displayPrayerName()} in",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.isDarkMode
                          ? const Color(0xFFEAEAEA)
                          : const Color(0xFF3E3D3C),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 0),
              Text(
                timeRemaining(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: widget.isDarkMode
                          ? Colors.white
                          : const Color(0xFF0F3D3E),
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
              ),
              const SizedBox(height: 0),
              Text(
                _formatDate(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : const Color(0xFF77736A),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
