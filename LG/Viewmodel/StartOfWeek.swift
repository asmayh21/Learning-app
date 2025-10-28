import Foundation

extension Calendar {

    func startOfWeek(for date: Date) -> Date {
        let startOfDay = self.startOfDay(for: date)

        if let weekInterval = dateInterval(of: .weekOfYear, for: startOfDay) {
            return weekInterval.start
        }

        let weekday = component(.weekday, from: startOfDay)
        let delta = (weekday - firstWeekday + 7) % 7
        return self.date(byAdding: .day, value: -delta, to: startOfDay) ?? startOfDay
    }
}
