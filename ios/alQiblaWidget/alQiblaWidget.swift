import WidgetKit
import SwiftUI

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
            // Update timeline after some time (every 30 minutes or when data changes)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    // Get data shared by the Flutter app
    private func getWidgetData(completion: @escaping (SimpleEntry) -> Void) {
        // Default values
        let now = Date()
        var entry = SimpleEntry(
            date: now,
            fajr: Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: now)!,
            dhuhr: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: now)!,
            asr: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: now)!,
            maghrib: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: now)!,
            isha: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: now)!,
            city: "Unknown"
        )
        
        // Get data from AppGroup - this needs to match your app group ID
        let userDefaults = UserDefaults(suiteName:  "group.com.jafar.alQiblaWidget")
        
        if let userDefaults = userDefaults {
            // Get timestamps from Flutter app
            if let fajrTime = userDefaults.object(forKey: "fajrTime") as? Int {
                entry.fajr = Date(timeIntervalSince1970: TimeInterval(fajrTime) / 1000)
            }
            
            if let dhuhrTime = userDefaults.object(forKey: "dhuhrTime") as? Int {
                entry.dhuhr = Date(timeIntervalSince1970: TimeInterval(dhuhrTime) / 1000)
            }
            
            if let asrTime = userDefaults.object(forKey: "asrTime") as? Int {
                entry.asr = Date(timeIntervalSince1970: TimeInterval(asrTime) / 1000)
            }
            
            if let maghribTime = userDefaults.object(forKey: "maghribTime") as? Int {
                entry.maghrib = Date(timeIntervalSince1970: TimeInterval(maghribTime) / 1000)
            }
            
            if let ishaTime = userDefaults.object(forKey: "ishaTime") as? Int {
                entry.isha = Date(timeIntervalSince1970: TimeInterval(ishaTime) / 1000)
            }
            
            if let cityName = userDefaults.string(forKey: "cityName") {
                entry.city = cityName
            }
        }
        
        completion(entry)
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

    var body: some View {
        let isDark = colorScheme == .dark
        let textColor = isDark ? Color.white : Color.black
        
        let nextPrayer = nextPrayerTime(from: entry)
        
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

    func nextPrayerTime(from entry: SimpleEntry) -> (name: String, time: Date) {
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

// MARK: - Widget Declaration
struct alQiblaWidget: Widget {
    let kind: String = "alQiblaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                alQiblaWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                alQiblaWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Prayer Times")
        .description("Displays daily Islamic prayer times.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
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
