
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
                
               
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Type here...", text: $viewModel.goalText)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .padding(.vertical, 6)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("I want to learn it in a")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    
                    HStack(spacing: 12) {
                    
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
                                            .fill(viewModel.selectedDuration == duration ? Color.color1 : Color.clear)
                                    )
                                    .overlay(
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
            .navigationBarBackButtonHidden(true)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
            .background(Color.black.ignoresSafeArea())
            
            .alert("Update Learning goal", isPresented: $viewModel.showUpdateAlert) {
                Button("Dismiss", role: .cancel) {
                    viewModel.showUpdateAlert = false
                }
                Button("Update", role: .destructive) {
                    viewModel.confirmUpdate()
                    
                }
                .tint(.orange)
            } message: {
                Text("If you update now, your streak will start over.")
            }
           
            }
        }
    }


#Preview("Learning Goal") {
    set()
        .preferredColorScheme(.dark)
}

