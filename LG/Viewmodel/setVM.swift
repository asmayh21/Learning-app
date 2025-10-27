//
//  setVM.swift
//  LG
//
//  Created by asma  on 04/05/1447 AH.
//

// LearningGoalViewModel.swift (يُوضع داخل مجلد ViewModel)

import Foundation
import SwiftUI // نحتاج هذا للاستخدام @Published4
import Combine

// ملاحظة: تم حذف تعريف DurationType من هنا لأنه أصبح في ملف الـ Model

class setVM: ObservableObject {
    @Published var goalText: String = ""
    // DurationType تم استخدامه من ملف الـ Model مباشرة
    @Published var selectedDuration: DurationType = .month
    @Published var showUpdateAlert = false
    @Published var isEditingExistingGoal = false
    @Published var shouldNavigateToActivity = false

    func saveGoal() {
        if isEditingExistingGoal {
            showUpdateAlert = true
        } else {
            print("✅ Goal saved:", goalText, "for duration:", selectedDuration.rawValue)
            shouldNavigateToActivity = true
        }
    }

    func confirmUpdate() {
        print("⚡️ Updated:", goalText, "for", selectedDuration.rawValue)
        shouldNavigateToActivity = true
    }
}
