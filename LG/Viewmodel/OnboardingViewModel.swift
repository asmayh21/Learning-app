import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var topic: String = "Swift"
    @Published var selectedPeriod: LearningPeriod = .week
    @Published var currentSession: LearningSession? = nil
    
   
    
    func startLearning() {
        // let session = LearningSession(topic: topic, period: selectedPeriod)
        print("User wants to learn \(topic) in \(selectedPeriod.rawValue)")
    }
}


