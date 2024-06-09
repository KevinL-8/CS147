import Foundation
import Combine

class HealthKitViewModel: ObservableObject {
    let healthKitManager = HealthKitManager()
    
    @Published var stepCount: Double = 0
    @Published var dietaryEnergy: Double = 0
    @Published var totalSleep: Double = 0
    @Published var totalFat: Double = 0
    @Published var totalCaloriesBurned: Double = 0
    @Published var totalDistance: Double = 0
    @Published var bloodGlucoseSamples: Double = 0
    @Published var numberOfAwakenings: Int = 0
    
    @Published var authorizationStatus: Bool = false
    @Published var errorDescription: String = ""

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        authorizeHealthKit()
        startUpdatingStepCount()
    }
    
    func authorizeHealthKit() {
        healthKitManager.authorizeHealthKit { authorized, error in
            DispatchQueue.main.async {
                if authorized {
                    self.authorizationStatus = true
                    self.readStepCountData()
                    self.readDietaryEnergy()
                    self.readSleepAnalysis()
                    self.readTotalFat()
                    self.readActiveEnergyBurned()
                    self.readWalkingRunningDistance()
                    self.readBloodGlucoseDuringMealTime()
                    self.readTodayNumberOfAwakenings()
                    
                } else {
                    self.authorizationStatus = false
                    self.errorDescription = error?.localizedDescription ?? "HealthKit authorization was not granted."
                }
            }
        }
    }
    
    func readStepCountData() {
        healthKitManager.readStepCount { stepCount, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.stepCount = stepCount
                }
            }
        }
    }
    func readDietaryEnergy() {
        healthKitManager.readDietaryEnergy { dietaryEnergy, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.dietaryEnergy = dietaryEnergy
                }
            }
        }
    }
    func readSleepAnalysis() {
        healthKitManager.readSleepAnalysis { totalSleep, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.totalSleep = totalSleep
                }
            }
        }
    }
    func readTotalFat() {
        healthKitManager.readTotalFat { totalFat, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.totalFat = totalFat
                }
            }
        }
    }
    func readActiveEnergyBurned() {
        healthKitManager.readActiveEnergyBurned { totalCaloriesBurned, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.totalCaloriesBurned = totalCaloriesBurned
                }
            }
        }
    }
    
    func readWalkingRunningDistance() {
        healthKitManager.readWalkingRunningDistance { totalDistance, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.totalDistance = totalDistance
                }
            }
        }
    }
    func readBloodGlucoseDuringMealTime() {
        healthKitManager.readBloodGlucoseDuringMealTime() { samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.bloodGlucoseSamples = samples ?? 0
                }
            }
        }
    }
    func readTodayNumberOfAwakenings() {
        healthKitManager.readTodayNumberOfAwakenings { numberOfAwakenings, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorDescription = error.localizedDescription
                } else {
                    self.numberOfAwakenings = numberOfAwakenings
                }
            }
        }
    }
    
    
    
    
    func startUpdatingStepCount() {
        // Invalidate the timer if it's already running
        timer?.invalidate()
        
        // Set up the timer to update the step count every minute
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.readStepCountData()
            self?.readDietaryEnergy()
            self?.readSleepAnalysis()
            self?.readTotalFat()
            self?.readActiveEnergyBurned()
            self?.readWalkingRunningDistance()
            self?.readBloodGlucoseDuringMealTime()
            self?.readTodayNumberOfAwakenings()
        }
    }
    
    deinit {
        // Invalidate the timer when the view model is deinitialized
        timer?.invalidate()
    }
}
