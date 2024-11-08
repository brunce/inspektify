import SwiftUI

struct UnityView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        #if !targetEnvironment(simulator)
        DispatchQueue.main.async {
            vc.view.addSubview(UnityEmbeddedSwift.getUnityView())
        }
        #endif
        return vc
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}
