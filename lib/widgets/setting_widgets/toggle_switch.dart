import 'package:al_qibla/app_theme.dart';
import 'package:flutter/material.dart';



class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDarkMode;

  const ToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value
              ? AppTheme.accentColor
              : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          border: Border.all(
            color: isDarkMode ? Colors.white24 : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              value ? Icons.check : Icons.close,
              size: 16,
              color: value ? AppTheme.accentColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}