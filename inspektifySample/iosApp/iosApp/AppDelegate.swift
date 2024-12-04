//
//  AppDelegate.swift
//  iosApp
//
//  Created by Blaz Vantur on 12. 10. 24.
//  Copyright © 2024 orgName. All rights reserved.
//

import UIKit
//import ComposeApp

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var shared: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }
    
    var window: UIWindow?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.launchOptions = launchOptions
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
//        let configuration = InspektifyShortcutHandlerKt.getInspektifyUISceneConfiguration(configurationForConnectingSceneSession: connectingSceneSession)
        let configuration = UISceneConfiguration()
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}
