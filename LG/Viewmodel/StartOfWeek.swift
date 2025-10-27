// Calendar+StartOfWeek.swift
import Foundation

extension Calendar {
    /// Returns the start of the week for the given date, honoring the calendar's `firstWeekday`.
    func startOfWeek(for date: Date) -> Date {
        // Normalize to start of day first
        let startOfDay = self.startOfDay(for: date)

        // Ask the calendar for the week interval containing this day
        if let weekInterval = dateInterval(of: .weekOfYear, for: startOfDay) {
            // dateInterval(of: .weekOfYear, for:) already respects `firstWeekday`
            return weekInterval.start
        }

        // Fallback: compute manually using weekday and firstWeekday
        let weekday = component(.weekday, from: startOfDay)
        // Distance (in days) from the first weekday
        let delta = (weekday - firstWeekday + 7) % 7
        return self.date(byAdding: .day, value: -delta, to: startOfDay) ?? startOfDay
    }
}
