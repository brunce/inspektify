import UIKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Test")
//            UnityView()
        }
                .ignoresSafeArea(.keyboard) // Compose has own keyboard handler
    }
}
