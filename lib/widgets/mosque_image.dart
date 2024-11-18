import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


class mosqueImage extends StatelessWidget {
  const mosqueImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Other widgets in the Stack
        SvgPicture.asset(
          'assets/images/mosques_background.svg',
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(255, 29, 25, 52),
        ),
        SvgPicture.asset(
          'assets/images/mosques_foreground2.svg',
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Provider.of<AppProvider>(context).currentMosqueColor,
        ),
      ],
    );
  }
}