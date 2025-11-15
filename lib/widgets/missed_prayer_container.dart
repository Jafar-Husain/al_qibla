import 'package:flutter/material.dart';
import 'package:al_qibla/app_theme.dart';

class MissedContainer extends StatelessWidget {
  MissedContainer({
    super.key,
    this.prayerName,
    this.missedNumber,
    this.Color1,
    this.Color2,
    required this.onClickAction,
    required this.onClickMinus,
    required this.onClickEdit,
  });

  final String? prayerName;
  final int? missedNumber;
  final Color? Color1;
  final Color? Color2;
  final Function onClickAction;
  final Function onClickMinus;
  final Function onClickEdit;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        onClickEdit();
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.getCurrentSmallContainer(isDarkMode),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Prayer Name
            Flexible(
              flex: 2,
              child: Text(
                "$prayerName",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Action Buttons and Missed Number
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Minus Button
                  GestureDetector(
                    onTap: () {
                      onClickMinus();
                    },
                    child: Icon(
                      Icons.remove_circle,
                      color: iconColor,
                      size: 45,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Missed Number with dynamic width
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$missedNumber",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button
                  GestureDetector(
                    onTap: () {
                      onClickAction();
                    },
                    child: Icon(
                      Icons.add_circle,
                      color: iconColor,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
