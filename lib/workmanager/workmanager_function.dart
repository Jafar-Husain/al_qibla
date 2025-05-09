import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final Map<String, CalculationParameters> calculationMethodsMap = {
  'MuslimWorldLeague': CalculationMethod.muslimWorldLeague(),
  'Egyptian': CalculationMethod.egyptian(),
  'Karachi': CalculationMethod.karachi(),
  'UmmAlQura': CalculationMethod.ummAlQura(),
  'Dubai': CalculationMethod.dubai(),
  'MoonsightingCommittee': CalculationMethod.moonsightingCommittee(),
  'NorthAmerica': CalculationMethod.northAmerica(),
  'Kuwait': CalculationMethod.kuwait(),
  'Qatar': CalculationMethod.qatar(),
  'Singapore': CalculationMethod.singapore(),
  'Tehran': CalculationMethod.tehran(),
  'Turkey': CalculationMethod.turkiye(),
  'Morocco': CalculationMethod.morocco(),
};

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
  params.madhab = madhab;
  params.highLatitudeRule = highLatitudeRule;
  PrayerTimes prayerTimes = PrayerTimes(
    date: date,
    coordinates: coordinates,
    calculationParameters: params,
  );
  return prayerTimes;
}

Future<List> setNextPrayerNameFromPrayerTimes(
  PrayerTimes prayerTimes,
) async {
  tz.initializeTimeZones();
  String ti = await FlutterNativeTimezone.getLocalTimezone();
  final timezone = tz.getLocation(ti);
  String next = prayerTimes.nextPrayer();

  return [next, tz.TZDateTime.from(prayerTimes.timeForPrayer(next)!, timezone)];
}

Future<bool?> updateWidget() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get saved parameters
  double longitude = prefs.getDouble("longitude")!;
  double latitude = prefs.getDouble("latitude")!;
  String method = prefs.getString("method")!;
  String madhab = prefs.getString("madhab")!;
  String highLatitudeRule = prefs.getString("highLatitudeRule")!;
  String cityName = prefs.getString("cityName")!;

  // Pass only the parameters to the widget, not the calculated times
  await HomeWidget.saveWidgetData<double>("latitude", latitude);
  await HomeWidget.saveWidgetData<double>("longitude", longitude);
  await HomeWidget.saveWidgetData<String>("method", method);
  await HomeWidget.saveWidgetData<String>("madhab", madhab);
  await HomeWidget.saveWidgetData<String>("highLatitudeRule", highLatitudeRule);
  await HomeWidget.saveWidgetData<String>("cityName", cityName);

  // Set a last updated timestamp for the widget to know data is fresh
  await HomeWidget.saveWidgetData<int>(
      "lastUpdated", DateTime.now().millisecondsSinceEpoch);

  // Update the widget
  await HomeWidget.updateWidget(
    name: 'FajrtoDhuhrWidget',
    iOSName: 'FajrtoDhuhrWidget',
  );
  await HomeWidget.updateWidget(
    name: 'AsrToIshaWidget',
    iOSName: 'AsrToIshaWidget',
  );
  return await HomeWidget.updateWidget(
    name: 'alQiblaWidget',
    iOSName: 'alQiblaWidget',
  );
}
