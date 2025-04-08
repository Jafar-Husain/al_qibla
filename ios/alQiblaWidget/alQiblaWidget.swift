import WidgetKit
import SwiftUI
import Adhan

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            fajr: Date(),
            dhuhr: Date(),
            asr: Date(),
            maghrib: Date(),
            isha: Date(),
            city: "Loading..."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        getWidgetData { entry in
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        getWidgetData { entry in
            // Create multiple entries for today and tomorrow
            var entries: [SimpleEntry] = [entry]
            
            // Calculate when the next prayer time is
            let nextPrayerTime = self.nextPrayerTime(from: entry)
            
            // Schedule an update right after the next prayer
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: nextPrayerTime.time)!
            
            // Add an entry for tomorrow too
            if let tomorrowEntry = self.calculateTomorrowEntry(from: entry) {
                entries.append(tomorrowEntry)
            }
            
            // Create a timeline that updates after the next prayer
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    // Get data shared by the Flutter app or calculate locally
    private func getWidgetData(completion: @escaping (SimpleEntry) -> Void) {
        // Get data from AppGroup
        let userDefaults = UserDefaults(suiteName: "group.com.jafar.alQiblaWidget")
        
        // Default parameters
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        var calculationMethod: String = "MoonsightingCommittee"
        var madhab: String = "shafi"
        var highLatitudeRule: String = "middle_of_the_night"
        var cityName: String = "Unknown"
        var lastUpdated: Date? = nil
        
        // Read parameters from UserDefaults (passed from Flutter)
        if let userDefaults = userDefaults {
            latitude = userDefaults.double(forKey: "latitude")
            longitude = userDefaults.double(forKey: "longitude")
            calculationMethod = userDefaults.string(forKey: "method") ?? calculationMethod
            madhab = userDefaults.string(forKey: "madhab") ?? madhab
            highLatitudeRule = userDefaults.string(forKey: "highLatitudeRule") ?? highLatitudeRule
            cityName = userDefaults.string(forKey: "cityName") ?? cityName
            
            if let lastUpdatedTimestamp = userDefaults.object(forKey: "lastUpdated") as? Int {
                lastUpdated = Date(timeIntervalSince1970: TimeInterval(lastUpdatedTimestamp) / 1000)
            }
        }
        
        // Calculate prayer times directly in Swift
        let entry = calculatePrayerTimes(
            latitude: latitude,
            longitude: longitude,
            calculationMethod: calculationMethod,
            madhab: madhab,
            highLatitudeRule: highLatitudeRule,
            cityName: cityName,
            forDate: Date()
        )
        
        completion(entry)
    }
    
    // Calculate prayer times for tomorrow
    private func calculateTomorrowEntry(from entry: SimpleEntry) -> SimpleEntry? {
        let userDefaults = UserDefaults(suiteName: "group.com.jafar.alQiblaWidget")
        
        guard let userDefaults = userDefaults else { return nil }
        
        let latitude = userDefaults.double(forKey: "latitude")
        let longitude = userDefaults.double(forKey: "longitude")
        let calculationMethod = userDefaults.string(forKey: "method") ?? "MoonsightingCommittee"
        let madhab = userDefaults.string(forKey: "madhab") ?? "shafi"
        let highLatitudeRule = userDefaults.string(forKey: "highLatitudeRule") ?? "middle_of_the_night"
        let cityName = userDefaults.string(forKey: "cityName") ?? "Unknown"
        
        // Tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        return calculatePrayerTimes(
            latitude: latitude,
            longitude: longitude,
            calculationMethod: calculationMethod,
            madhab: madhab,
            highLatitudeRule: highLatitudeRule,
            cityName: cityName,
            forDate: tomorrow
        )
    }
    
    // Calculate prayer times using Adhan Swift library
    private func calculatePrayerTimes(
        latitude: Double,
        longitude: Double,
        calculationMethod: String,
        madhab: String,
        highLatitudeRule: String,
        cityName: String,
        forDate: Date
    ) -> SimpleEntry {
        // Create coordinates
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        
        // Set calculation parameters based on method
        var params: CalculationParameters
        
        switch calculationMethod {
        case "MuslimWorldLeague":
            params = CalculationMethod.muslimWorldLeague.params
        case "Egyptian":
            params = CalculationMethod.egyptian.params
        case "Karachi":
            params = CalculationMethod.karachi.params
        case "UmmAlQura":
            params = CalculationMethod.ummAlQura.params
        case "Dubai":
            params = CalculationMethod.dubai.params
        case "MoonsightingCommittee":
            params = CalculationMethod.moonsightingCommittee.params
        case "NorthAmerica":
            params = CalculationMethod.northAmerica.params
        case "Kuwait":
            params = CalculationMethod.kuwait.params
        case "Qatar":
            params = CalculationMethod.qatar.params
        case "Singapore":
            params = CalculationMethod.singapore.params
        case "Turkey":
            params = CalculationMethod.turkey.params
        case "Tehran":
            params = CalculationMethod.tehran.params
            var params = CalculationMethod.other.params
                params.fajrAngle = 19
                params.ishaAngle = 17
                params.adjustments.sunrise = -3
                params.adjustments.dhuhr = 5
                params.adjustments.maghrib = 5

                
        default:
            params = CalculationMethod.moonsightingCommittee.params
        }
        
        // Set madhab
        if madhab == "hanafi" {
            params.madhab = .hanafi
        } else {
            params.madhab = .shafi
        }
        
        // Set high latitude rule
        switch highLatitudeRule {
        case "middle_of_the_night":
            params.highLatitudeRule = .middleOfTheNight
        case "seventh_of_the_night":
            params.highLatitudeRule = .seventhOfTheNight
        case "twilight_angle":
            params.highLatitudeRule = .twilightAngle
        default:
            params.highLatitudeRule = .middleOfTheNight
        }
        
        // Create prayer times
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: forDate)
        let prayerTimes = PrayerTimes(coordinates: coordinates, date: dateComponents, calculationParameters: params)
        
        // Create entry with calculated times
        return SimpleEntry(
            date: forDate,
            fajr: prayerTimes!.fajr,
            dhuhr: prayerTimes!.dhuhr,
            asr: prayerTimes!.asr,
            maghrib: prayerTimes!.maghrib,
            isha: prayerTimes!.isha,
            city: cityName
        )
    }
    
    // Helper function to find next prayer time
    private func nextPrayerTime(from entry: SimpleEntry) -> (name: String, time: Date) {
        let now = Date()
        let prayers = [
            ("Fajr", entry.fajr),
            ("Dhuhr", entry.dhuhr),
            ("Asr", entry.asr),
            ("Maghrib", entry.maghrib),
            ("Isha", entry.isha)
        ]
        
        // Filter out prayers that have passed
        let upcomingPrayers = prayers.filter { $0.1 > now }
        
        // Find the closest upcoming prayer
        if let next = upcomingPrayers.min(by: { $0.1 < $1.1 }) {
            return next
        } else {
            // If all prayers passed, return the first prayer for tomorrow
            return ("Fajr (Tomorrow)", entry.fajr)
        }
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    var fajr: Date
    var dhuhr: Date
    var asr: Date
    var maghrib: Date
    var isha: Date
    var city: String
}

