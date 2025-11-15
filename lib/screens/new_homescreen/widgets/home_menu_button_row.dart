import 'package:al_qibla/app_theme.dart';
import 'package:flutter/material.dart';


enum HomeMenuTab { prayerTimes, information, events, calendar }

class HomeMenuButtonRow extends StatelessWidget {
  final bool isDarkMode;
  final HomeMenuTab selectedTab;
  final Function(HomeMenuTab) onTabSelected;

  const HomeMenuButtonRow({
    super.key,
    required this.isDarkMode,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildTextButton(
              context,
              "Prayer",
              isDarkMode,
              isSelected: selectedTab == HomeMenuTab.prayerTimes,
              onTap: () => onTabSelected(HomeMenuTab.prayerTimes),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTextButton(
              context,
              "Missed Prayers",
              isDarkMode,
              isSelected: selectedTab == HomeMenuTab.information,
              onTap: () => onTabSelected(HomeMenuTab.information),
            ),
          ),
          
          const SizedBox(width: 4),
          Expanded(
            child: _buildTextButton(
              context,
              "Calendar",
              isDarkMode,
              isSelected: selectedTab == HomeMenuTab.calendar,
              onTap: () => onTabSelected(HomeMenuTab.calendar),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    String text,
    bool isDarkMode, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? (isDarkMode ? Colors.black87 : Colors.white)
                  : (isDarkMode ? Colors.white : AppTheme.primaryColor),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
