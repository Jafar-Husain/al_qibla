import 'dart:io';
import 'package:al_qibla/class/notifications_api.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/screens/new_calendar_screen.dart';
import 'package:al_qibla/screens/citites_screen.dart';
import 'package:al_qibla/screens/missedPrayer_screen.dart';
import 'package:al_qibla/screens/qibla_screen.dart';
import 'package:al_qibla/screens/settings_screen.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/workmanager/workmanager_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:al_qibla/screens/home_screen.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This is the method that will be called when the task is executed.
    try {
      await updateWidget();
      return Future.value(true);
    } catch (e) {
      print('Error updating widget: $e');
      return Future.value(false);
    }
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

  // Register background task to update widgets
  // Note: iOS does not support periodic tasks, so we register a one-off task
  // On iOS, widgets should calculate prayer times natively in Swift
  // On Android, we use a periodic task to keep widgets updated
  if (Platform.isAndroid) {
    Workmanager().registerPeriodicTask(
      "widget-update-task",
      "widgetUpdate",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 10),
    );
  } else if (Platform.isIOS) {
    // On iOS, register a one-off task to update widget data once at app launch
    // iOS widgets will handle their own refresh via TimelineProvider
    Workmanager().registerOneOffTask(
      "widget-update-task",
      "widgetUpdate",
      initialDelay: Duration(seconds: 5),
    );
  }

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
            themeMode:
                appProvider.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light,

            // This is important - it overrides TextField theme specifically
            // to ensure dialog text fields show black text
            builder: (context, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor:
                      isDark ? const Color(0xFF2F3E3C) : Colors.white,
                  dialogTheme: DialogThemeData(
                    backgroundColor:
                        isDark ? const Color(0xFF2F3E3C) : Colors.white,
                    titleTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    contentTextStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87),
                    hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF384A48) : Colors.white,
                  ),
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor:
                        isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                    selectionColor: isDark
                        ? AppTheme.darkPrimaryColor.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                    selectionHandleColor:
                        isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? AppTheme.darkPrimaryColor : Colors.blue,
                    ),
                  ),
                  // Ensure TextField uses appropriate text color
                  textTheme: Theme.of(context).textTheme.copyWith(
                        titleMedium: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                      ),
                ),
                child: child!,
              );
            },

            routes: {
              '/homeScreen': (context) => const HomeScreen(),
              '/settingScreen': (context) => const SettingScreen(),
              '/qiblaScreen': (context) => const QiblaScreen(),
              '/citiesScreen': (context) => const CitiesScreen(),
              '/calendarScreen': (context) => NewCalendarScreen(
                    latitude: Provider.of<AppProvider>(context, listen: false)
                        .getLatitude(),
                    longitude: Provider.of<AppProvider>(context, listen: false)
                        .getLongitude(),
                    local: true,
                  ),
              '/missedPrayerScreen': (context) => const MissedPrayerScreen()
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