// MARK: - Main View
struct alQiblaWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    var body: some View {
        let isDark = colorScheme == .dark
        let textColor = isDark ? Color.white : Color.black
        let nextPrayer = nextPrayerTime(from: entry)

        switch family {
        case .accessoryCircular:
            // LOCKSCREEN circular widget
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.5))
                VStack(spacing: 2) {
                    Text(getAbbreviation(for: nextPrayer.name))
                        .font(.caption)
                        .foregroundColor(textColor)
                    Text(format(nextPrayer.time))
                        .font(.system(size: 15))
                        .foregroundColor(textColor)
                }
            }

        default:
            // REGULAR WIDGET
            HStack(spacing: 16) {
                // LEFT SIDE — Highlighted Prayer
                VStack(alignment: .leading, spacing: 4) {
                    Text(nextPrayer.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text(format(nextPrayer.time))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(entry.city)
                            .font(.caption)
                            .foregroundColor(textColor)
                    }
                    .padding(.top, 4)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // RIGHT SIDE — Prayer Times
                VStack(alignment: .leading) {
                    prayerRow(name: "Fajr", time: format(entry.fajr), textColor: textColor)
                    Spacer()
                    prayerRow(name: "Dhuhr", time: format(entry.dhuhr), textColor: textColor)
                    Spacer()
                    prayerRow(name: "Asr", time: format(entry.asr), textColor: textColor)
                    Spacer()
                    prayerRow(name: "Maghrib", time: format(entry.maghrib), textColor: textColor)
                    Spacer()
                    prayerRow(name: "Isha", time: format(entry.isha), textColor: textColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding()
        }
    }

    func prayerRow(name: String, time: String, textColor: Color) -> some View {
        HStack {
            Text(name)
                .font(.caption)
                .foregroundColor(textColor)
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundColor(textColor)
        }
    }

    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    func getAbbreviation(for prayerName: String) -> String {
        switch prayerName {
        case "Fajr": return "FJR"
        case "Dhuhr": return "DHU"
        case "Asr": return "ASR"
        case "Maghrib": return "MGH"
        case "Isha": return "ISH"
        default: return "FJR"
        }
    }

    func nextPrayerTime(from entry: SimpleEntry) -> (name: String, time: Date) {
        let now = Date()
        let prayers = [
            ("Fajr", entry.fajr),
            ("Dhuhr", entry.dhuhr),
            ("Asr", entry.asr),
            ("Maghrib", entry.maghrib),
            ("Isha", entry.isha)
        ]

        if let next = prayers.first(where: { $0.1 > now }) {
            return next
        }
        // If all prayers passed, fallback to next day's Fajr
        return ("Fajr", entry.fajr)
    }
}






// MARK: - Widget Declaration
struct alQiblaWidget: Widget {
    let kind: String = "alQiblaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                            // Use environment to determine where widget is being displayed
                            @Environment(\.widgetFamily) var family
                            
                            if family == .accessoryCircular {
                                // Lock Screen Widget
                                alQiblaWidgetEntryView(entry: entry)
                            } else {
                                // Original Home Screen Widget
                                alQiblaWidgetEntryView(entry: entry)
                                    .containerBackground(.fill.tertiary, for: .widget)
                            }
                        } else {
                            alQiblaWidgetEntryView(entry: entry)
                                .padding()
                                .background()
                        }
        }
        .configurationDisplayName("Prayer Times")
        .description("Displays daily Islamic prayer times.")
        .supportedFamilies([.systemMedium,.accessoryCircular,])
    }
}

// MARK: - Preview
#Preview(as: .accessoryCircular) {
    alQiblaWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        fajr: Calendar.current.date(bySettingHour: 5, minute: 43, second: 0, of: .now)!,
        dhuhr: Calendar.current.date(bySettingHour: 13, minute: 3, second: 0, of: .now)!,
        asr: Calendar.current.date(bySettingHour: 16, minute: 5, second: 0, of: .now)!,
        maghrib: Calendar.current.date(bySettingHour: 18, minute: 45, second: 0, of: .now)!,
        isha: Calendar.current.date(bySettingHour: 20, minute: 11, second: 0, of: .now)!,
        city: "Genève"
    )
}
