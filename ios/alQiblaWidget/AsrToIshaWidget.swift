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
struct AsrToIshaWidget: Widget {
    let kind: String = "AsrToIshaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                // Use environment to determine where widget is being displayed
                AsrToIshaWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AsrToIshaWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Evening Prayers")
        .description("Displays Asr, Maghrib and Isha prayer times.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Widget View
struct AsrToIshaWidgetView: View {
    var entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        let textColor = Color.white // Using white for lock screen visibility
        
        HStack(spacing: 5) {
            // Only showing Asr, Maghrib, and Isha
            PrayerTimeView(label: "ASR", icon: "cloud.sun.fill", time: format(entry.asr))
            PrayerTimeView(label: "MGH", icon: "sunset.fill", time: format(entry.maghrib))
            PrayerTimeView(label: "ISH", icon: "moon.fill", time: format(entry.isha))
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
    AsrToIshaWidget()
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
