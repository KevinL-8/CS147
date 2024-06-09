import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSheet = false
    @State private var showingHealthAppAlert = false // State for alert control

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                greetingSection

                Divider().padding(.vertical)

                settingsSection
                
                Spacer()
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarItems(trailing: EditButton())
        .sheet(isPresented: $showingSheet) {
            if let user = appState.currentUser {
                EditProfileView(user: .constant(user))
            }
        }
        .alert(isPresented: $showingHealthAppAlert) { // Alert configuration
            Alert(
                title: Text("Open Health App"),
                message: Text("To view or change your health data, please open the Apple Health app directly from your home screen."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var greetingSection: some View {
        HStack {
            Text(greetingText)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .font(.title2)
                .bold()

            Button("Open Apple Health") { // When this button is tapped, show alert
                showingHealthAppAlert = true
            }
            .buttonStyle(ProfileButtonStyle(backgroundColor: .blue))

            Button("Edit Profile") {
                showingSheet = true
            }
            .buttonStyle(ProfileButtonStyle(backgroundColor: .green))
        }
    }

    private var greetingText: String {
        if let userName = appState.currentUser?.userName {
            return "Hi \(userName)"
        } else {
            return "Hi User"
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct ProfileButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
