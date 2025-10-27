//
//  setVM.swift
//  LG
//
//  Created by Asma on 04/05/1447 AH.
//

import Foundation
import SwiftUI
import Combine

final class setVM: ObservableObject {
    @Published var goalText: String = ""
    @Published var selectedDuration: DurationType = .month
    @Published var showUpdateAlert = false
    @Published var isEditingExistingGoal = false
    @Published var shouldNavigateToActivity = false

    /// المتغيرات الجديدة لتمرير الهدف مباشرة إلى ActivityView
    @Published var activityTopic: String = ""
    @Published var activityPeriod: LearningPeriod = .week

    /// ✅ يظهر التنبيه كل مرة عند الضغط على ✅ سواء الهدف جديد أو تعديل
    func saveGoal() {
        showUpdateAlert = true
    }

    /// تأكيد التحديث بعد الضغط على "Update" في مربع التنبيه
    func confirmUpdate() {
        print("⚡️ Goal updated:", goalText, "for", selectedDuration.rawValue)
        resetActivityGoal()
        navigateToActivity()
    }

    /// 🔁 إعادة تعيين هدف النشاط (ActivityView)
    private func resetActivityGoal() {
        // 🕒 تحويل مدة التعلم إلى LearningPeriod
        switch selectedDuration {
        case .week:
            activityPeriod = .week
        case .month:
            activityPeriod = .month
        case .year:
            activityPeriod = .year
        }

        // 📝 حفظ الهدف الجديد
        activityTopic = goalText.isEmpty ? "Learning" : goalText

        // ⚡️ إعادة تعيين القيم داخل ActivityViewModel
        ActivityViewModel.shared.resetForNewGoal(topic: activityTopic, period: activityPeriod)
    }

    /// 🧭 الانتقال إلى ActivityView
    private func navigateToActivity() {
        shouldNavigateToActivity = true
    }
}
