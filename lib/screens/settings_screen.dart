// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/custom_app_bar.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/widgets/setting_widgets/setting_container.dart';
import 'package:al_qibla/widgets/setting_widgets/section_title.dart';
import 'package:al_qibla/widgets/setting_widgets/toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'package:al_qibla/widgets/navbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? selectedMehthod;

  void setSelectedMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String method = prefs.getString("method") ?? "Tehran";
    print(method);

    setState(() {
      selectedMehthod = method;
    });
  }

  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setSelectedMethod();
  }

  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.getCurrentBackgroundColor(isDarkMode),
        appBar: CustomAppBar(
          title: "Settings",
          backgroundColor: Colors.transparent,
          foregroundColor: isDarkMode ? Colors.white : AppTheme.primaryColor,
          showBackButton: false,
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SectionTitle(
                    title: "Calculation Parameters",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  SettingContainer(
                    title: 'Calculation Method',
                    subtitle: Provider.of<AppProvider>(context)
                            .calculationMethodRadioTileMap[
                        selectedMehthod ?? "Tehran"]!,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Add any action you want when the ListTile is tapped
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Select Calculation Method'),
                              content: Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: Provider.of<AppProvider>(context)
                                      .calculationMethodRadioTileMap
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final key =
                                        Provider.of<AppProvider>(context)
                                            .calculationMethodRadioTileMap
                                            .keys
                                            .toList()[index];
                                    final value =
                                        Provider.of<AppProvider>(context)
                                            .calculationMethodRadioTileMap[key];

                                    return RadioListTile<String>(
                                      title: Text(value!),
                                      value: key,
                                      groupValue: selectedMehthod,
                                      onChanged: (String? newValue) {
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .setMethod(newValue!);

                                        setState(() {
                                          selectedMehthod = newValue;
                                        });

                                        Navigator.pop(
                                            context); // Close the dialog
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .getPrayerTimes(refresh: true);
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Asr Juristic Method',
                    subtitle: Provider.of<AppProvider>(context).madhabMap[
                        Provider.of<AppProvider>(context).getMadhab()]!,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Juristic Method for Asr'),
                              content: Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: Provider.of<AppProvider>(context)
                                      .madhabMap
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final key =
                                        Provider.of<AppProvider>(context)
                                            .madhabMap
                                            .keys
                                            .toList()[index];
                                    final value =
                                        Provider.of<AppProvider>(context)
                                            .madhabMap[key];

                                    return RadioListTile<String>(
                                      title: Text(value!),
                                      value: key,
                                      groupValue:
                                          Provider.of<AppProvider>(context)
                                              .getMadhab(),
                                      onChanged: (String? newValue) {
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .setMadhab(newValue!);
                                        Navigator.pop(
                                            context); // Close the dialog
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .getPrayerTimes(refresh: true);
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Higher Latitude Adjustment',
                    subtitle: Provider.of<AppProvider>(context).highLatitudeMap[
                        Provider.of<AppProvider>(context)
                            .getHighLatitudeRule()]!,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Higher Latitude Adjustment'),
                              content: Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: Provider.of<AppProvider>(context)
                                      .highLatitudeMap
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final key =
                                        Provider.of<AppProvider>(context)
                                            .highLatitudeMap
                                            .keys
                                            .toList()[index];
                                    final value =
                                        Provider.of<AppProvider>(context)
                                            .highLatitudeMap[key];

                                    return RadioListTile<String>(
                                      title: Text(value!),
                                      value: key,
                                      groupValue:
                                          Provider.of<AppProvider>(context)
                                              .getHighLatitudeRule(),
                                      onChanged: (String? newValue) {
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .setHighLatitudeRule(newValue!);
                                        Navigator.pop(
                                            context); // Close the dialog
                                        Provider.of<AppProvider>(context,
                                                listen: false)
                                            .getPrayerTimes(refresh: true);
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SectionTitle(
                    title: "App Settings",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  SettingContainer(
                    title: 'Dark Theme',
                    subtitle:
                        Provider.of<AppProvider>(context).getIsDarkMode()
                            ? 'Enabled'
                            : 'Disabled',
                    trailing: ToggleSwitch(
                      value:
                          Provider.of<AppProvider>(context).getIsDarkMode(),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .setDarkMode(value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: '24 Hour Format',
                    subtitle:
                        Provider.of<AppProvider>(context).getTimeFormat24()
                            ? 'Enabled'
                            : 'Disabled',
                    trailing: ToggleSwitch(
                      value:
                          Provider.of<AppProvider>(context).getTimeFormat24(),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .setTimeFormat(value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Notifications',
                    subtitle: 'Open Settings',
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.notification);
                    },
                  ),
                  const SizedBox(height: 32),
                  SectionTitle(
                    title: "Location",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  SettingContainer(
                    title: 'Location Permission',
                    subtitle: 'Open Location Settings',
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    isDarkMode: isDarkMode,
                    onTap: () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.location);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: BottomNavigationWidget(selectedIndex: 3),
          ),
        ),
      ),
    );
  }
}
