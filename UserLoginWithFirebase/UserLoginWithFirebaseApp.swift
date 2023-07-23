

import SwiftUI
import Firebase

@main
struct UserLoginWithFirebaseApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


