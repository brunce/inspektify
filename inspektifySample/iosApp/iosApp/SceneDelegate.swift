import UIKit
import SwiftUI

class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = windowScene.keyWindow
        
        UnityEmbeddedSwift.setHostMainWindow(window)
        UnityEmbeddedSwift.setLaunchinOptions(AppDelegate.shared?.launchOptions)
        UnityEmbeddedSwift.showUnity()
    }
}
