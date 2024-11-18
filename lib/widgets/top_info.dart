import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class topInfo extends StatelessWidget {
   topInfo({
    super.key,
  });
   

  @override
  Widget build(BuildContext context) {
    DateFormat customDateFormat = Provider.of<AppProvider>(context).getTimeFormat24()
    ? DateFormat('HH:mm')
    : DateFormat('h:mm a');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
        child: Column(
          children: [
            const homeAppbar(),
            const SizedBox(
              height: 25,
            ),
            Container(
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Provider.of<AppProvider>(context).getCityName(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    
                    customDateFormat.format(Provider.of<AppProvider>(context).nextPrayerTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 65,
                      color: Colors.white,
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
