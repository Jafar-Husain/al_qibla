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
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // This is the method that will be called when the task is executed.
    //updateWidget();
    //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId("group.com.jafar.alQiblaWidget");
  // Initialize notifications
  await NotificationApi.init(initScheduled: true);
  
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: false,
    // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  Workmanager().registerOneOffTask("task-identifier", "simpleTask",
      initialDelay: Duration(seconds: 10));

  

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
          dialogBackgroundColor: Colors.white,
          dialogTheme: const DialogTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: Colors.black),
          ),
          
          // Define separate input decoration theme for text fields in dialogs
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black87),
            hintStyle: TextStyle(color: Colors.black54),
            // Ensure text appears black in text fields
            filled: true,
            fillColor: Colors.white,
          ),
          
          // Override text selection color for TextField
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.blue,
            selectionColor: Colors.blue.withOpacity(0.3),
            selectionHandleColor: Colors.blue,
          ),
          
          // Define your custom theme here for app UI (not dialogs)
          textTheme: const TextTheme(
            // These styles will apply to app text but not dialog text
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
          ),
          
          // We need to explicitly set TextField style
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Button text color
            ),
          ),
          
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        
        // This is important - it overrides TextField theme specifically
        // to ensure dialog text fields show black text
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              // Ensure TextField uses black text regardless of parent theme
              textTheme: Theme.of(context).textTheme.copyWith(
                // This specifically targets TextField input
                titleMedium: TextStyle(color: Colors.black),
              ),
            ),
            child: child!,
          );
        },
        
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