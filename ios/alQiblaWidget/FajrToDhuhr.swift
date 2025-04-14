//
//  AsrToIshaWidget.swift
//  Runner
//
//  Created by Jafar Husain on 14.04.2025.
//

import WidgetKit
import SwiftUI
import Adhan

// MARK: - Widget Declaration
struct FajrToDhuhrWidget: Widget {
    let kind: String = "FajrToDhuhrWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                // Use environment to determine where widget is being displayed
                FajrToDhuhrWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FajrToDhuhrWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Morning Prayers")
        .description("Displays Fajr, Sunrise and Dhuhr prayer times.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Widget View
struct FajrToDhuhrWidgetView: View {
    var entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        let textColor = Color.white // Using white for lock screen visibility
        
        HStack(spacing: 5) {
            // Using more appropriate icons for morning prayers
            PrayerTimeView(label: "FJR", icon: "sun.and.horizon.fill", time: format(entry.fajr))
            PrayerTimeView(label: "SUN", icon: "sunrise.fill", time: format(entry.sunrise))
            PrayerTimeView(label: "DHU", icon: "sun.max.fill", time: format(entry.dhuhr))
        }
    }
    
    struct PrayerTimeView: View {
        let label: String
        let icon: String
        let time: String

        var body: some View {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                    .foregroundColor(.white)
                    

                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(time)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview(as: .accessoryRectangular) {
    FajrToDhuhrWidget()
} timeline: {
    SimpleEntry(
        date: Calendar.current.date(bySettingHour: 00, minute: 30, second: 0, of: .now)!,
        fajr: Calendar.current.date(bySettingHour: 5, minute: 43, second: 0, of: .now)!,
        sunrise: Calendar.current.date(bySettingHour: 6, minute: 43, second: 0, of: .now)!,
        dhuhr: Calendar.current.date(bySettingHour: 13, minute: 3, second: 0, of: .now)!,
        asr: Calendar.current.date(bySettingHour: 18, minute: 5, second: 0, of: .now)!,
        maghrib: Calendar.current.date(bySettingHour: 22, minute: 45, second: 0, of: .now)!,
        isha: Calendar.current.date(bySettingHour: 23, minute: 11, second: 0, of: .now)!,
        city: "Genève"
    )
}
