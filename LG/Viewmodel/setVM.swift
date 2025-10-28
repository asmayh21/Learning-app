

import Foundation
import SwiftUI
import Combine

final class setVM: ObservableObject {
    @Published var goalText: String = ""
    @Published var selectedDuration: DurationType = .month
    @Published var showUpdateAlert = false
    @Published var isEditingExistingGoal = false
    @Published var shouldNavigateToActivity = false

    @Published var activityTopic: String = ""
    @Published var activityPeriod: LearningPeriod = .week

    func saveGoal() {
        showUpdateAlert = true
    }

    func confirmUpdate() {
        print("⚡️ Goal updated:", goalText, "for", selectedDuration.rawValue)
        resetActivityGoal()
        navigateToActivity()
    }

    private func resetActivityGoal() {
        switch selectedDuration {
        case .week:
            activityPeriod = .week
        case .month:
            activityPeriod = .month
        case .year:
            activityPeriod = .year
        }

        activityTopic = goalText.isEmpty ? "Learning" : goalText

        ActivityViewModel.shared.resetForNewGoal(topic: activityTopic, period: activityPeriod)
    }

    private func navigateToActivity() {
        shouldNavigateToActivity = true
    }
}
