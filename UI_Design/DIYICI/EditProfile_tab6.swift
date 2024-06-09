

import Foundation
import SwiftUI


//import SwiftUI

struct EditProfileView: View {
    @Binding var user: UserModel?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("User Name", text: binding(for: \.userName, default: ""))
//                    TextField("Password", text: binding(for: \.passWord, default: ""))
                    TextField("age", text: binding(for: \.age, default: ""))
                    TextField("race", text: binding(for: \.race, default: ""))
                    TextField("diseaseHistory", text: binding(for: \.diseaseHistory, default: ""))
                    TextField("motionFrequency", text: binding(for: \.motionFrequency, default: ""))
                    TextField("preferredSports", text: binding(for: \.preferredSports, default: ""))
                    TextField("dailyNumberMeals", text: binding(for: \.dailyNumberMeals, default: ""))
                    TextField("sleepOverallQuality", text: binding(for: \.sleepOverallQuality, default: ""))
                    TextField("averageLengthSleep", text: binding(for: \.averageLengthSleep, default: ""))
                    TextField("Height", text: binding(for: \.height, default: ""))
                    // Use `NumberFormatter` for non-String types
                    let weightBinding = Binding<Double>(
                        get: { self.user?.weight ?? 0.0 },
                        set: { self.user?.weight = $0 }
                    )

                    // Use weightBinding directly with the TextField
                    TextField("Weight", value: weightBinding, formatter: NumberFormatter())

                    // Continue with other fields
                }
                .navigationBarItems(trailing: Button("Save") {
                    // 在这里添加保存逻辑
                    // 假设保存逻辑已经在这里处理
                    if let updatedUser = user {
                                appState.updateUser(updatedUser)
                                print("User data has been saved: \(updatedUser)")
                            } else {
                                print("No user data to save.")
                            }
                    print("Saving changes for user: \(user?.preferredSports ?? "Unknown")")
                    // 关闭视图
                    self.presentationMode.wrappedValue.dismiss()
                })
                
                .navigationBarTitle("Edit Profile", displayMode: .inline)}
        }
    }

    private func binding<T>(for keyPath: ReferenceWritableKeyPath<UserModel, T?>, default defaultValue: T) -> Binding<T> where T: Equatable {
        Binding<T>(
            get: { self.user?[keyPath: keyPath] ?? defaultValue },
            set: { self.user?[keyPath: keyPath] = $0 }
        )
    }
}
