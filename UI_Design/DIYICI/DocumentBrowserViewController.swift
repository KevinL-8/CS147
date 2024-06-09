

import SwiftUI
import HealthKit
import WCDBSwift

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()


        delegate = self

        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white

        // Specify the allowed content types of your application via the Info.plist.

        // Do any additional setup after loading the view.
        let healthKitManager = HealthKitManager()
        healthKitManager.authorizeHealthKit { authorized, error in
                    if authorized {
                        print("HealthKit authorization granted.")

                    } else {
                        if let error = error {
                            print("HealthKit authorization failed with error: \(error.localizedDescription)")
                        } else {
                            print("HealthKit authorization was not granted.")
                        }
                    }
                }

        //以下皆为调试
        healthKitManager.readStepCount { stepCount, error in
            if let error = error {
                // 如果有错误，打印错误信息
                print("An error occurred: \(error.localizedDescription)")
            } else {
                // 没有错误，打印步数
                print("Total steps today: \(stepCount)")
            }
        }

        healthKitManager.readLatestBodyWeight { weight, error in
            if let weight = weight {
                print("Latest body weight: \(weight) kg")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.weight = weight
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.weight],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Error reading body weight: \(String(describing: error))")
            }
        }

        // 读取当天的饮食能量（卡路里消耗）
        healthKitManager.readDietaryEnergy { totalCalories, error in
            if let error = error {
                print("Error reading dietary energy: \(error.localizedDescription)")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.totalCalories = totalCalories
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.totalCalories],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Total dietary energy today: \(totalCalories) kcal")
            }
        }

        // 读取当天的睡眠分析（睡眠时长）
        healthKitManager.readSleepAnalysis { totalSleep, error in
            if let error = error {
                print("Error reading sleep analysis: \(error.localizedDescription)")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.totalSleep = totalSleep
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.totalCalories],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                let hours = totalSleep / 3600 // 将秒转换为小时
                print("Total sleep today: \(hours) hours")
            }
        }

        // 读取当天的总脂肪摄入
        healthKitManager.readTotalFat { totalFat, error in
            if let error = error {
                print("Error reading total fat: \(error.localizedDescription)")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.totalFat = totalFat
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.totalCalories],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Total fat intake today: \(totalFat) grams")
            }
        }

        // 读取当天的活动能量消耗
        healthKitManager.readActiveEnergyBurned { totalCaloriesBurned, error in
            if let error = error {
                print("Error reading active energy burned: \(error.localizedDescription)")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.totalCaloriesBurned = totalCaloriesBurned
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.totalCalories],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Total active energy burned today: \(totalCaloriesBurned) kcal")
            }
        }

        // 读取当天的步行与跑步距离
        healthKitManager.readWalkingRunningDistance { totalDistance, error in
            if let error = error {
                print("Error reading walking and running distance: \(error.localizedDescription)")

                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.totalDistance = totalDistance
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.totalCalories],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Total walking and running distance today: \(totalDistance) meters")
            }
        }

        // 假设你已经定义了吃饭的开始和结束时间
