import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/mosque_image.dart';
import '../widgets/prayer_picker.dart';
import '../widgets/top_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId("group.com.jafar.alQiblaWidget");
    WidgetsBinding.instance?.addObserver(this);

    // Initialize prayer times
    Provider.of<AppProvider>(context, listen: false).initStateHomePage();
    //Provider.of<AppProvider>(context, listen: false).getPrayerTimes(refresh: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<AppProvider>(context, listen: false)
          .getPrayerTimes(refresh: true);
      print("App resumed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      drawer: HomeDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appProvider.currentFirstGrad,
              appProvider.currentSecondGrad,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Show basic UI elements

            appProvider.nextPrayerTime != null ? topInfo() : const SizedBox(),
            mosqueImage(),
            appProvider.currentSVG,
            // Conditionally show the prayer picker
            appProvider.prayerTimesList.isNotEmpty
                ? prayerPicker()
                : const Center(
                    child: Text(
                      "Loading prayer times...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
