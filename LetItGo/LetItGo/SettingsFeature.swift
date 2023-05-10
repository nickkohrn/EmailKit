import ComposableArchitecture
import Foundation

struct SettingsFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var enableHapticFeedback = false
        var accentColorSelection: AccentColorSelectionFeature.State?
        var isAccentColorSelectionActive = false
        var selectedAccentColor: AccentColorSelection = .blue
    }

    enum Action: Equatable, BindableAction {
        enum DelegateAction: Equatable {
            case dismiss
        }

        case accentColorSelection(AccentColorSelectionFeature.Action)
        case accentColorSelectionDismissed
        case accentColorSelectionTapped
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case dismissButtonActivated
        case onAppear
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .accentColorSelectionDismissed:
                state.accentColorSelection = nil
                return .none

            case .accentColorSelectionTapped:
                state.accentColorSelection = .init()
                return .none

            case .accentColorSelection(.delegate(.selectedAccentColor)):
                state.selectedAccentColor = userDefaults.selectedAccentColor
                return .none

            case .accentColorSelection:
                return .none

            case .binding(\.$enableHapticFeedback):
                return .fireAndForget { [enabled = state.enableHapticFeedback] in
                    await userDefaults.setEnableHapticFeedback(enabled)
                }

            case .binding:
                return .none

            case .delegate:
                return .none

            case .dismissButtonActivated:
                return EffectTask(value: .delegate(.dismiss))

            case .onAppear:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                state.enableHapticFeedback = userDefaults.enableHapticFeedback
                return .none

            }
        }
        .ifLet(\.accentColorSelection, action: /Action.accentColorSelection) {
            AccentColorSelectionFeature()
        }
    }
}
