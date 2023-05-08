import ComposableArchitecture
import SwiftUI

@main
struct VentApp: App {
    var body: some Scene {
        WindowGroup {
            MessagingView(store: .init(
                initialState: .init(),
                reducer: MessagingFeature()
            ))
        }
    }
}
