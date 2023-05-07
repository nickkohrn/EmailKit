import ComposableArchitecture
import Foundation

struct MessageFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var input = ""
        var isSendingInput = false
        
        var isSendButtonDisabled: Bool {
            input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case sendInput
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            
        case .binding:
            return .none
            
        case .sendInput:
            state.isSendingInput = true
            return .none
            
        }
    }
}
