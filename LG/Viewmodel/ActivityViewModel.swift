import Foundation
import Combine
import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    
   
    static let shared = ActivityViewModel(topic: "Learning", period: .week)
    
    // MARK: - Published Variables
    @Published var selectedDate = Date()
    @Published var currentWeekStart = Calendar.current.startOfWeek(for: Date())
    @Published var learnedStreak = 0
    @Published var freezeCount = 0
    @Published var dayStatuses: [Date: DayStatus] = [:]
    @Published var isGoalCompleted = false
    @Published var showSheet = false
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var learningTopic: String
    @Published var goalCompleted: Bool = false
    var calendarViewModel: CalendarViewModel?
    
    // MARK: - Goal Dates
    let goalStartDate: Date
    let goalEndDate: Date
    
    internal var goalDays: Int
    let months = Calendar.current.monthSymbols
    let years = (Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 10)
    let maxFreezes = 2
    
    // MARK: - Colors
    let defaultColor = Color("Color")
    let learnedColor = Color(red: 0.6, green: 0.3, blue: 0.1)
    let freezedColor = Color("Reg")
    let freezedButtonColor = Color(red: 86/255, green: 105/255, blue: 106/255) // لون الزر فريز
    let defaultCalendarColor = Color.orange.opacity(0.5)
    let learnedCalendarColor = Color(red: 0.8, green: 0.4, blue: 0.2)
    let freezedCalendarColor = Color.cyan.opacity(0.6)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(topic: String, period: LearningPeriod) {
        self.learningTopic = topic
        self.goalDays = period.days
        self.goalStartDate = Date()
        self.goalEndDate = Calendar.current.date(byAdding: .day, value: period.days, to: self.goalStartDate) ?? Date()
        
        $selectedMonth
            .dropFirst()
            .sink { [weak self] _ in self?.updateSelectedDate() }
            .store(in: &cancellables)
        
        $selectedYear
            .dropFirst()
            .sink { [weak self] _ in self?.updateSelectedDate() }
            .store(in: &cancellables)
    }
    
    // MARK: - Date Helpers
    func prepareSheetPickers() {
        let cal = Calendar.current
        selectedMonth = cal.component(.month, from: selectedDate)
        selectedYear = cal.component(.year, from: selectedDate)
    }
    
    func updateSelectedDate() {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = min(calendar.component(.day, from: selectedDate), 28)
        
        let newDate = calendar.date(from: comps)
            ?? calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))
            ?? Date()
        
        selectedDate = newDate
        currentWeekStart = calendar.startOfWeek(for: newDate)
    }
    
    // MARK: - Week Navigation
    func moveWeek(by offset: Int) {
        let cal = Calendar.current
        guard let newWeekStart = cal.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else {
            return
        }
        currentWeekStart = cal.startOfWeek(for: newWeekStart)
    }
    
    func moveToCurrentWeek() {
        let cal = Calendar.current
        currentWeekStart = cal.startOfWeek(for: Date())
        selectedDate = Date()
    }
    
    // MARK: - Goal Control
    func setNewGoal() {
        learnedStreak = 0
        freezeCount = 0
        dayStatuses.removeAll()
        isGoalCompleted = false
        moveToCurrentWeek()
    }
    
    func resetSameGoal() {
        learnedStreak = 0
        freezeCount = 0
        dayStatuses.removeAll()
        isGoalCompleted = false
        moveToCurrentWeek()
    }
    
    // MARK: - Computed Properties
    var selectedDayStatus: DayStatus {
        let key = Calendar.current.startOfDay(for: selectedDate)
        return dayStatuses[key] ?? .none
    }
    
    var mainCircleText: String {
        switch selectedDayStatus {
        case .learned: return "Learned Today"
        case .freezed: return "Day Freezed"
        case .none:    return "Log as Learned"
        }
    }
    
    var mainCircleColor: Color {
        switch selectedDayStatus {
        case .learned: return learnedColor
        case .freezed: return freezedColor
        case .none:    return defaultColor.opacity(0.6)
        }
    }
    
    var calendarDayColor: Color {
        switch selectedDayStatus {
        case .learned: return learnedCalendarColor
        case .freezed: return freezedCalendarColor
        case .none:    return defaultCalendarColor
        }
    }
    
    var freezeCountText: String {
        "\(freezeCount) out of \(maxFreezes) Freezes used"
    }
    
    // MARK: - Toggle Status
    func toggleDayStatus(_ status: DayStatus) {
        let key = Calendar.current.startOfDay(for: selectedDate)
        let current = dayStatuses[key] ?? .none
        
        if current == status {
            dayStatuses[key] = .none
            if status == .learned { learnedStreak = max(0, learnedStreak - 1) }
            if status == .freezed { freezeCount = max(0, freezeCount - 1) }
        } else {
            dayStatuses[key] = status
            switch status {
            case .learned:
                learnedStreak += 1
                if current == .freezed { freezeCount = max(0, freezeCount - 1) }
            case .freezed:
                if freezeCount < maxFreezes {
                    freezeCount += 1
                } else {
                    dayStatuses[key] = current
                }
                if current == .learned { learnedStreak = max(0, learnedStreak - 1) }
            case .none:
                break
            }
        }
        
        calendarViewModel?.updateDayStatus(for: selectedDate, status: status)
        
        if learnedStreak >= goalDays {
            isGoalCompleted = true
        } else {
            isGoalCompleted = false
        }
    }
    
    // MARK: - Reset for new goal
    func resetForNewGoal(topic: String, period: LearningPeriod) {
        self.learningTopic = topic
        self.learnedStreak = 0
        self.freezeCount = 0
        self.dayStatuses.removeAll()
        self.isGoalCompleted = false

        self.currentWeekStart = Calendar.current.startOfWeek(for: Date())
        self.selectedDate = Date()
        self.goalDays = period.days

        print(" تم إعادة تعيين الهدف إلى: \(topic) لمدة \(period.days) يوم")
    }
}
