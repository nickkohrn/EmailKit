import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<MainFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MessagingView(store: store.scope(
                state: \.messagingFeatureState,
                action: MainFeature.Action.messagingFeature
            ))
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: .init(
            initialState: .init(),
            reducer: MainFeature()
        ))
    }
}
