import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/home_drawer.dart';

import 'package:flutter/material.dart';
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
  late Future<void> initHomePage;
  bool _isHomePageInitialized = false; // Flag for initialization state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initHomePage =
        Provider.of<AppProvider>(context, listen: false).initStateHomePage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isHomePageInitialized) {
        // Initialize data only if not already done
        initHomePage = Provider.of<AppProvider>(context, listen: false)
            .initStateHomePage();
        _isHomePageInitialized = true;
      }
      Provider.of<AppProvider>(context, listen: false)
          .getPrayerTimes(refresh: true);
      print("resumed");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Provider.of<AppProvider>(context).currentFirstGrad,
              Provider.of<AppProvider>(context).currentSecondGrad,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Show basic UI elements immediately:
            topInfo(),
            mosqueImage(),
            Provider.of<AppProvider>(context).currentSVG,
            // Conditionally show the prayer picker only after initialization:
            prayerPicker(), // Placeholder
          ],
        ),
      ),
    );
  }
}
