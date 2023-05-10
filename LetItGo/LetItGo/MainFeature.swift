import ComposableArchitecture
import Foundation
import PurchasesKit

struct MainFeature: ReducerProtocol {
    struct State: Equatable {
        var messagingFeatureState = MessagingFeature.State()
    }

    enum Action: Equatable {
        case messagingFeature(MessagingFeature.Action)
        case onAppear
    }

    @Dependency(\.purchasesClient) var purchasesClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.messagingFeatureState, action: /Action.messagingFeature) {
            MessagingFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {

            case .messagingFeature:
                return .none

            case .onAppear:
                return .fireAndForget {
                    await purchasesClient.configure("appl_xruXOmtyowhaCVzmzQJncuCuVdh")
                }

            }
        }
    }
}
