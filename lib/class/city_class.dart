class City {
  String cityName;
  double latitude;
  double longitude;
  List<DateTime> prayerTimes;
  String timeDifference;
  String nextPrayerName;
  DateTime nextPrayerTime;

  City({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.prayerTimes,
    required this.timeDifference,
    required this.nextPrayerName,
    required this.nextPrayerTime
  });
}
