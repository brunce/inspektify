import SwiftUI

struct UnityView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            vc.view.addSubview(UnityEmbeddedSwift.getUnityView())
        }
        return vc
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}
