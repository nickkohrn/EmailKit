import ComposableArchitecture
import SwiftUI

@main
struct LetItGoApp: App {
    var body: some Scene {
        WindowGroup {
            MessagingView(store: .init(
                initialState: .init(),
                reducer: MessagingFeature()
            ))
        }
    }
}
