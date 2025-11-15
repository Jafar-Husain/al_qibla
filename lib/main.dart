import 'package:al_qibla/class/notifications_api.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/screens/calendar_screen.dart';
import 'package:al_qibla/screens/citites_screen.dart';
import 'package:al_qibla/screens/missedPrayer_screen.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/settings_screen.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:al_qibla/screens/new_homescreen/homescreen.dart';

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
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appProvider.getIsDarkMode()
                ? ThemeMode.dark
                : ThemeMode.light,

            // This is important - it overrides TextField theme specifically
            // to ensure dialog text fields show black text
            builder: (context, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: isDark ? const Color(0xFF2F3E3C) : Colors.white,
                  dialogTheme: DialogThemeData(
                    backgroundColor: isDark ? const Color(0xFF2F3E3C) : Colors.white,
                    titleTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    contentTextStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF384A48) : Colors.white,
                  ),
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                    selectionColor: isDark
                        ? AppTheme.darkPrimaryColor.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                    selectionHandleColor: isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                    ),
                  ),
                  // Ensure TextField uses appropriate text color
                  textTheme: Theme.of(context).textTheme.copyWith(
                        titleMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
                      ),
                ),
                child: child!,
              );
            },

            routes: {
              '/homeScreen  ': (context) => const NewHomeScreen(),
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
            home: const NewHomeScreen(),
          );
        },
      ),
    );
  }
}
