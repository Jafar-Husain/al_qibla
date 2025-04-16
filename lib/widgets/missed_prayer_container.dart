import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: () {
        onClickEdit();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          gradient: LinearGradient(
            colors: [
              Color1 ?? Colors.blue,
              Color2 ?? Colors.blueAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Prayer Name
            Flexible(
              flex: 2,
              child: Text(
                "$prayerName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
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
                    child: const Icon(
                      Icons.remove_circle,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Missed Number with dynamic width
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$missedNumber",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add Button
                  GestureDetector(
                    onTap: () {
                      onClickAction();
                    },
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.white,
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