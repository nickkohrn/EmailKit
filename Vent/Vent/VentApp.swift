import ComposableArchitecture
import SwiftUI

@main
struct VentApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(
                initialState: .init(),
                reducer: MessageFeature()
            ))
        }
    }
}
