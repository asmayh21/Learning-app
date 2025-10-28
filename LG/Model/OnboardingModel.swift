import Foundation

enum LearningPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var days: Int {
        switch self {
        case .week:
            return 7
        case .month:
            return 30
        case .year:
            return 365
        }
    }
}

struct LearningSession {
    var topic: String
    var period: LearningPeriod
}
