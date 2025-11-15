import 'dart:convert';
import 'package:al_qibla/class/notifications_api.dart';
import 'package:al_qibla/workmanager/workmanager_function.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:al_qibla/class/city_class.dart';
import 'package:al_qibla/widgets/moon_image.dart';
import 'package:al_qibla/widgets/sun_image.dart';
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppProvider extends ChangeNotifier {
  //Const var:
  List<Color> firstGrad = [
    const Color(0xff100e2a), // fajr (Moon)
    const Color(0xffeb6344), // sunrise (Sun)
    const Color.fromARGB(255, 131, 208, 236), // dhuhr (Sun)
    const Color(0xff4ca1dc), // asr (Sun)
    //const Color(0xFFFF6B6B), // sunset (Sun)
    const Color(0xff8a327d), // maghrib (moon)
    const Color.fromARGB(255, 24, 0, 71), // isha (Moon)
  ];

  List<Color> secondGrad = [
    const Color(0xff2e2855), // fajr (Moon)
    const Color(0xffeaab94), // sunrise (Sun)
    const Color(0xffade0f2), // dhuhr (Sun)
    const Color.fromARGB(255, 137, 191, 230), // asr (Sun)
    //const Color(0xFFFEBF63), // sunset (Sun)
    const Color(0xffc630a4), // maghrib (mooon)
    const Color.fromARGB(255, 141, 116, 192), // isha (Moon)
  ];
  List mosqueFront = [
    Colors.black, //fajr
    Colors.black, //sunrise
    const Color.fromARGB(255, 23, 33, 54),
    const Color.fromARGB(255, 23, 33, 54), //asr
    const Color.fromARGB(255, 21, 23, 41),
    const Color.fromARGB(255, 21, 23, 41),
    const Color.fromARGB(255, 21, 23, 41), //isha
  ];

  List<String> prayerNames = [
    "Fajr",
    "Sunrise",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha"
  ];
  Map<String, int> prayerNameToValue = {
    'fajr': 0,
    'sunrise': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
    'fajrafter': 0,
  };

  final Map<String, CalculationParameters> calculationMethodsMap = {
    'MuslimWorldLeague': CalculationMethodParameters.muslimWorldLeague(),
    'Egyptian': CalculationMethodParameters.egyptian(),
    'Karachi': CalculationMethodParameters.karachi(),
    'UmmAlQura': CalculationMethodParameters.ummAlQura(),
    'Dubai': CalculationMethodParameters.dubai(),
    'MoonsightingCommittee':
        CalculationMethodParameters.moonsightingCommittee(),
    'NorthAmerica': CalculationMethodParameters.northAmerica(),
    'Kuwait': CalculationMethodParameters.kuwait(),
    'Qatar': CalculationMethodParameters.qatar(),
    'Singapore': CalculationMethodParameters.singapore(),
    'Tehran': CalculationMethodParameters.tehran(),
    'Turkey': CalculationMethodParameters.turkiye(),
    'Morocco': CalculationMethodParameters.morocco(),
  };

  final Map<String, String> calculationMethodRadioTileMap = {
    'MuslimWorldLeague': "Muslim World League",
    'Egyptian': "Egyptian General Authority of Survey",
    'Karachi': "University of Islamic Sciences, Karachi",
    'UmmAlQura': "Umm al-Qura University, Makkah",
    'Dubai': "Dubai authority",
    'MoonsightingCommittee': "Moonsighting Committee",
    'NorthAmerica': "Islamic Society of North America (ISNA)",
    'Kuwait': "Kuwait",
    'Qatar': "Qatar",
    'Singapore': "Singapore",
    'Tehran': "Institute of Geophysics, University of Tehran",
    'Turkey': "Turkey",
    'Morocco': "Morocco",
  };

  final Map<String, String> madhabMap = {
    "shafi": "Standard Asr Method",
    "hanafi": "Hanafi",
  };

  final Map<String, String> highLatitudeMap = {
    "middleofthenight": "Middle of the night",
    "seventhofthenight": "One-Seventh of Night",
    "twilightangle": "Angle Based",
  };

  //changing var:
  late double _latitude;
  late double _longitude;
  late CalculationParameters _method;
  late String _madhab;
  late String _highLatitudeRule;
  String _cityName = "";
  var currentFirstGrad = const Color(0xff100e2a);
  var currentSecondGrad = const Color(0xff2e2855);
  var currentMosqueColor = Colors.black;
  late List prayerTimesList;
  var nextPrayerTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  late var nextPrayerName;
  late var currentPrayerName;
  Widget currentSVG = const moonImage();
  FixedExtentScrollController scrollController = FixedExtentScrollController();
  bool _timeFormat24 = true; // modified removed late testing!
  bool _isDarkMode = false;
  List<String> _myCities = [];
  List<City> _myCityCities = [];
  late int _fajrMissed;
  late int _dhuhrMissed;
  late int _asrMissed;
  late int _maghribMissed;
  late int _ishaMissed;

  // Prayer notification preferences
  bool _fajrNotification = true;
  bool _dhuhrNotification = true;
  bool _asrNotification = true;
  bool _maghribNotification = true;
  bool _ishaNotification = true;

  Future<void> getFajrMissed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fajrMissed = await prefs.getInt("fajrMissed") ?? 0;
    notifyListeners();
  }

  Future<void> getDhuhrMissed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _dhuhrMissed = await prefs.getInt("dhuhrMissed") ?? 0;
    notifyListeners();
  }

  Future<void> getAsrMissed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _asrMissed = await prefs.getInt("asrMissed") ?? 0;
    notifyListeners();
  }

  Future<void> getMaghribMissed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _maghribMissed = await prefs.getInt("maghribMissed") ?? 0;
    notifyListeners();
  }

  Future<void> getIshaMissed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ishaMissed = await prefs.getInt("ishaMissed") ?? 0;
    notifyListeners();
  }

  Future<void> loadNotificationPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fajrNotification = prefs.getBool("fajrNotification") ?? true;
    _dhuhrNotification = prefs.getBool("dhuhrNotification") ?? true;
    _asrNotification = prefs.getBool("asrNotification") ?? true;
    _maghribNotification = prefs.getBool("maghribNotification") ?? true;
    _ishaNotification = prefs.getBool("ishaNotification") ?? true;
    notifyListeners();
  }

  Future<void> togglePrayerNotification(String prayerName, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (prayerName.toLowerCase()) {
      case 'fajr':
        _fajrNotification = value;
        await prefs.setBool("fajrNotification", value);
        break;
      case 'dhuhr':
        _dhuhrNotification = value;
        await prefs.setBool("dhuhrNotification", value);
        break;
      case 'asr':
        _asrNotification = value;
        await prefs.setBool("asrNotification", value);
        break;
      case 'maghrib':
        _maghribNotification = value;
        await prefs.setBool("maghribNotification", value);
        break;
      case 'isha':
        _ishaNotification = value;
        await prefs.setBool("ishaNotification", value);
        break;
    }

    notifyListeners();

    // Reschedule notifications with new preferences
    List<DateTime> next10DaysPrayerTimes = await getNext10DaysPrayerTimes();
    await schedulePrayerNotifications(next10DaysPrayerTimes);
  }

  bool isPrayerNotificationEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return _fajrNotification;
      case 'dhuhr':
        return _dhuhrNotification;
      case 'asr':
        return _asrNotification;
      case 'maghrib':
        return _maghribNotification;
      case 'isha':
        return _ishaNotification;
      default:
        return false;
    }
  }

  //getters:

  int fajrMissed() {
    return _fajrMissed;
  }

  int dhuhrMissed() {
    return _dhuhrMissed;
  }

  int asrMissed() {
    return _asrMissed;
  }

  int maghribMissed() {
    return _maghribMissed;
  }

  int ishaMissed() {
    return _ishaMissed;
  }

  double getLongitude() {
    return _longitude;
  }

  List<City> myCityCities() {
    return _myCityCities;
  }

  Future<List<String>> getMyCitiesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myCities = prefs.getStringList("myCities2")!;
    notifyListeners();
    return _myCities;
  }

  Future setMyCityCities() async {
    print(_myCities);
    _myCityCities = await transformStringListToCityList(_myCities);
    if (_myCityCities.length > 1) {
      print(_myCityCities[1].nextPrayerName);
      print(_myCityCities[1].nextPrayerTime.toString());
      print(_myCityCities[1].prayerTimes);
    }
    notifyListeners();
  }

  CalculationParameters getMethod() {
    return _method;
  }

  String getMadhab() {
    return _madhab;
  }

  bool getTimeFormat24() {
    return _timeFormat24;
  }

  bool getIsDarkMode() {
    return _isDarkMode;
  }

  double getLatitude() {
    return _latitude;
  }

  String getCityName() {
    return _cityName;
  }

  String getHighLatitudeRule() {
    return _highLatitudeRule;
  }

  // Notification preference getters
  bool getFajrNotification() => _fajrNotification;
  bool getDhuhrNotification() => _dhuhrNotification;
  bool getAsrNotification() => _asrNotification;
  bool getMaghribNotification() => _maghribNotification;
  bool getIshaNotification() => _ishaNotification;

  //setters

  void hapticOnClick() {
    HapticFeedback.mediumImpact();
  }

  Future<void> setFajrMissed(int value) async {
    if (value >= 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("fajrMissed", value);

      _fajrMissed = value;
      hapticOnClick();

      notifyListeners();
    }
  }

  Future<void> setDhuhrMissed(int value) async {
    if (value >= 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("dhuhrMissed", value);

      _dhuhrMissed = value;
      hapticOnClick();

      notifyListeners();
    }
  }

  Future<void> setAsrMissed(int value) async {
    if (value >= 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("asrMissed", value);

      _asrMissed = value;
      hapticOnClick();

      notifyListeners();
    }
  }

  Future<void> setMaghribMissed(int value) async {
    if (value >= 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("maghribMissed", value);

      _maghribMissed = value;
      hapticOnClick();

      notifyListeners();
    }
  }

  Future<void> setIshaMissed(int value) async {
    if (value >= 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("ishaMissed", value);

      _ishaMissed = value;
      hapticOnClick();

      notifyListeners();
    }
  }

  Future setLongitutde(double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('longitude', longitude);

    _longitude = longitude;

    notifyListeners();
  }

  Future removeMyCities(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cityList = await prefs.getStringList("myCities2");

    cityList!.removeAt(index);
    print("city with removed $cityList");
    await setMyCities(cityList);
  }

  Future addMyCities(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cityList = await prefs.getStringList("myCities2");
    cityList!.add(city);
    await setMyCities(cityList);
  }

  Future setMyCities(List<String> cites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('myCities2', cites);

    _myCities = cites;

    notifyListeners();
  }

  Future setLatitude(double latitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);

    _latitude = latitude;

    notifyListeners();
  }

  void setMethod(String method) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("method", "$method");

    _method = calculationMethodsMap[method]!;
    notifyListeners();
  }

  void setMadhab(String madhab) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("madhab", madhab);

    _madhab = madhab;
    notifyListeners();
  }

  void setTimeFormat(bool timeFormat24) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("timeFormat24", timeFormat24);

    _timeFormat24 = timeFormat24;

    notifyListeners();
  }

  void setDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", isDarkMode);

    _isDarkMode = isDarkMode;

    notifyListeners();
  }

  void setHighLatitudeRule(String highLatitudeRule) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("highLatitudeRule", highLatitudeRule);

    _highLatitudeRule = highLatitudeRule;
    notifyListeners();
  }

  Future setCityName(double longitude, double latitude) async {
    String cityName;

    try {
      cityName = "";
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        cityName = placemark.locality ?? placemark.country ?? ""; // City name

        _cityName = cityName;
      } else {
        cityName = "";
      }
    } catch (e) {
      // Handle exceptions here
      print("Error fetching placemarks: $e");
      // You can set cityName to a default value or handle the error in any other way
      cityName = "";
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName);
    print(_cityName);
    print("shdfj");
    notifyListeners();
  }

  Future getAllSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _longitude = prefs.getDouble("longitude")!;
    _latitude = prefs.getDouble("latitude")!;
    _method = calculationMethodsMap[prefs.getString("method")]!;
    _madhab = prefs.getString("madhab")!;
    _highLatitudeRule = prefs.getString("highLatitudeRule")!;
    _cityName = prefs.getString("cityName")!;
    _timeFormat24 = prefs.getBool("timeFormat24")!;
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;

    notifyListeners();
  }

  //Other
  void setColors() {
    currentFirstGrad = firstGrad[prayerNameToValue[nextPrayerName]!];
    currentSecondGrad = secondGrad[prayerNameToValue[nextPrayerName]!];
    currentMosqueColor = mosqueFront[prayerNameToValue[nextPrayerName]!];
    if (prayerNameToValue[nextPrayerName]! == 0 ||
        prayerNameToValue[nextPrayerName]! == 4 ||
        prayerNameToValue[nextPrayerName]! == 5) {
      currentSVG = const moonImage();
    } else {
      currentSVG = const sunImage();
    }
    notifyListeners();
  }

  Future<void> initScrollController() async {
    scrollController = await FixedExtentScrollController(
        initialItem: prayerNameToValue[nextPrayerName]!);
    setColors();
    notifyListeners();
  }

  void animateScrollController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateToItem(prayerNameToValue[nextPrayerName]!,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
    notifyListeners();
  }

  void onPickerChange(index) {
    currentFirstGrad = firstGrad[index];
    currentSecondGrad = secondGrad[index];
    currentMosqueColor = mosqueFront[index];
    if (index == 0 || index == 4 || index == 5) {
      currentSVG = const moonImage();
    } else {
      currentSVG = const sunImage();
    }
    notifyListeners();
  }

  Madhab _stringToMadhab(String madhab) {
    switch (madhab.toLowerCase()) {
      case 'shafi':
        return Madhab.shafi;
      case 'hanafi':
        return Madhab.hanafi;
      default:
        return Madhab.shafi;
    }
  }

  HighLatitudeRule _stringToHighLatitudeRule(String rule) {
    switch (rule.toLowerCase()) {
      case 'middleofthenight':
        return HighLatitudeRule.middleOfTheNight;
      case 'seventhofthenight':
        return HighLatitudeRule.seventhOfTheNight;
      case 'twilightangle':
        return HighLatitudeRule.twilightAngle;
      default:
        return HighLatitudeRule.middleOfTheNight;
    }
  }

  Future<PrayerTimes> calculatePrayerTimes(
    double latitude,
    double longitude,
    CalculationParameters method,
    String madhab,
    String highLatitudeRule,
    DateTime date,
  ) async {
    Coordinates coordinates = Coordinates(latitude, longitude);
    CalculationParameters params = method;
    params.madhab = _stringToMadhab(madhab);
    params.highLatitudeRule = _stringToHighLatitudeRule(highLatitudeRule);

    // Use UTC to avoid DST issues
    final nowUtc = date.toUtc();
    final targetDateUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    PrayerTimes prayerTimes = PrayerTimes(
        date: targetDateUtc,
        coordinates: coordinates,
        calculationParameters: params);
    return prayerTimes;
  }

  Future<List<DateTime>> calculatePrayerTimeFromPrayerTimes(
    PrayerTimes prayerTimes,
  ) async {
    // The adhan_dart library returns times in UTC, convert to local
    DateTime fajrTime = prayerTimes.fajr.toLocal();
    DateTime sunriseTime = prayerTimes.sunrise.toLocal();
    DateTime dhuhrTime = prayerTimes.dhuhr.toLocal();
    DateTime asrTime = prayerTimes.asr.toLocal();
    DateTime maghribTime = prayerTimes.maghrib.toLocal();
    DateTime ishaTime = prayerTimes.isha.toLocal();

    return [fajrTime, sunriseTime, dhuhrTime, asrTime, maghribTime, ishaTime];
  }

  Future<String> getTimeDifference(double latitude, double longitude) async {
    // Get device's timezone location using lat/lng
    tz.initializeTimeZones();
    String deviceTimezoneString =
        tzmap.latLngToTimezoneString(_latitude, _longitude);
    final deviceTimeZone = tz.getLocation(deviceTimezoneString);

    String cityTimezoneString =
        tzmap.latLngToTimezoneString(latitude, longitude);
    final cityTimeZone = tz.getLocation(cityTimezoneString);

    DateTime deviceTime = tz.TZDateTime.now(deviceTimeZone);
    DateTime cityTime = tz.TZDateTime.now(cityTimeZone);

    print("my tz $deviceTimezoneString, city tz $cityTimezoneString");
    print("my time:$deviceTime, city time: $cityTime");

    Duration myTzOffset = deviceTime.timeZoneOffset;
    Duration cityTzOffset = cityTime.timeZoneOffset;

    Duration offsetDifference = myTzOffset - cityTzOffset;

    int hours = offsetDifference.inHours;
    print("Hours $hours");
    int minutes = (offsetDifference.inMinutes - (hours * 60))
        .abs(); // Absolute value in case it's negative

    String aheadOrBehind = (offsetDifference.isNegative) ? "ahead" : "behind";

    if (minutes == 0 && hours != 0) {
      if (hours > 1) {
        return '${hours.toString().replaceFirst("-", "")} hours $aheadOrBehind';
      } else
        return '${hours.toString().replaceFirst("-", "")} hour $aheadOrBehind';
    } else if (minutes == 0 && hours == 0) {
      return "same time";
    } else if (hours.abs() == 1) {
      return '${hours.toString().replaceFirst("-", "")} hour and $minutes minutes $aheadOrBehind';
    } else {
      return '${hours.toString().replaceFirst("-", "")} hours and $minutes minutes $aheadOrBehind';
    }
  }

  Future<String> getCityNextPrayerName(
      PrayerTimes prayerTimes, double latitude, double longitude) async {
    tz.initializeTimeZones();
    String ti = tzmap.latLngToTimezoneString(latitude, longitude);
    final timezone = tz.getLocation(ti);
    DateTime now = tz.TZDateTime.now(timezone);

    Prayer next = prayerTimes.nextPrayer(date: now);

    return next.name;
  }

  Future<DateTime> getCityNextPrayerTime(
      PrayerTimes prayerTimes, double latitude, double longitude) async {
    tz.initializeTimeZones();
    String ti = tzmap.latLngToTimezoneString(latitude, longitude);
    final timezone = tz.getLocation(ti);
    DateTime now = tz.TZDateTime.now(timezone);
    Prayer next = prayerTimes.nextPrayer(date: now);
    // Convert UTC prayer time to local time
    DateTime nPT = prayerTimes.timeForPrayer(next).toLocal();
    return nPT;
  }

  Future<List<DateTime>> calculateCityPrayerTimeFromPrayerTimes(
      PrayerTimes prayerTimes, double latitude, double longitude) async {
    // Prayer times from adhan_dart are in UTC, convert to local
    DateTime fajrTime = prayerTimes.fajr.toLocal();
    DateTime sunriseTime = prayerTimes.sunrise.toLocal();
    DateTime dhuhrTime = prayerTimes.dhuhr.toLocal();
    DateTime asrTime = prayerTimes.asr.toLocal();
    DateTime maghribTime = prayerTimes.maghrib.toLocal();
    DateTime ishaTime = prayerTimes.isha.toLocal();

    return [fajrTime, sunriseTime, dhuhrTime, asrTime, maghribTime, ishaTime];
  }

  Future<List<City>> transformStringListToCityList(List<String> cities) async {
    List<City> cityList = [];

    for (String cityString in cities) {
      Map<String, dynamic> cityMap = json.decode(cityString);

      double latitude = double.parse(cityMap['lat']);
      double longitude = double.parse(cityMap['lng']);
      String cityName = cityMap['name'];
      PrayerTimes prayert = await calculatePrayerTimes(latitude, longitude,
          _method, _madhab, _highLatitudeRule, DateTime.now());
      List<DateTime> prayerTimeList =
          await calculateCityPrayerTimeFromPrayerTimes(
              prayert, latitude, longitude);
      String timediff = await getTimeDifference(latitude, longitude);
      String nextPrayerName1 =
          await getCityNextPrayerName(prayert, latitude, longitude);
      DateTime nextPrayerTime1 =
          await getCityNextPrayerTime(prayert, latitude, longitude);
      City city = City(
        cityName: cityName,
        latitude: latitude,
        longitude: longitude,
        prayerTimes: prayerTimeList,
        timeDifference: timediff,
        nextPrayerName: nextPrayerName1,
        nextPrayerTime: nextPrayerTime1,
      );
      cityList.add(city);
    }
    return cityList;
  }

  Future setNextPrayerNameFromPrayerTimes(
    PrayerTimes prayerTimes,
  ) async {
    Prayer next = prayerTimes.nextPrayer();
    nextPrayerName = next.name;
    // Convert from UTC to local time
    nextPrayerTime = prayerTimes.timeForPrayer(next).toLocal();

    // Determine current prayer (the one we're in now)
    final now = DateTime.now();
    final prayers = [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    currentPrayerName = 'isha'; // Default to Isha if before Fajr

    for (int i = prayers.length - 1; i >= 0; i--) {
      final prayerTime = prayerTimes.timeForPrayer(prayers[i]).toLocal();
      if (now.isAfter(prayerTime)) {
        currentPrayerName = prayers[i].name;
        // Don't highlight anything between sunrise and dhuhr
        if (currentPrayerName == 'sunrise') {
          currentPrayerName = null;
        }
        break;
      }
    }

    print('Next prayer: $nextPrayerName');
    print('Current prayer: $currentPrayerName');

    notifyListeners();
  }

  void test() {}

  Future<Position> determinePosition({bool first_launch = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && first_launch == false) {
      return Future.error("error");
    }

    if (!serviceEnabled && first_launch == true) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      return Position(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0, // Add altitudeAccuracy argument
        headingAccuracy: 1.0, // Add headingAccuracy argument
      );
    }

    permission = await Geolocator.checkPermission();

    // Check if permissions are permanently denied
    if (permission == LocationPermission.deniedForever) {
      // Return the default position of London
      return Position(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0, // Add altitudeAccuracy argument
        headingAccuracy: 1.0, // Add headingAccuracy argument
      );
    }

    // Loop until permission is granted
    while (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // If permissions are permanently denied during the loop, break out and return default position
      if (permission == LocationPermission.deniedForever) {
        return Position(
          latitude: 51.5074,
          longitude: -0.1278,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 1.0, // Add altitudeAccuracy argument
          headingAccuracy: 1.0, // Add headingAccuracy argument
        );
      }
    }

    // Once permission is granted or if it was already granted, get the position
    try {
      Position position = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          if (first_launch == true) {
            return Position(
              latitude: 51.5074,
              longitude: -0.1278,
              timestamp: DateTime.now(),
              accuracy: 1.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 1.0, // Add altitudeAccuracy argument
              headingAccuracy: 1.0, // Add headingAccuracy argument
            );
          } else {
            Position position = await Geolocator.getCurrentPosition();
            return position;
          }
          // If it times out, return London's position
        },
      );
      return position;
    } catch (e) {
      if (true) {
        print("Error obtaining current position: $e");
      }
      return Future.error("Error obtaining position");
    }
  }

  Future<void> getPrayerTimes({bool init = false, bool refresh = true}) async {
    await getAllSharedPref();
    var prayerTimes;

    // Helper function to handle common tasks
    Future<void> handlePrayerTimes(PrayerTimes prayerTimes) async {
      prayerTimesList = await calculatePrayerTimeFromPrayerTimes(prayerTimes);
      await setNextPrayerNameFromPrayerTimes(prayerTimes);
      await getMyCitiesList();
      await getFajrMissed();
      await getDhuhrMissed();
      await getAsrMissed();
      await getMaghribMissed();
      await getIshaMissed();
    }

    if (init) {
      // Initial setup
      prayerTimes = await calculatePrayerTimes(
        _latitude,
        _longitude,
        _method,
        _madhab,
        _highLatitudeRule,
        DateTime.now(),
      );
      await handlePrayerTimes(prayerTimes);
      await setCityName(_longitude, _latitude);
      await initScrollController();
      animateScrollController();

      final List<DateTime> next10DaysPrayerTimes =
          await getNext10DaysPrayerTimes();
      await schedulePrayerNotifications(next10DaysPrayerTimes);
    }

    if (refresh) {
      // Refresh prayer times
      print("deter 1");
      try {
        Position position = await determinePosition();

        await setLongitutde(position.longitude);
        await setLatitude(position.latitude);
        await setCityName(position.longitude, position.latitude);

        prayerTimes = await calculatePrayerTimes(
          position.latitude,
          position.longitude,
          _method,
          _madhab,
          _highLatitudeRule,
          DateTime.now(),
        );
        await handlePrayerTimes(prayerTimes);

        animateScrollController();

        final List<DateTime> next10DaysPrayerTimes =
            await getNext10DaysPrayerTimes();
        await schedulePrayerNotifications(next10DaysPrayerTimes);
      } catch (e) {
        // Location services are off or failed, use saved location data
        print("Location services unavailable, using saved location: $e");

        prayerTimes = await calculatePrayerTimes(
          _latitude,
          _longitude,
          _method,
          _madhab,
          _highLatitudeRule,
          DateTime.now(),
        );
        await handlePrayerTimes(prayerTimes);

        animateScrollController();

        final List<DateTime> next10DaysPrayerTimes =
            await getNext10DaysPrayerTimes();
        await schedulePrayerNotifications(next10DaysPrayerTimes);
      }
    }

    updateWidget();
    notifyListeners();
  }

  bool checkTimeFormat() {
    final now = DateTime.now();

    // Format the current time in the user's locale
    final formattedTime = DateFormat.jm().format(now);

    // Check if 'formattedTime' contains AM or PM to determine the time format
    if (formattedTime.contains('AM') || formattedTime.contains('PM')) {
      return false; // Time format is 12-hour
    } else {
      return true; // Time format is 24-hour
    }
  }

  Future<void> firstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("firstLaunch");
    if (!prefs.containsKey('latitude')) {
      print("deter 2");
      Position position = await determinePosition(first_launch: true);

      await setLatitude(position.latitude);
      await setLongitutde(position.longitude);
      if (!prefs.containsKey('cityName')) {
        await setCityName(position.longitude, position.latitude);
      }
    }

    //convert old method notation the new one
    if (prefs.containsKey("method")) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String defaultMethod = prefs.getString("method")!;
      if (defaultMethod == "Muslim World League" ||
          defaultMethod == "Umm al Qura" ||
          defaultMethod == "North America") {
        // Replace spaces with no spaces
        defaultMethod = defaultMethod.replaceAll(" ", "");
      }
      await prefs.setString("method", defaultMethod);
    }

    if (!prefs.containsKey('method')) {
      setMethod("Tehran");
    }

    if (!prefs.containsKey('madhab')) {
      setMadhab("shafi");
    }
    String convertHighLatValue(String value) {
      switch (value) {
        case "middle":
          return "middleofthenight";
        case "seventh":
          return "seventhofthenight";
        case "angle":
          return "twilightangle";
        default:
          return "unknown"; // or handle the default case accordingly
      }
    }

    if (!prefs.containsKey('highLatitudeRule') &&
        !prefs.containsKey("highLat")) {
      setHighLatitudeRule("twilightangle");
    } else if (!prefs.containsKey('highLatitudeRule') &&
        prefs.containsKey("highLat")) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String highLatValue = prefs.getString('highLat')!;
      String convertedValue = convertHighLatValue(highLatValue);
      setHighLatitudeRule(convertedValue);
    }

    if (!prefs.containsKey('timeFormat24')) {
      setTimeFormat(true);
      print("setting default");
    }

    if (!prefs.containsKey('isDarkMode')) {
      setDarkMode(false);
    }

    if (!prefs.containsKey('myCities2')) {
      await setMyCities([]);
    }

    if (!prefs.containsKey('fajrMissed')) {
      await setFajrMissed(0);
    }

    if (!prefs.containsKey('dhuhrMissed')) {
      await setDhuhrMissed(0);
    }

    if (!prefs.containsKey('asrMissed')) {
      await setAsrMissed(0);
    }

    if (!prefs.containsKey('maghribMissed')) {
      await setMaghribMissed(0);
    }

    if (!prefs.containsKey('ishaMissed')) {
      await setIshaMissed(0);
    }
    final DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    // Request notification permissions
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iOSInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (result == null || !result) {
      print("Notification permissions denied");
    } else {
      print("Notification permissions granted");
    }

    notifyListeners();
  }

  Future<void> initStateHomePage() async {
    print("initStateHomePage");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("latitude")) {
      await firstLaunch();
    }

    await loadNotificationPreferences();
    await getPrayerTimes(init: true, refresh: false);
  }

  //notifications
  Future<void> schedulePrayerNotifications(
    List<DateTime> prayerTimes,
  ) async {
    await NotificationApi.init(initScheduled: true);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.cancelAll();

    const prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 0; i < prayerTimes.length; i++) {
      final int prayerIndex = i % prayerNames.length;

      // Skip notifications for sunrise
      if (prayerIndex == 1) continue;

      final prayerName = prayerNames[prayerIndex];

      // Skip if notification is disabled for this prayer
      if (!isPrayerNotificationEnabled(prayerName)) continue;

      // Check if the scheduled date has already passed
      if (prayerTimes[i].isAfter(DateTime.now())) {
        await NotificationApi.showScheduledNotification(
          id: i,
          title: '$prayerName Time',
          body: _timeFormat24
              ? DateFormat('HH:mm').format(prayerTimes[i])
              : DateFormat('h:mm a').format(prayerTimes[i]),
          payload: _timeFormat24
              ? DateFormat('HH:mm').format(prayerTimes[i])
              : DateFormat('h:mm a').format(prayerTimes[i]),
          scheduledDate: prayerTimes[i],
        );
      } else {
        print('Skipped scheduling for $prayerName as the time has passed.');
      }
    }

    var pendingNotificationRequests2 =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (int i = 0; i < pendingNotificationRequests2.length; i++) {
      print(pendingNotificationRequests2[i].payload.toString());
    }
  }

  Future<List<DateTime>> getNext10DaysPrayerTimes() async {
    List<DateTime> next10Days = [];

    for (int i = 0; i < 10; i++) {
      PrayerTimes prayert = await calculatePrayerTimes(
        _latitude,
        _longitude,
        _method,
        _madhab,
        _highLatitudeRule,
        DateTime.now().add(Duration(days: i)),
      );
      next10Days.addAll(await calculatePrayerTimeFromPrayerTimes(prayert));
    }

    return next10Days;
  }
}
