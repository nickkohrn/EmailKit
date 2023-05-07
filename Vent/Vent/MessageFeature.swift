import ComposableArchitecture
import Foundation

struct MessageFeature: ReducerProtocol {
    enum Transition: Int, Equatable, CaseIterable, Identifiable {
        case move
        case vanish

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .move: return "move"
            case .vanish: return "vanish"
            }
        }

        var systemSymbolName: String {
            switch self {
            case .move: return "arrow.up.circle.fill"
            case .vanish: return "circle.dotted"
            }
        }
    }
    
    struct State: Equatable {
        @BindingState var input = ""
        @BindingState var transition: Transition = .move
        var inputToAnimate = ""
        var isAnimatingInput = false
        
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

            case .binding(\.$transition):
                return .fireAndForget { [transition = state.transition] in
                    await userDefaults.setMessageAnimation(transition.id)
                }

            case .binding:
                return .none

            case .endAnimation:
                state.isAnimatingInput = false
                return .none

            case .onAppear:
                let transitionID = userDefaults.messageSendAnimation
                guard let transition = Transition(rawValue: transitionID) else {
                    assertionFailure("Expected \(Transition.self)")
                    return .none
                }
                state.transition = transition
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
