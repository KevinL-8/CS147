//
//  Exercise_tab2.swift
//  DIYICI
//
//  Created by 李笑丞 on 2024/3/12.
//
import SwiftUI
import OpenAI

struct CircularProgressBar: View {
    // Example progress value
    var progress: CGFloat = 0.3

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            // Foreground Circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0)) // Start from the top
                .animation(.linear, value: progress)
            
            // Progress Text (Optional)
            Text(String(format: "%.0f%%", progress * 100.0))
                .font(.largeTitle)
                .animation(.none)
        }
    }
}


    private var headerSection: some View {
        Text("Your Health Data")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.vertical)
    }

struct HealthDataView: View {
    // Actual progress values should be provided by your data model or state variables
    @EnvironmentObject var appState: AppState
    @State private var stepProgress: CGFloat = 0
    @State private var otherMetricProgress: CGFloat = 0
    @StateObject var viewModel = HealthKitViewModel()
    @State private var showingResponse = false
    @State private var responseText = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false


    
    let openAI = OpenAI(apiToken:"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")
    
    var body: some View {
        VStack {
            headerSection

            Text("Step Count: \(viewModel.stepCount)")
            Text("Dietary Energy: \(viewModel.dietaryEnergy)")
            Text("Total Sleep: \(viewModel.totalSleep / 3600)")
            Text("Total Fat: \(viewModel.totalFat)")
            Text("Total Calories Burned: \(viewModel.totalCaloriesBurned)")
            Text("Total Distance: \(viewModel.totalDistance)")
            Text("Number of Awakenings: \(viewModel.numberOfAwakenings)")
            Text("Target Step     Target Calories")
                .foregroundStyle(.blue)
            // Displaying the custom progress bars
            HStack(spacing: 20) {
                CircularProgressBar(progress: stepProgress)
                .frame(width: 100, height: 100)
                .onTapGesture {
                    resetProgress(type: "Step")
                }

            CircularProgressBar(progress: otherMetricProgress)
                .frame(width: 100, height: 100)
                .onTapGesture {
                    resetProgress(type: "Calorie")
                }
        }
        .padding(.vertical)
        .alert(isPresented: $showingAlert) {
        Alert(title: Text("Target Updated"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }

        
            Button("Get Recommendation from GPT") {
                getRecommendationFromGPT()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }
        .onAppear {
            stepProgress = CGFloat(viewModel.stepCount) / 10000 // Assuming 10,000 steps as a goal
            otherMetricProgress = CGFloat(viewModel.totalCaloriesBurned) / 2000 // Assuming 2,000 calories as a goal
        }
        .sheet(isPresented: $showingResponse) {
            // Pop-up window for showing the API response
            VStack {
                Text("GPT Response")
                    .font(.headline)
                    .padding()
                ScrollView {
                    Text(responseText)
                        .padding()
                }
                Button("Close") {
                    self.showingResponse = false
                }
                .padding()
            }
        }
        .onChange(of: viewModel.stepCount) { newStepCount in
            self.appState.currentUser?.totalCalories = viewModel.dietaryEnergy
            print("self.appState.currentUser?.totalCalories",self.appState.currentUser?.totalCalories ?? 0)
        }
        .onChange(of: viewModel.dietaryEnergy) { newDietaryEnergy in
            self.appState.currentUser?.totalCalories = newDietaryEnergy
        }
        .onChange(of: viewModel.totalSleep) { newTotalSleep in
            self.appState.currentUser?.totalSleep = newTotalSleep
        }
        .onChange(of: viewModel.totalFat) { newTotalFat in
            self.appState.currentUser?.totalFat = newTotalFat
        }
        .onChange(of: viewModel.totalCaloriesBurned) { newtotalCaloriesBurned in
            self.appState.currentUser?.totalCaloriesBurned = newtotalCaloriesBurned
        }
        .onChange(of: viewModel.totalDistance) { newtotalDistance in
            self.appState.currentUser?.totalDistance = newtotalDistance
        }
        .onChange(of: viewModel.numberOfAwakenings) { newnumberOfAwakenings in
            self.appState.currentUser?.awakeningsCount = newnumberOfAwakenings
        }
    }
    func getRecommendationFromGPT() {
        // Ensure this data is correctly fetched from your AppState and HealthKitViewModel
        guard let user = self.appState.currentUser else { return }

        let userName = user.userName ?? "User"
        let age = user.age ?? ""
        let race = user.race ?? ""
        let diseaseHistory = user.diseaseHistory ?? ""
        let motionFrequency = user.motionFrequency ?? ""
        let preferredSports = user.preferredSports ?? ""
        let dailyNumberMeals = user.dailyNumberMeals ?? ""
        let sleepOverallQuality = user.sleepOverallQuality ?? ""
        let averageLengthSleep = String(format: "%.1f", user.averageLengthSleep ?? 0)
        let height = user.height
        let weight = user.weight
        let totalSleepHours = String(format: "%.1f", viewModel.totalSleep / 3600)

        let content = """
        You are a professional health recommender. Utilize the following given information as input to generate detailed, actionable recommendations for users to help them lead a healthier lifestyle. Your output should strictly follow the given format and provide specific examples (e.g., name exact foods to eat, specific physical activities) instead of general recommendations (e.g., eat healthy food). Please note, if any of the data points are empty, 0, or don't align with usual patterns (for example, abnormal step count or sleep hours), those factors should be disregarded in generating these recommendations.

        Input:

        userName: \(userName)
        stepCount: \(viewModel.stepCount)
        dietaryEnergy: \(viewModel.dietaryEnergy) calories
        totalSleep: \(totalSleepHours) hours
        totalFat: \(viewModel.totalFat) grams
        totalCaloriesBurned: \(viewModel.totalCaloriesBurned) calories
        totalDistance: \(viewModel.totalDistance) kilometers
        numberOfAwakenings: \(viewModel.numberOfAwakenings)
        age: \(age)
        race: \(race)
        diseaseHistory: \(diseaseHistory)
        motionFrequency: \(motionFrequency)
        preferredSports: \(preferredSports)
        dailyNumberMeals: \(dailyNumberMeals)
        sleepOverallQuality: \(sleepOverallQuality)
        averageLengthSleep: \(averageLengthSleep) hours
        height: \(height ?? "0") cm
        weight: \(weight) kg

        Output (If no information or number 0 or abnormal information provided for the content of placeholders, you should not consider them into the final output):

        Hi, [userName]. Based on the information provided, here are my tailored, detailed health recommendations for you:

        Morning Routine:
        - Breakfast suggestion: [If dietaryEnergy and totalFat are specified, include specific breakfast recommendation, e.g., "A bowl of oatmeal with blueberries and almonds."]
        - Morning activity: [If stepCount, preferredSports, and motionFrequency are specified, include specific morning activity recommendation, e.g., "30 minutes of brisk walking or a yoga session tailored to your favorite sport."]

        Lunch Time:
        - Lunch suggestion: [If dietaryEnergy and dailyNumberMeals are specified, include specific lunch recommendation, e.g., "Grilled chicken salad with a variety of vegetables and a vinaigrette dressing."]
        - Midday activity: [If totalDistance and preferredSports are specified, include specific midday activity recommendation, e.g., "A 20-minute cycling session or playing tennis for 30 minutes."]

        Dinner Time:
        - Dinner suggestion: [If dietaryEnergy and dailyNumberMeals are specified, include specific dinner recommendation, e.g., "Baked salmon with quinoa and steamed broccoli."]
        - Evening activity: [If totalSleep and sleepOverallQuality are specified, include specific evening activity recommendation, e.g., "A relaxing walk after dinner or stretching exercises to improve sleep quality."]

        Sleep Recommendations:
        - [If totalSleep, numberOfAwakenings, and sleepOverallQuality are specified, include specific sleep improvement tips, e.g., "Establish a consistent sleep schedule and create a relaxing bedtime routine, such as reading or meditation."]

        General Health Tips:
        - [If totalCaloriesBurned, age, and weight are specified, include a general health recommendation with specific examples, e.g., "Incorporate strength training exercises twice a week to boost metabolism."]
        - [If diseaseHistory is specified, include specific health precaution or advice with details, e.g., "Considering your history of hypertension, monitor sodium intake by choosing fresh, unprocessed foods."]

        Please note that these recommendations are designed to guide you towards a healthier lifestyle. Regularly updating your health and activity data can provide more accurate and personalized advice over time.
        """

        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: content)])

        Task {
            do {
                let result = try await openAI.chats(query: query)
                DispatchQueue.main.async {
                    self.responseText = result.choices.first?.message.content ?? "No response"
                    self.showingResponse = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.responseText = "Error: \(error.localizedDescription)"
                    self.showingResponse = true
                }
            }
        }
    }


    private func resetProgress(type: String) {
            switch type {
            case "Step":
                stepProgress = 0.0 // Resetting progress
                alertMessage = "New step target created."
            case "Calorie":
                otherMetricProgress = 0.0 // Resetting progress
                alertMessage = "New calorie target created."
            default:
                break
            }
            showingAlert = true
        }
    
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataView()
    }
}
