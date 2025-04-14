// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:adhan_dart/adhan_dart.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_settings/system_settings.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  late String selectedMehthod;

  void setSelectedMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String method = prefs.getString("method")!;
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 244, 255, 1.0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 0, 0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                child: Text(
                  "Calculation Parameters",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                tileColor: Colors.white,
                // Background color
                title: Text(
                  'Calculation Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  Provider.of<AppProvider>(context)
                      .calculationMethodRadioTileMap[selectedMehthod]!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios), // Right-hand side arrow icon
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
                              itemBuilder: (BuildContext context, int index) {
                                final key = Provider.of<AppProvider>(context)
                                    .calculationMethodRadioTileMap
                                    .keys
                                    .toList()[index];
                                final value = Provider.of<AppProvider>(context)
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
                                      selectedMehthod = newValue!;
                                    });

                                    Navigator.pop(context); // Close the dialog
                                    Provider.of<AppProvider>(context, listen: false)
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
              Divider(
                color: Colors.grey,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                tileColor: Colors.white, // Background color
                title: Text(
                  'Asr Juristic Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  Provider.of<AppProvider>(context)
                      .madhabMap[Provider.of<AppProvider>(context).getMadhab()]!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios), // Right-hand side arrow icon
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
                              itemBuilder: (BuildContext context, int index) {
                                final key = Provider.of<AppProvider>(context)
                                    .madhabMap
                                    .keys
                                    .toList()[index];
                                final value = Provider.of<AppProvider>(context)
                                    .madhabMap[key];
          
                                return RadioListTile<String>(
                                  title: Text(value!),
                                  value: key,
                                  groupValue: Provider.of<AppProvider>(context)
                                      .getMadhab(),
                                  onChanged: (String? newValue) {
                                    Provider.of<AppProvider>(context,
                                            listen: false)
                                        .setMadhab(newValue!);
                                    Navigator.pop(context); // Close the dialog
                                    Provider.of<AppProvider>(context, listen: false)
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
              Divider(
                color: Colors.grey,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                tileColor: Colors.white, // Background color
                title: Text(
                  'Higher Latitude Adjustment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  Provider.of<AppProvider>(context).highLatitudeMap[
                      Provider.of<AppProvider>(context).getHighLatitudeRule()]!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios), // Right-hand side arrow icon
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
                              itemBuilder: (BuildContext context, int index) {
                                final key = Provider.of<AppProvider>(context)
                                    .highLatitudeMap
                                    .keys
                                    .toList()[index];
                                final value = Provider.of<AppProvider>(context)
                                    .highLatitudeMap[key];
          
                                return RadioListTile<String>(
                                  title: Text(value!),
                                  value: key,
                                  groupValue: Provider.of<AppProvider>(context)
                                      .getHighLatitudeRule(),
                                  onChanged: (String? newValue) {
                                    Provider.of<AppProvider>(context,
                                            listen: false)
                                        .setHighLatitudeRule(newValue!);
                                  Navigator.pop(context); // Close the dialog
                                    Provider.of<AppProvider>(context, listen: false)
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
              Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                child: Text(
                  "App Settings",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                tileColor: Colors.white, // Background color
                title: Text(
                  '24 Hour Format',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Switch(
                  value: Provider.of<AppProvider>(context).getTimeFormat24(),
                  onChanged: (value) {
                    Provider.of<AppProvider>(context, listen: false)
                        .setTimeFormat(value);
                  },
                ), // Right-hand side arrow icon
                onTap: () {
                  // Add any action you want when the ListTile is tapped
                },
              ),
              Divider(
                color: Colors.grey,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                tileColor: Colors.white, // Background color
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Open Settings',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios), // Right-hand side arrow icon
                onTap: () {
                  SystemSettings.appNotifications();
                  // Add any action you want when the ListTile is tapped
                },
              ),
          
              Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                child: Text(
                  "Location",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                tileColor: Colors.white, // Background color
                title: Text(
                  'Location Permission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Open Location Settings',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios), // Right-hand side arrow icon
                onTap: () {
                  SystemSettings.location();
                  // Add any action you want when the ListTile is tapped
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
