import 'package:flutter/material.dart';


class moonImage extends StatelessWidget {
  const moonImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset("assets/images/moon.png"),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 133,
            child: Image.asset("assets/images/moon_b.png"),
          ),
        ),
      ],
    );
  }
}