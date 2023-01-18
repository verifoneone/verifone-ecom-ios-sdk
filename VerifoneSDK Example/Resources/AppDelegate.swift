//
//  AppDelegate.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        config()
        return true
    }

    func config() {
        // set custom font
        UIFont.jbs_registerFont(
            withFilenameString: "NotoSans-Regular.ttf",
            bundle: .main)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let nc = NotificationCenter.default

        var param: [String: String] = [:]
        if let switchedApp = UserDefaults.standard.value(forKey: Keys.switchedApp) as? String {
            param = ["payment": switchedApp]
        }
        nc.post(name: Notification.Name("CallbackFromThirdPartyApp"), object: nil, userInfo: param)
        return true
    }
}
