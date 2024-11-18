import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class sunImage extends StatelessWidget {
  const sunImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SvgPicture.asset(
        'assets/images/assr_sun_detail.svg',
        alignment: Alignment.center,
        width: (MediaQuery.of(context).size.width),
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}
