import Combine // <--- التعديل الأول: لاستخدام ObservableObject و @Published
import Foundation

// ملاحظة: هذا الكود يفترض أنك عرّفت CalendarMonth و CalendarDay
// في مكان آخر كـ "typealias" لـ Date.
// مثال:
// typealias CalendarMonth = Date
// typealias CalendarDay = Date

final class CalendarViewModel: ObservableObject {
    @Published var months: [CalendarMonth] = []
    @Published var goalCompleted = false // ✅ يحدد إذا اكتمل الهدف بناءً على التاريخ
    
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
        // التعديل الثاني: تم تغيير نوع المصفوفة ليطابق نوع الإرجاع
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
        
        // هذه الدالة تُرجع [Date]، وهي تعمل طالما أن CalendarDay هو typealias لـ Date
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }
    
    func leadingSpaces(for month: CalendarMonth) -> Int {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: startOfMonth)
        return weekday - 1 // (يعتمد على أن الأسبوع يبدأ بالأحد = 1)
    }
    // ✅ تحقق من الهدف بناءً على عدد الأيام بين startDate واليوم الحالي
    func checkGoalProgress() {
        let now = Date()
        let daysPassed = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
        
        // تحقق من أسبوع / شهر / سنة
        if daysPassed >= 7 || daysPassed >= 30 || daysPassed >= 365 {
            goalCompleted = true
        }
    }
}

