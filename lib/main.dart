import 'package:al_qibla/class/notifications_api.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/screens/calendar_screen.dart';
import 'package:al_qibla/screens/citites_screen.dart';
import 'package:al_qibla/screens/home_screen.dart';
import 'package:al_qibla/screens/missedPrayer_screen.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/settings_screen.dart';
import 'package:al_qibla/workmanager/workmanager_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';



void main() async {


  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationApi.init(initScheduled: true);
   
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
            dialogBackgroundColor: Colors.grey[350],
          // Define your custom theme here
          textTheme: const TextTheme(
            
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall:
                TextStyle(color: Colors.white), // Change the default text color
          ),
          iconTheme: const IconThemeData(
              color: Colors.white), // Change the default icon color
        ),
        routes: {
          '/homeScreen  ': (context) => const HomeScreen(),
          '/settingScreen': (context) => const SettingScreen(),
          '/qiblaScreen': (context) => const QiblaScreen(),
          '/citiesScreen': (context) => const CitiesScreen(),
          '/calendarScreen': (context) => CalendarScreen(
                latitude: Provider.of<AppProvider>(context, listen: false)
                    .getLatitude(),
                longitude: Provider.of<AppProvider>(context, listen: false)
                    .getLongitude(),
                local: true,
              ),
          '/missedPrayerScreen': (context) => const MissedPrayerScreen()
        },
        home: const HomeScreen(),
      ),
    );
  }
}
