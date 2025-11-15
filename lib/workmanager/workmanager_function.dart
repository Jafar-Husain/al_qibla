import 'package:adhan_dart/adhan_dart.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

final Map<String, CalculationParameters> calculationMethodsMap = {
  'MuslimWorldLeague': CalculationMethodParameters.muslimWorldLeague(),
  'Egyptian': CalculationMethodParameters.egyptian(),
  'Karachi': CalculationMethodParameters.karachi(),
  'UmmAlQura': CalculationMethodParameters.ummAlQura(),
  'Dubai': CalculationMethodParameters.dubai(),
  'MoonsightingCommittee': CalculationMethodParameters.moonsightingCommittee(),
  'NorthAmerica': CalculationMethodParameters.northAmerica(),
  'Kuwait': CalculationMethodParameters.kuwait(),
  'Qatar': CalculationMethodParameters.qatar(),
  'Singapore': CalculationMethodParameters.singapore(),
  'Tehran': CalculationMethodParameters.tehran(),
  'Turkey': CalculationMethodParameters.turkiye(),
  'Morocco': CalculationMethodParameters.morocco(),
};

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
  final nowUtc = date.toUtc();
  final targetDateUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
  PrayerTimes prayerTimes = PrayerTimes(
    date: targetDateUtc,
    coordinates: coordinates,
    calculationParameters: params,
  );
  return prayerTimes;
}

Future<List> setNextPrayerNameFromPrayerTimes(
  PrayerTimes prayerTimes,
) async {
  tzdata.initializeTimeZones();
  final timezone = tz.local;
  final now = tz.TZDateTime.now(timezone);
  Prayer next = prayerTimes.nextPrayer(date: now);

  final nextTimeLocal = prayerTimes.timeForPrayer(next).toLocal();
  return [next.name, tz.TZDateTime.from(nextTimeLocal, timezone)];
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
