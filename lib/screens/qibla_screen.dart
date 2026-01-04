import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/compass_view.dart';
import 'package:al_qibla/widgets/custom_app_bar.dart';
import 'package:al_qibla/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _bearing = 0;

  void getQibla() async {
    double long =
        await Provider.of<AppProvider>(context, listen: false).getLongitude();
    double lat =
        await Provider.of<AppProvider>(context, listen: false).getLatitude();
    print("getting qibla");
    setState(() {
      _bearing = Qibla.qibla(Coordinates(lat, long));
    });
  }

  @override
  void initState() {
    getQibla();
    print("initstate");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final heading = snapshot.data?.heading ?? 0;
          final accuracy = snapshot.data?.accuracy;
          String accuracyStatus = '';
          Color accuracyColor =
              isDarkMode ? Colors.white : AppTheme.primaryColor;

          if (accuracy != null) {
            if (accuracy <= 5) {
              accuracyStatus = 'Excellent';
              accuracyColor =
                  isDarkMode ? Colors.greenAccent : Colors.green[700]!;
            } else if (accuracy > 5 && accuracy <= 15) {
              accuracyStatus = 'Medium';
              accuracyColor =
                  isDarkMode ? Colors.amberAccent : Colors.orange[800]!;
            } else {
              accuracyStatus = 'Bad';
              accuracyColor = isDarkMode ? Colors.redAccent : Colors.red[700]!;
            }
          } else {
            accuracyStatus = 'N/A';
          }

          return Scaffold(
            drawer: const HomeDrawer(selectedIndex: 1),
            appBar: CustomAppBar(
              title: "Compass",
              backgroundColor: Colors.transparent,
              foregroundColor:
                  isDarkMode ? Colors.white : AppTheme.primaryColor,
              showBackButton: false,
              showMenuButton: true,
            ),
            backgroundColor: AppTheme.getCurrentBackgroundColor(isDarkMode),
            body: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${heading.ceil() > 0 ? heading.ceil() : 360 + heading.ceil()}°",
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.white : AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: const Alignment(0, -0.2),
                    child: CompassView(
                      bearing: _bearing,
                      heading: heading,
                      foregroundColor:
                          isDarkMode ? Colors.white : AppTheme.primaryColor,
                      bearingColor:
                          isDarkMode ? AppTheme.accentColor : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Qibla is ${_bearing!.ceil()}°",
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.white : AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Accuracy is $accuracyStatus",
                    style: TextStyle(color: accuracyColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
