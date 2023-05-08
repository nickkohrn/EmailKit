import ComposableArchitecture
import SwiftUI

@main
struct VentApp: App {
    var body: some Scene {
        WindowGroup {
            MessageView(store: .init(
                initialState: .init(),
                reducer: MessageFeature()
            ))
        }
    }
}
