
// set.swift (داخل مجلد View)

import SwiftUI

struct set: View { // ⬅️ تم تغيير اسم الواجهة ليتناسب مع set.swift
    @StateObject private var viewModel = setVM()
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss   // ⬅️ لإغلاق الشاشة والرجوع

    // تحويل DurationType إلى LearningPeriod لاستخدامه مع ActivityView
    private func learningPeriod(from duration: DurationType) -> LearningPeriod {
        switch duration {
        case .week:  return .week
        case .month: return .month
        case .year:  return .year
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 40) {
                
                // --- 1. جزء إدخال الهدف ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    
                    // حقل الإدخال
                    TextField("Type here...", text: $viewModel.goalText)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .padding(.vertical, 6)
                    
                    // الخط الفاصل
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
                
                // --- 2. جزء اختيار المدة ---
                VStack(alignment: .leading, spacing: 16) {
                    Text("I want to learn it in a")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    
                    HStack(spacing: 12) {
                        // يجب استخدام DurationType مباشرة (بدون setVM.) كما اتفقنا لحل الأخطاء
                        ForEach(DurationType.allCases, id: \.self) { duration in
                            Button {
                                viewModel.selectedDuration = duration
                            } label: {
                                Text(duration.rawValue)
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 22)
                                    .background(
                                        Capsule()
                                            // الخلفية: برتقالي للمختار، شفاف لغير المختار
                                            .fill(viewModel.selectedDuration == duration ? Color.orange : Color.clear)
                                    )
                                    .overlay(
                                        // الإطار الخارجي: خط برتقالي
                                        Capsule()
                                            .stroke(Color.orange, lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // ⬅️ اخفاء السهم الافتراضي (الأبيض)
            
            // --- 3. شريط الأدوات (Toolbar) ---
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // زر الرجوع (السهم) — يشتغل ويرجع لورا
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange) // يبقى برتقالي
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // زر الحفظ (العلامة)
                    Button { viewModel.saveGoal() } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.orange)
                    }
                    .disabled(viewModel.goalText.isEmpty)
                }
            }
            // --- 4. الخلفية السوداء ---
            .background(Color.black.ignoresSafeArea())
            
            // --- 5. التنبيه والتنقل (منطقية ViewModel) ---
            .alert("Update Learning goal", isPresented: $viewModel.showUpdateAlert) {
                Button("Dismiss", role: .cancel) { viewModel.showUpdateAlert = false }
                Button("Update", role: .destructive) { viewModel.confirmUpdate() }
            } message: {
                Text("If you update now, your streak will start over.")
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToActivity) {
                // ✅ مرّر المعاملات المطلوبة بشكل صريح لتقليل التعقيد على الـ type-checker
                ActivityView(
                    topic: viewModel.goalText.isEmpty ? "Learning" : viewModel.goalText,
                    period: learningPeriod(from: viewModel.selectedDuration)
                )
            }
        }
    }
}

#Preview("Learning Goal") {
    set()
        .preferredColorScheme(.dark)
}

