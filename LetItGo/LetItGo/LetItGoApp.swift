import ComposableArchitecture
import SwiftUI

@main
struct LetItGoApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(store: .init(
                initialState: .init(),
                reducer: MainFeature()
            ))
        }
    }
}
