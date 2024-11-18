// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool local;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // TODO: implement debugFillProperties
    super.debugFillProperties(properties);
  }

  const CalendarScreen(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.local});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  var slcDay = DateTime.now();
  List<DateTime> prayersList = [
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
  ];

  void initializePrayerList() async {
    PrayerTimes prayerT = await Provider.of<AppProvider>(context, listen: false)
        .calculatePrayerTimes(
            widget.latitude,
            widget.longitude,
            Provider.of<AppProvider>(context, listen: false).getMethod(),
            Provider.of<AppProvider>(context, listen: false).getMadhab(),
            Provider.of<AppProvider>(context, listen: false)
                .getHighLatitudeRule(),
            slcDay);
    if (widget.local == true) {
      List<DateTime> prayersList2 =
          await Provider.of<AppProvider>(context, listen: false)
              .calculatePrayerTimeFromPrayerTimes(prayerT);
      setState(() {
        prayersList = prayersList2;
      });
    } else {
      List<DateTime> prayersList2 =
          await Provider.of<AppProvider>(context, listen: false)
              .calculateCityPrayerTimeFromPrayerTimes(
                  prayerT, widget.latitude, widget.longitude);
      setState(() {
        prayersList = prayersList2;
      });
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    initializePrayerList();
  }

  Widget build(BuildContext context) {
    var calFormat = CalendarFormat.month;

    double fontSize = 15;
    DateFormat customDateFormat =
        Provider.of<AppProvider>(context).getTimeFormat24()
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');
    List<String> prayerNames = [
      "Fajr",
      "Sunrise",
      "Dhuhr",
      "Asr",
      "Maghrib",
      "Isha"
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TableCalendar(
              
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.black),
                outsideTextStyle: TextStyle(color: Colors.black),
              ),
              headerVisible: true,
              headerStyle: HeaderStyle(
                leftChevronIcon: Icon(Icons.chevron_left,color: Colors.black,),
                rightChevronIcon: Icon(Icons.chevron_right,color: Colors.black,),
    titleTextStyle: TextStyle(color:Colors.black,fontSize: 17,fontWeight: FontWeight.w700),
    formatButtonVisible: false, // Set to true if you want format buttons
  ),
              focusedDay: slcDay,
              selectedDayPredicate: (day) {
                return isSameDay(slcDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  slcDay = selectedDay;
                  initializePrayerList();
                });
              },
              firstDay: slcDay.add(Duration(days: -365)),
              lastDay: slcDay.add(
                Duration(days: 365),
              ),
              calendarFormat: calFormat,
              onFormatChanged: (format) {},
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(slcDay),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      for (int i = 0; i < prayerNames.length; i++)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                prayerNames[i],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                customDateFormat.format(prayersList[i]),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
