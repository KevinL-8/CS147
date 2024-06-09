import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = HealthKitViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                if let user = appState.currentUser {
                    welcomeUserSection(userName: user.userName)
                    
                    stepCountSection(stepCount: Int(viewModel.stepCount))
                    
                    calorieCountSection(calories: Int(viewModel.totalCaloriesBurned))
                    
                    sleepSection(sleepHours: String(viewModel.totalSleep / 3600))// Assuming `sleepOverallQuality` is a String representing sleep hours
                    
                    dietSection(dailyMeals: String(viewModel.totalFat))
                    
                    exerciseSection(exerciseContent: String(viewModel.totalDistance))
                } else {
                    Text("No user logged in.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .onChange(of: viewModel.stepCount) { newStepCount in
            self.appState.currentUser?.totalCalories = newStepCount // Update total calories dynamically
        }
    }

    // MARK: - UI Components

    var headerSection: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
            .padding(.top, 20)
    }

    func welcomeUserSection(userName: String?) -> some View {
        Text("Welcome, \(userName ?? "User")")
            .font(.headline)
            .padding(.vertical)
    }

    func stepCountSection(stepCount: Int) -> some View {
        InfoPanel(title: "Steps", value: "\(stepCount)", icon: "figure.walk")
    }

    func calorieCountSection(calories: Int) -> some View {
        InfoPanel(title: "Calories Burned", value: "\(calories)", icon: "flame.fill")
    }

    func sleepSection(sleepHours: String?) -> some View {
        InfoPanel(title: "Sleep Hours", value: sleepHours ?? "N/A", icon: "bed.double.fill")
    }

    func dietSection(dailyMeals: String?) -> some View {
        InfoPanel(title: "Daily Meals", value: dailyMeals ?? "N/A", icon: "leaf.fill")
    }

    func exerciseSection(exerciseContent: String?) -> some View {
        InfoPanel(title: "Exercise", value: exerciseContent ?? "N/A", icon: "figure.walk.circle.fill")
    }
}

struct InfoPanel: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primary)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState())
    }
}

