import ComposableArchitecture
import Foundation

struct SettingsFeature: ReducerProtocol {
    struct State: Equatable {
        var accentColorSelection: AccentColorSelectionFeature.State?
        var isAccentColorSelectionActive = false
        var selectedAccentColor: AccentColorSelection?
    }

    enum Action: Equatable {
        enum DelegateAction: Equatable {
            case dismiss
            case selectedAccentColor
        }

        case accentColorSelection(AccentColorSelectionFeature.Action)
        case accentColorSelectionDismissed
        case accentColorSelectionTapped
        case delegate(DelegateAction)
        case dismissButtonActivated
        case onAppear
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
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
                return EffectTask(value: .delegate(.selectedAccentColor))

            case .accentColorSelection:
                return .none

            case .delegate:
                return .none

            case .dismissButtonActivated:
                return EffectTask(value: .delegate(.dismiss))

            case .onAppear:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                return .none

            }
        }
        .ifLet(\.accentColorSelection, action: /Action.accentColorSelection) {
            AccentColorSelectionFeature()
        }
    }
}
