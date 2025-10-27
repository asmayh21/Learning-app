import SwiftUI
import UIKit

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    // ✅ تهيئة صحيحة لـ @StateObject
    init(startDate: Date, endDate: Date) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(startDate: startDate, endDate: endDate))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // ✅ ScrollView مع ForEach آمن باستخدام indices لتفادي مشاكل الـ ID مع Date
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(viewModel.months.indices, id: \.self) { index in
                        let month = viewModel.months[index]
                        MonthView(viewModel: viewModel, month: month)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 100)
                .padding(.bottom, 20)
            }
            
            // ✅ الهيدر
            VStack {
                HStack {
                    // زر الرجوع
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                    }
                    
                    Spacer()
                    
                    // العنوان
                    Text("All Activities")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // placeholder شفاف لموازنة التصميم
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.clear)
                        .padding(10)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
            }
            .frame(height: 100)
            .background(
                Color.black.opacity(0.85)
                    .ignoresSafeArea(edges: .top)
            )
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationBarHidden(true)
    }
}

// ✅ MonthView المعدّل
struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let month: Date
    private let calendar = Calendar.current
    
    private var today: Date { calendar.startOfDay(for: Date()) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // اسم الشهر والسنة
            Text(month, format: .dateTime.month(.wide).year())
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(.leading, 5)
            
            // شبكة الأيام
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                
                // أيام الأسبوع
                ForEach(viewModel.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday.uppercased())
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                // فراغات البداية
                ForEach(0..<viewModel.leadingSpaces(for: month), id: \.self) { _ in
                    Text("")
                }
                
                // الأيام الفعلية
                ForEach(viewModel.daysInMonth(for: month), id: \.self) { day in
                    let isToday = calendar.isDate(calendar.startOfDay(for: day), inSameDayAs: today)
                    
                    Text("\(calendar.component(.day, from: day))")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(isToday ? Color("rreg") : Color.gray.opacity(0.15))
                        )
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// ✅ Preview جاهز للتجربة
#Preview {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())
    let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
    let endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
    
    CalendarView(startDate: startDate, endDate: endDate)
        .preferredColorScheme(.dark)
}

