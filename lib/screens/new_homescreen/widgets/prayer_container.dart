import 'package:flutter/material.dart';
import 'package:al_qibla/app_theme.dart';

class PrayerContainer extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final bool isCurrentPrayer;

  const PrayerContainer({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.isCurrentPrayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? (isDarkMode
                ? AppTheme.darkPrimaryColor.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPrayer
            ? Border.all(
                color: isDarkMode
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.primaryColor,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Prayer name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prayerName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  prayerTime,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell (placeholder)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.darkBigContainer
                  : AppTheme.smallContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: isDarkMode ? Colors.white70 : AppTheme.secondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
