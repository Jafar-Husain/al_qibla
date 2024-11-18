import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/compass_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _bearing = 0;

  void getQibla() async {
    double long = await Provider.of<AppProvider>(context,listen: false).getLongitude();
    double lat = await Provider.of<AppProvider>(context,listen: false).getLatitude();
    print("getting qibla");
    setState(() {
      _bearing = Qibla.qibla(Coordinates(lat, long));
    });
  }

  void _setBearing(double heading) {
    setState(() {
      _bearing = heading;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getQibla();
    print("initstate");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading ?? 0;
        final accuracy = snapshot.data?.accuracy;
        String accuracyStatus = '';
        Color accuracyColor = Colors.white; // Default color

        if (accuracy != null) {
          if (accuracy <= 5) {
            accuracyStatus = 'Excellent';
            accuracyColor = Colors.green;
          } else if (accuracy > 5 && accuracy <= 15) {
            accuracyStatus = 'Medium';
            accuracyColor = Colors.yellow;
          } else {
            accuracyStatus = 'Bad';
            accuracyColor = Colors.red;
          }
        } else {
          accuracyStatus = 'N/A';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Compass",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${heading.ceil() > 0 ? heading.ceil() : 360 + heading.ceil()}°",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(
                height: 40,
              ),
              Align(
                alignment: const Alignment(0, -0.2),
                child: CompassView(
                  bearing: _bearing,
                  heading: heading,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                "Qibla is ${_bearing!.ceil()}°",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Accuracy is $accuracyStatus",
                style: TextStyle(color: accuracyColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
