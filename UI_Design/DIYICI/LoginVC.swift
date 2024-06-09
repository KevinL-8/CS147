import SwiftUI



class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?
    func updateUser(_ newUser: UserModel?) {
        // 这里可以添加逻辑来验证用户信息的有效性或进行其他必要的处理
        currentUser = newUser
        //更新本地数据库
        UserManager.shared.updateAllData(user: newUser!) { isSuccess, error in
            if isSuccess {
                // 成功
            } else {
                // 失败
            }
        }
    }
}


struct ContentView: View {
    @StateObject var appState = AppState()
    var body: some View {
        if !appState.isAuthenticated {
            NavigationView {
                VStack {
                    Image("health") // Assuming you have an image named "health" in your asset catalog
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.top, 50)
                    
                    Text("WellnessWise")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginView(appState: appState)) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                    
                    // Changed the Sign Up button to a text link
                    NavigationLink(destination: SignUpView(appState: appState)) {
                        Text("Not have an account? Tap here to sign up")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                }
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarHidden(true)
            }
        } else {
            MainTabView().environmentObject(appState)
        }
    }
}


struct LoginView: View {
    @ObservedObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
//    @State private var isAuthenticated = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    var body: some View {
        NavigationView {
            VStack {
                Image("health") // Assuming you have an image named "health" in your asset catalog
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
//                NavigationLink(destination: MainTabView(), isActive: $isAuthenticated) { EmptyView() }
                
                Button(action: {
                                    loginUser()
                                }) {
                                    Text("Login")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 200, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                                .alert(isPresented: $showingAlert) {
                                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }
                            }
//                            .padding().navigationBarBackButtonHidden(true)
                        }.padding()//.navigationBarBackButtonHidden(true)
                        
                    }
                    
                    func loginUser() {
                        UserManager.shared.loginTask(userName: email, passWord: password) { success, userModel, error in
                            DispatchQueue.main.async {
//                                print(email)
//                                print(pass)

                                if success {
                                    self.appState.isAuthenticated = true
                                    self.appState.currentUser = userModel
                                    print("fdskjfdasjkjlhasdfkjhlsdfkljhsfakjlhafsdjkfsajklhjkhfsdajkhafsd",userModel.userName)
//                                    self.isAuthenticated = true
                                } else {
                                    self.alertMessage = error?.localizedDescription ?? "Login failed. Please check your credentials and try again."
                                    self.showingAlert = true
                                    self.appState.isAuthenticated = false
                                }
                            }
                        }
                    }
                }

struct SignUpView: View {
    @ObservedObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
//    @State private var isAuthenticated = false
    @State private var showingAlert = false
    @State private var alertMessage = "Something went wrong. Please try again."

    var body: some View {
        NavigationView {
            VStack {
                Image("health")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                Button(action: {
                                    registerUser()
                                }) {
                                    Text("Sign Up")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 200, height: 50)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                                .alert(isPresented: $showingAlert) {
                                    Alert(title: Text("Registration Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }
                            }
                            .padding()
                        }
                       // .navigationBarBackButtonHidden(true)
                    }
                    
                    func registerUser() {
                        @StateObject var viewModel = HealthKitViewModel()
                        let newUser = UserModel()
                        newUser.userName = email
                        newUser.passWord = password
                        newUser.height = ""
                        newUser.weight = 0
                        newUser.age = ""
                        newUser.race = ""
                        newUser.diseaseHistory = ""
                        newUser.motionFrequency = ""
                        newUser.preferredSports = ""
                        newUser.dailyNumberMeals = ""
                        newUser.sleepOverallQuality = ""
                        newUser.averageLengthSleep = ""
                        UserManager.shared.registerTask(inputUserModel: newUser) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    self.appState.isAuthenticated = true
                                    self.appState.currentUser = newUser
//                                    self.isAuthenticated = true
                                } else {
                                    self.alertMessage = error?.localizedDescription ?? "An unknown error occurred."
                                    self.showingAlert = true
                                    self.appState.isAuthenticated = false
                                }
                            }
                        }
                    }
                }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
