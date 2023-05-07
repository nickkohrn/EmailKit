import ComposableArchitecture
import Foundation

struct MessageFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var input = ""
        var inputToAnimate = ""
        var isAnimatingInput = false
        
        var isSendButtonDisabled: Bool {
            input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case endAnimation
        case sendInput
        case startAnimation
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .binding:
                return .none

            case .endAnimation:
                state.isAnimatingInput = false
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
                    await send(.endAnimation, animation: .default)
                }

            }
        }
    }
}
