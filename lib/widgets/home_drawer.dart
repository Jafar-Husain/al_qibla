// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:al_qibla/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: Text(
                'Home', 
              ),
              selected: true,
            ),
          ),
          DrawerTile(
            title: "Qibla", 
            icon: Icons.explore,
            routeName: "/qiblaScreen",
          ),
          DrawerTile(
            title: "Missed Prayers",
            icon: Icons.history,
            routeName: "/missedPrayerScreen",
          ),

          /// DrawerTile(
          ///   title: "Cities",
          ///   icon: Icons.public,
          ///   routeName: "/citiesScreen",
          /// ),
          ListTile(
            leading: Icon(
              Icons.public,
              color: Colors.white,
            ),
            title: Text(
              "Cities", style: TextStyle(color: Colors.white),
              
            ),
            onTap: () async {
              await Provider.of<AppProvider>(context, listen: false)
                  .setMyCityCities();
               Navigator.pop(context);
               Navigator.of(context).pushNamed("/citiesScreen");
            },
          ),
          DrawerTile(
            title: "Calendar",
            icon: Icons.calendar_month,
            routeName: "/calendarScreen",
          ),
          DrawerTile(
            title: "Settings",
            icon: Icons.settings,
            routeName: "/settingScreen",
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String routeName;
  const DrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title, style: TextStyle(color: Colors.white),
      ),
      onTap: () async {
         Navigator.pop(context);
         Navigator.of(context).pushNamed(routeName);
      },
    );
  }
}
