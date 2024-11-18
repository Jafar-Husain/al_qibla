import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class homeAppbar extends StatelessWidget {
  const homeAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          child: Icon(Icons.menu),
          onTap: () {
            Scaffold.of(context).openDrawer();
            
          },
        ),
        Text(
          "Next prayer time",
          style: TextStyle(fontSize: 17),
        ),
        InkWell(
          child: Icon(Icons.refresh_rounded),
          onTap: () {
            Provider.of<AppProvider>(context, listen: false).getPrayerTimes(refresh: true);
          },
        ),
      ],
    );
  }
}
