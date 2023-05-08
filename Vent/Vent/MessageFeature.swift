import ComposableArchitecture
import Foundation
import SwiftUI

struct MessageFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var input = ""
        var inputToAnimate = ""
        var isAnimatingInput = false
        var accentColor: Color = .blue
        
        var isSendButtonDisabled: Bool {
            input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case endAnimation
        case onAppear
        case sendInput
        case startAnimation
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .binding:
                return .none

            case .endAnimation:
                state.isAnimatingInput = false
                return .none

            case .onAppear:
                state.accentColor = userDefaults.accentColor ?? .blue
                return .none

            case .sendInput:
                return .run { send in
                    await send(.startAnimation, animation: .default)
                }

            case .startAnimation:
                state.isAnimatingInput = true
                state.inputToAnimate = state.input
                state.input = ""
                return .run { send in
                    try await clock.sleep(for: .seconds(0.1))
                    await send(.endAnimation, animation: .default)
                }

            }
        }
    }
}
