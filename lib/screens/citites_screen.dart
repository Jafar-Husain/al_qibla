// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:al_qibla/class/city_class.dart';
import 'package:al_qibla/class/sting_extension.dart';
import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cityJson =
              await rootBundle.loadString('assets/json/cities.json');
          List<Map<String, dynamic>> cities =
              List<Map<String, dynamic>>.from(json.decode(cityJson));

          List<Map<String, dynamic>> filterCities(String searchText) {
            List<Map<String, dynamic>> filteredCities = cities
                .where((city) =>
                    city['name']
                        .toLowerCase()
                        .contains(searchText.toLowerCase()) ||
                    city['country']
                        .toLowerCase()
                        .contains(searchText.toLowerCase()))
                .toList();
            return filteredCities;
          }

          print(cities[0]);

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add City'),
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
                        List<Map<String, dynamic>> suggestions =
                            filterCities(textEditingValue.text);
                        return suggestions;
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<Map<String, dynamic>>
                              onSelected,
                          Iterable<Map<String, dynamic>> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
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
      
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Map<String, dynamic> city =
                                        options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(city);
                                      },
                                      child: ListTile(
                                        title: Text(
                                            '${city['name']}, ${city['country']}'),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        );
                      },
                      onSelected: (Map<String, dynamic> selection) async {
                        Navigator.pop(context);
                        print(selection.toString());
                        
                        print("latitude is ${selection["lat"]}");
                        await Provider.of<AppProvider>(context, listen: false)
                            .addMyCities(jsonEncode(selection));
                        await Provider.of<AppProvider>(context, listen: false)
                            .getMyCitiesList();

                        await Provider.of<AppProvider>(context, listen: false)
                            .setMyCityCities();
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      // List city =
                      //     await Provider.of<AppProvider>(context, listen: false)
                      //         .getMyCitiesList();
                      // print(city);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Cities",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    Provider.of<AppProvider>(context).myCityCities().length,
                itemBuilder: (context, index) {
                  List<City> cityLi =
                      Provider.of<AppProvider>(context).myCityCities();
                  return Column(
                    children: [
                      Dismissible(
                        key: Key(cityLi[index].latitude.toString() +
                            cityLi[index].longitude.toString()),
                        onDismissed: (DismissDirection direction) async {
                          await Provider.of<AppProvider>(context, listen: false)
                              .removeMyCities(index);
                          await Provider.of<AppProvider>(context, listen: false)
                              .getMyCitiesList();
          
                          await Provider.of<AppProvider>(context, listen: false)
                              .setMyCityCities();
                        },
                        background: Container(
                          padding: EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: CityExpansionTile(
                          cityName: cityLi[index].cityName,
                          timeDiff: cityLi[index].timeDifference,
                          nextPrayerName: cityLi[index].nextPrayerName,
                          nextPrayerTime: cityLi[index].nextPrayerTime,
                          prayerTimeList: cityLi[index].prayerTimes,
                          latitude: cityLi[index].latitude,
                          longitude: cityLi[index].longitude,
                        ),
                      ),
                      Divider(
                        thickness: 2,
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CityExpansionTile extends StatelessWidget {
  final String cityName;
  final String timeDiff;
  final String nextPrayerName;
  final DateTime nextPrayerTime;
  final List<DateTime> prayerTimeList;
  final double latitude;
  final double longitude;

  const CityExpansionTile({
    super.key,
    required this.cityName,
    required this.timeDiff,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.prayerTimeList,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat customDateFormat =
        Provider.of<AppProvider>(context).getTimeFormat24()
            ? DateFormat('HH:mm')
            : DateFormat('h:mm a');
    return ExpansionTile(
      title: Text(
        cityName,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      tilePadding: EdgeInsets.only(left: 0),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(timeDiff),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.mosque,
                size: 20,
                color: Colors.blue,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                customDateFormat.format(nextPrayerTime),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              SizedBox(
                width: 15,
              ),
              Text(nextPrayerName == "fajrafter"
                  ? "Fajr"
                  : nextPrayerName.capitalize()),
              Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendarScreen(
                            latitude: latitude,
                            longitude: longitude,
                            local: false)),
                  );
                },
                icon: Icon(Icons.calendar_month),
              )
            ],
          ),
        ],
      ),
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: 6,
          separatorBuilder: (BuildContext context, int index) {
            // Add your desired space between items here
            return SizedBox(height: 10); // Adjust the height as needed
          },
          itemBuilder: (context, index) {
            return Row(
              // Align both texts at the start

              children: [
                SizedBox(
                  width: 37,
                ),
                Text(
                  customDateFormat.format(
                    prayerTimeList[index],
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  Provider.of<AppProvider>(context).prayerNames[index],
                  style: TextStyle(color: Colors.black),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
