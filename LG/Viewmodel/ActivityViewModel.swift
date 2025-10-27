import Foundation
import Combine
import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    
    // ... (كل المتغيرات @Published كما هي) ...
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
    
    
    // --- (هذان هما المتغيران الجديدان) ---
    let goalStartDate: Date // تاريخ بداية الهدف
    let goalEndDate: Date   // تاريخ نهاية الهدف
    // --- (نهاية الإضافة) ---
    
    private var goalDays: Int
    let months = Calendar.current.monthSymbols
    let years = (Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 10)
    let maxFreezes = 2
    
    // الألوان
    let defaultColor = Color("Color")
    let learnedColor = Color(red: 0.6, green: 0.3, blue: 0.1)
    let freezedColor = Color("Reg")
    let freezedButtonColor = Color.coldBlue.opacity(0.3)   // 🎨 ألوان مخصصة للكالندر لما تتغير حالة الدائرة
    let defaultCalendarColor = Color.orange.opacity(0.5)
    let learnedCalendarColor = Color(red: 0.8, green: 0.4, blue: 0.2) // افتح شوي من لون الدائرة
    let freezedCalendarColor = Color.cyan.opacity(0.6)
    
    private var cancellables = Set<AnyCancellable>()

    init(topic: String, period: LearningPeriod) {
        self.learningTopic = topic
        self.goalDays = period.days
        
        // --- (هذا هو التعديل) ---
        self.goalStartDate = Date() // افترضنا أن الهدف يبدأ "الآن"
        self.goalEndDate = Calendar.current.date(byAdding: .day, value: period.days, to: self.goalStartDate) ?? Date()
        // --- (نهاية التعديل) ---
        
        // (باقي كود الـ init)
        $selectedMonth
            .dropFirst()
            .sink { [weak self] _ in self?.updateSelectedDate() }
            .store(in: &cancellables)
            
        $selectedYear
            .dropFirst()
            .sink { [weak self] _ in self?.updateSelectedDate() }
            .store(in: &cancellables)
    }
    
    // مزامنة الـ pickers مع التاريخ الحالي عند فتح الـ sheet
    func prepareSheetPickers() {
        let cal = Calendar.current
        selectedMonth = cal.component(.month, from: selectedDate)
        selectedYear = cal.component(.year, from: selectedDate)
    }
    
    // MARK: - Date Helpers
    // تقوم هذه الدالة بتحديث selectedDate بناءً على selectedMonth و selectedYear
    func updateSelectedDate() {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = min(calendar.component(.day, from: selectedDate), 28) // ضمان يوم صالح دائماً
        // إذا لم يتمكن من إنشاء التاريخ (في حالات نادرة)، ن fallback لأول يوم في الشهر
        let newDate = calendar.date(from: comps)
            ?? calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))
            ?? Date()
        selectedDate = newDate
        currentWeekStart = calendar.startOfWeek(for: newDate)
    }
    
    // MARK: - Week navigation
    func moveWeek(by offset: Int) {
        let cal = Calendar.current
        guard let newWeekStart = cal.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else {
            return
        }
        currentWeekStart = cal.startOfWeek(for: newWeekStart)
        
        // Keep selectedDate within the newly selected week using same weekday offset
        let oldStart = cal.startOfWeek(for: selectedDate)
        let weekdayOffset = cal.dateComponents([.day], from: oldStart, to: selectedDate).day ?? 0
        if let newSelected = cal.date(byAdding: .day, value: weekdayOffset, to: currentWeekStart) {
            selectedDate = newSelected
        } else {
            selectedDate = currentWeekStart
        }
        
        // If needed, refresh week-related data here.
        // updateDayStatusesForCurrentWeek()
    }
    
    // Optional helper
    func moveToCurrentWeek() {
        let cal = Calendar.current
        currentWeekStart = cal.startOfWeek(for: Date())
        selectedDate = Date()
    }
    
    // MARK: - Actions used by ActivityView (added to fix compile errors)
    // Stub behavior you can refine:
    // - setNewGoal(): clears progress and marks goal as not completed; you could navigate back to onboarding to pick a new topic/period.
    // - resetSameGoal(): clears progress but keeps same topic/period/duration.
    func setNewGoal() {
        // Basic reset of progress; in a real app you might route back to onboarding.
        learnedStreak = 0
        freezeCount = 0
        dayStatuses.removeAll()
        isGoalCompleted = false
        // Optionally reset the selected date/week to today
        moveToCurrentWeek()
    }
    
    func resetSameGoal() {
        // Reset progress but keep current topic and goalDays
        learnedStreak = 0
        freezeCount = 0
        dayStatuses.removeAll()
        isGoalCompleted = false
        moveToCurrentWeek()
    }
    
    // MARK: - Placeholders referenced by ActivityView
    // Add minimal implementations so ActivityView compiles. Adjust logic as needed.
    var selectedDayStatus: DayStatus {
        let key = Calendar.current.startOfDay(for: selectedDate)
        return dayStatuses[key] ?? .none
    }
    
    var mainCircleText: String {
        switch selectedDayStatus {
        case .learned: return "Learned"
        case .freezed: return "Freezed"
        case .none:    return "Log as Learned"
        }
    }
    //hello
    
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
    
    func toggleDayStatus(_ status: DayStatus) {
        let key = Calendar.current.startOfDay(for: selectedDate)
        let current = dayStatuses[key] ?? .none
        
        if current == status {
            // Tapping same status toggles back to none
            dayStatuses[key] = .none
            if status == .learned { learnedStreak = max(0, learnedStreak - 1) }
            if status == .freezed { freezeCount = max(0, freezeCount - 1) }
        } else {
            // Apply new status
            dayStatuses[key] = status
            switch status {
            case .learned:
                learnedStreak += 1
                // If previously frozen, decrement freezeCount
                if current == .freezed { freezeCount = max(0, freezeCount - 1) }
            case .freezed:
                // Respect max freezes if you want (simple cap here)
                if freezeCount < maxFreezes {
                    freezeCount += 1
                } else {
                    // If over limit, ignore or replace previous status
                    dayStatuses[key] = current // revert
                }
                if current == .learned { learnedStreak = max(0, learnedStreak - 1) }
            case .none:
                // Clearing handled above when toggling same status
                break
            }
        }
        
        // Simple example: mark goal completed when learnedStreak reaches goalDays
        if learnedStreak >= goalDays {
            isGoalCompleted = true
        } else {
            isGoalCompleted = false
        }
    }
}

