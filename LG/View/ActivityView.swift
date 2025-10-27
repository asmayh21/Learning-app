import SwiftUI

struct ActivityView: View {
    // --- 1. يستقبل البيانات من ContentView ---
    @StateObject private var viewModel: ActivityViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // عرض يدوي لصفحة "Well done"
    @State private var forceShowDone = false
    
    // ✅ حالة جديدة للضغط على زر الفريز
    @State private var isFreezePressed = false
    
    let startDate = Calendar.current.date(from: DateComponents(
        year: Calendar.current.component(.year, from: Date()),
        month: 1,
        day: 1
    ))!
    let endDate = Calendar.current.date(from: DateComponents(
        year: Calendar.current.component(.year, from: Date()),
        month: 12,
        day: 31
    ))!
    
    init(topic: String, period: LearningPeriod) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(topic: topic, period: period))
    }
    
    var body: some View {
        VStack {
            // MARK: - Header
            HStack {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Calendar
                NavigationLink {
                    CalendarView(startDate: startDate, endDate: endDate)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .glassEffect(.clear)
                        .clipShape(Circle())
                }
                
                // Edit
                NavigationLink {
                    set()
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                       
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .glassEffect(.clear)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // MARK: - Week Calendar
            VStack(spacing: 24) {
                HStack {
                    Text(viewModel.currentWeekStart, format: .dateTime.month(.wide).year())
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Button { viewModel.showSheet.toggle() } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.orange)
                            .glassEffect(.clear)
                            .padding(.leading, 4)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button { viewModel.moveWeek(by: -1) } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                        Button { viewModel.moveWeek(by: 1) } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                // Days Row
                HStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { offset in
                        let day = Calendar.current.date(byAdding: .day, value: offset, to: viewModel.currentWeekStart)!
                        let dayKey = Calendar.current.startOfDay(for: day)
                        let status = viewModel.dayStatuses[dayKey] ?? .none
                        let isSelected = Calendar.current.isDate(day, equalTo: viewModel.selectedDate, toGranularity: .day)
                        
                        let circleFillColor: Color = {
                            if status == .learned { return viewModel.learnedCalendarColor }
                            else if status == .freezed { return viewModel.freezedCalendarColor }
                            else if isSelected { return viewModel.defaultCalendarColor }
                            else { return Color(.secondarySystemBackground).opacity(0.3) }
                        }()
                        
                        VStack(spacing: 6) {
                            Text(day, format: .dateTime.weekday(.narrow))
                                .font(.caption2)
                                .foregroundStyle(.gray)
                            
                            Text(day, format: .dateTime.day())
                                .font(.headline.weight(.semibold))
                                .frame(width: 44, height: 44)
                                
                                .background(
                                    Circle()
                                        .fill(circleFillColor)
                                        .overlay(
                                            status == .freezed ?
                                                Circle().stroke(viewModel.freezedCalendarColor, lineWidth: 2) :
                                            status == .learned ?
                                                Circle().stroke(viewModel.learnedCalendarColor, lineWidth: 2) :
                                            nil
                                        )
                                )
                                .foregroundStyle(.white)
                                .onTapGesture { viewModel.selectedDate = day }
                        }
                    }
                }
                
                Divider().background(Color.white.opacity(0.2)).padding(.top, 8)
                
                Text(viewModel.learningTopic)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    .foregroundColor(.white)
                
                // MARK: - Stats
                HStack(spacing: 15) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill").foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.learnedStreak)").font(.headline.bold())
                            Text(viewModel.learnedStreak == 1 ? "Day Learned" : "Days Learned").font(.caption)
                        }.foregroundColor(.white)
                    }
                    .frame(width: 160, height: 69)
                    
                    .background(viewModel.learnedColor.opacity(0.5))
                    
                    .clipShape(Capsule())
                    .glassEffect(.clear)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "cube.fill").foregroundColor(.cyan)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.freezeCount)").font(.headline.bold())
                            Text(viewModel.freezeCount == 1 ? "Day Freezed" : "Days Freezed").font(.caption)
                        }.foregroundColor(.white)
                    }
                    
                    .frame(width: 160, height: 69)
                    .glassEffect(.clear)
                    .background(viewModel.freezedColor.opacity(0.5))
                    .clipShape(Capsule())
                }
            }
            .padding()
            .glassEffect(in: .rect(cornerRadius: 16.0))
            
            Spacer().frame(height: 20)
            
            // MARK: - Main Circle + Buttons
            Group {
                if forceShowDone || viewModel.isGoalCompleted {
                    VStack(spacing: 20) {
                        Image(systemName: "hands.and.sparkles.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Will done!")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Goal completed! start learning again or\nset new learning goal")
                            .font(.subheadline)
                            .foregroundStyle(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button(action: { viewModel.setNewGoal() }) {
                            Text("Set new learning goal")
                                .font(.headline)
                                .frame(width: 274, height: 48)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(colors: [Color.orange, Color("rreg")],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                                       
                                )
                        }
                        
                        Button(action: { viewModel.resetSameGoal() }) {
                            Text("Set same learning goal and duration")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                    }
                    .transition(.opacity)
                } else {
                    VStack(spacing: 20) {
                        Button(action: { viewModel.toggleDayStatus(.learned) }) {
                            Text(viewModel.mainCircleText)
                                .font(.system(size: 36, weight: .bold))
                                .frame(width: 274, height: 274)
                                .background(
                                    Circle()
                                        .fill(viewModel.mainCircleColor)
                                        .overlay(
                                            viewModel.selectedDayStatus == .freezed ?
                                                Circle().stroke(viewModel.freezedColor, lineWidth: 8) :
                                            viewModel.selectedDayStatus == .learned ?
                                                Circle().stroke(viewModel.learnedColor, lineWidth: 8) :
                                            nil
                                        )
                                        .shadow(color: viewModel.mainCircleColor.opacity(0.7),
                                                radius: 10, x: 0, y: 5)
                                        
                                )
                                .foregroundColor(.white)
                                .glassEffect(.clear)
                        }
                        
                        Button {
                            isFreezePressed.toggle()
                            viewModel.toggleDayStatus(.freezed)
                        } label: {
                            Text("Freeze Current day")
                                .frame(width: 274, height: 48)
                                .glassEffect(.clear)
                                .background(
                                    isFreezePressed ?
                                    Color("FreezePressed") : // 👈 من الـ Assets
                                    (viewModel.selectedDayStatus == .freezed ?
                                     viewModel.freezedColor :
                                     Color("gg"))
                                )
                                .font(.headline.bold())
                                .cornerRadius(28)
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.freezeCountText)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: forceShowDone || viewModel.isGoalCompleted)
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.showSheet) {
            VStack(spacing: 20) {
                Capsule().fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                Text("Select Date")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                HStack(spacing: 0) {
                    Picker("Month", selection: $viewModel.selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(viewModel.months[month - 1]).tag(month)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(Array(viewModel.years), id: \.self) { year in
                            Text(String(year)).tag(year)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .colorScheme(.dark)
                Spacer()
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(20)
            .background(.ultraThinMaterial)
            .onAppear { viewModel.prepareSheetPickers() }
        }
    }
}

#Preview {
    ActivityView(topic: "Swift", period: .week)
        .preferredColorScheme(.dark)
}
