// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

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
    super.initState();
  }

  @override
  void didChangeDependencies() {
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
          showBackButton: true,
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

                                        Navigator.pop(context);
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
                                        Navigator.pop(context);
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
                                        Navigator.pop(context);
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
                    subtitle: Provider.of<AppProvider>(context).getIsDarkMode()
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context).getIsDarkMode(),
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
                  const SizedBox(height: 32),
                  SectionTitle(
                    title: "Notifications",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  SettingContainer(
                    title: 'Fajr',
                    subtitle: Provider.of<AppProvider>(context)
                            .isPrayerNotificationEnabled('Fajr')
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context)
                          .isPrayerNotificationEnabled('Fajr'),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .togglePrayerNotification('Fajr', value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Dhuhr',
                    subtitle: Provider.of<AppProvider>(context)
                            .isPrayerNotificationEnabled('Dhuhr')
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context)
                          .isPrayerNotificationEnabled('Dhuhr'),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .togglePrayerNotification('Dhuhr', value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Asr',
                    subtitle: Provider.of<AppProvider>(context)
                            .isPrayerNotificationEnabled('Asr')
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context)
                          .isPrayerNotificationEnabled('Asr'),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .togglePrayerNotification('Asr', value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Maghrib',
                    subtitle: Provider.of<AppProvider>(context)
                            .isPrayerNotificationEnabled('Maghrib')
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context)
                          .isPrayerNotificationEnabled('Maghrib'),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .togglePrayerNotification('Maghrib', value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  SettingContainer(
                    title: 'Isha',
                    subtitle: Provider.of<AppProvider>(context)
                            .isPrayerNotificationEnabled('Isha')
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: ToggleSwitch(
                      value: Provider.of<AppProvider>(context)
                          .isPrayerNotificationEnabled('Isha'),
                      onChanged: (value) {
                        Provider.of<AppProvider>(context, listen: false)
                            .togglePrayerNotification('Isha', value);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 32),
                  SectionTitle(
                    title: "Location",
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  SettingContainer(
                    title: 'Auto Location',
                    subtitle: Provider.of<AppProvider>(context).isManualLocation
                        ? 'Manual'
                        : 'Using GPS',
                    trailing: ToggleSwitch(
                      value:
                          !Provider.of<AppProvider>(context).isManualLocation,
                      onChanged: (value) async {
                        if (value) {
                          // Switching to auto (GPS)
                          await Provider.of<AppProvider>(context, listen: false)
                              .clearManualLocation();
                        } else {
                          // Switching to manual - show city picker
                          _showCitySearchDialog(context, isDarkMode);
                        }
                      },
                      isDarkMode: isDarkMode,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  // Show city selector when in manual mode
                  if (Provider.of<AppProvider>(context).isManualLocation) ...[
                    const SizedBox(height: 12),
                    SettingContainer(
                      title: 'Selected City',
                      subtitle: Provider.of<AppProvider>(context).getCityName(),
                      trailing: Icon(
                        Icons.edit,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      isDarkMode: isDarkMode,
                      onTap: () => _showCitySearchDialog(context, isDarkMode),
                    ),
                  ],
                  const SizedBox(height: 12),
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
      ),
    );
  }

  Future<void> _showCitySearchDialog(
      BuildContext context, bool isDarkMode) async {
    final cityJson = await rootBundle.loadString('assets/json/cities.json');
    List<Map<String, dynamic>> cities =
        List<Map<String, dynamic>>.from(json.decode(cityJson));

    List<Map<String, dynamic>> filterCities(String searchText) {
      return cities
          .where((city) =>
              city['name'].toLowerCase().contains(searchText.toLowerCase()) ||
              city['country'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select City'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return filterCities(textEditingValue.text);
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54),
                      filled: true,
                      fillColor: isDarkMode
                          ? AppTheme.darkSmallContainer
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: isDarkMode
                                ? AppTheme.accentColor
                                : AppTheme.primaryColor),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Map<String, dynamic>> onSelected,
                    Iterable<Map<String, dynamic>> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      color: isDarkMode
                          ? AppTheme.darkSmallContainer
                          : Colors.white,
                      child: SizedBox(
                        height: options.length > 2
                            ? 180
                            : options.length > 1
                                ? 120
                                : 70,
                        width: 232,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> city =
                                options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(city);
                              },
                              child: ListTile(
                                title: Text(
                                  '${city['name']}, ${city['country']}',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (Map<String, dynamic> selection) async {
                  Navigator.pop(context);

                  final appProvider =
                      Provider.of<AppProvider>(context, listen: false);

                  await appProvider.setManualLocation(
                    latitude: double.parse(selection['lat']),
                    longitude: double.parse(selection['lng']),
                    cityName: selection['name'],
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
