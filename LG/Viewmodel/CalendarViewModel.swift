import Combine
import Foundation


final class CalendarViewModel: ObservableObject {
    @Published var months: [CalendarMonth] = []
    @Published var goalCompleted = false
    @Published var dayStatuses: [Date: DayStatus] = [:] // ✅ لحفظ حالة الأيام (learned / freezed)

    private let calendar = Calendar.current
    private let startDate: Date
    private let endDate: Date

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.months = generateMonths()
        checkGoalProgress()
    }

    private func generateMonths() -> [CalendarMonth] {
        var months: [CalendarMonth] = []
        var current = startDate

        while current <= endDate {
            months.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        return months
    }

    var shortWeekdaySymbols: [String] {
        calendar.shortWeekdaySymbols
    }

    func daysInMonth(for month: CalendarMonth) -> [CalendarDay] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    func leadingSpaces(for month: CalendarMonth) -> Int {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: startOfMonth)
        return weekday - 1 // (يعتمد على أن الأسبوع يبدأ بالأحد = 1)
    }

    func updateDayStatus(for date: Date, status: DayStatus) {
        let key = calendar.startOfDay(for: date)
        dayStatuses[key] = status
    }

    func statusForDay(_ date: Date) -> DayStatus {
        let key = calendar.startOfDay(for: date)
        return dayStatuses[key] ?? .none
    }

    func checkGoalProgress() {
        let now = Date()
        let daysPassed = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0

        if daysPassed >= 7 || daysPassed >= 30 || daysPassed >= 365 {
            goalCompleted = true
        }
    }
}
