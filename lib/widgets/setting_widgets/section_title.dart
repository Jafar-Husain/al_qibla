import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const SectionTitle({
    super.key,
    required this.title,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }
}