//        func readBloodGlucoseDuringMealTime(completion: @escaping (Double?, Error?) -> Void) {
//            guard let bloodGlucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
//                completion(nil, HealthKitError.dataTypeNotAvailable)
//                return
//            }
//
//            let (start, end) = startAndEndOfToday() // 获取今天的起始时间和结束时间
//            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
//
//            let query = HKSampleQuery(sampleType: bloodGlucoseType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
//                guard let samples = results as? [HKQuantitySample] else {
//                    completion(nil, error)
//                    return
//                }
//
//                // 计算血糖值的总和
//                let totalBloodGlucose = samples.reduce(0.0) { (result, sample) -> Double in
//                    return result + sample.quantity.doubleValue(for: HKUnit(from: "mg/dL"))
//                }
//
//                // 计算平均血糖值
//                let averageBloodGlucose = totalBloodGlucose / Double(samples.count)
//
//                completion(averageBloodGlucose, nil)
//            }
//
//            healthStore.execute(query)
//        }

        // 读取当天的睡眠期间起床次数
        healthKitManager.readTodayNumberOfAwakenings { awakeningsCount, error in
            if let error = error {
                print("Error reading number of awakenings during sleep: \(error.localizedDescription)")
                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
                    if success {
                        currentUserModel.awakeningsCount = awakeningsCount
                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                             on: [UserModel.Properties.awakeningsCount],
                                                             with: currentUserModel,
                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
                    } else {
                        // 未登录
                    }
                }
            } else {
                print("Number of awakenings during sleep today: \(awakeningsCount)")
            }
        }

        // 读取当天的睡眠期间心率数据
        healthKitManager.readTodayHeartRateDuringSleep { samples, error in
            if let error = error {
                print("Error reading heart rate during sleep: \(error.localizedDescription)")
//                UserManager.shared.judgeIsLogin { success, currentUserModel, error in
//                    if success {
//                        currentUserModel.samples = samples!
//                        try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
//                                                             on: [UserModel.Properties.samples],
//                                                             with: currentUserModel,
//                                                             where: UserModel.Properties.userName == currentUserModel.userName!)
//                    } else {
//                        // 未登录
//                    }
//                }
            } else if let samples = samples {
                for sample in samples {
                    let heartRateValue = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    print("Heart rate during sleep: \(heartRateValue) BPM")
                }
            }
        }


        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button1.center = CGPoint(x: view.center.x, y: view.center.y + 70 - 100)

        button1.center = view.center
        button1.setTitle("登录", for: .normal)
        button1.setTitleColor(.blue, for: .normal)
        button1.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(button1)

        let button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button2.center = CGPoint(x: view.center.x, y: view.center.y + 70)
        button2.setTitle("注册", for: .normal)
        button2.setTitleColor(.red, for: .normal)
        button2.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        view.addSubview(button2)

        let button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button3.center = CGPoint(x: view.center.x, y: view.center.y + 70 - 200)
        button3.setTitle("更新", for: .normal)
        button3.setTitleColor(.red, for: .normal)
        button3.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        view.addSubview(button3)

    }
    // 更新
    @objc func updateButtonTapped() {


        UserManager.shared.judgeIsLogin { success, currentUserModel, error in
            if success {
                var model = currentUserModel
                model.userName = "ooo"
                try? LocalDBHandler.shared.db.update(table: "\(UserModel.self)",
                                                     on: [UserModel.Properties.userName],
                                                     with: model,
                                                     where: UserModel.Properties.userName == currentUserModel.userName!)
            } else {
                // 未登录
            }
        }
    }

    @objc func loginButtonTapped() {
        // 登录按钮点击事件处理
        print("登录按钮被点击")
        UserManager.shared.loginTask(userName: "hhh", passWord: "999999999") { isSuccessful, userModel, error in
            print("打印当前登录用户的全部信息 \(userModel)")
            if isSuccessful {
                print("登录成功")
            } else {
                print("登录失败 \(String(describing: error))")
            }
        }
    }
    @objc func registerButtonTapped() {
        // 注册按钮点击事件处理
        print("注册按钮被点击")
        let userModel = UserModel()
        userModel.userName = ""
        userModel.passWord = ""
        userModel.height = ""
        userModel.weight = 0
        userModel.age = ""
        userModel.race = ""
        userModel.diseaseHistory = ""
        userModel.motionFrequency = ""
        userModel.preferredSports = ""
        userModel.dailyNumberMeals = ""
        userModel.sleepOverallQuality = ""
        userModel.averageLengthSleep = ""
        UserManager.shared.registerTask(inputUserModel: userModel) { isSuccessful, error in
            if isSuccessful {
//                print("注册成功")
            } else {
//                print("注册失败 \(String(describing: error))")
            }
        }
    }
    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil

        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
//        guard let sourceURL = documentURLs.first else { return }

        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
//        presentDocument(at: sourceURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
//        presentDocument(at: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }

    // MARK: Document Presentation

//    func presentDocument(at documentURL: URL) {
//
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "File") as! DocumentViewController
//        documentViewController.document = Document(fileURL: documentURL)
//        documentViewController.modalPresentationStyle = .fullScreen
//
//        present(documentViewController, animated: true, completion: nil)
//    }
}

