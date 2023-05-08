import ComposableArchitecture
import Foundation

struct SettingsFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var enableHapticFeedback = false
        @BindingState var enableMessageSendBlur = false
        @BindingState var selectedInterfaceStyle = InterfaceStyleSelection.message
        var accentColorSelection: AccentColorSelectionFeature.State?
        var isAccentColorSelectionActive = false
        var selectedAccentColor: AccentColorSelection = .blue
        let supportedInterfaceStyles = InterfaceStyleSelection.allCases
    }

    enum Action: Equatable, BindableAction {
        enum DelegateAction: Equatable {
            case selectedInterfaceStyle
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

            case .binding(\.$enableMessageSendBlur):
                return .fireAndForget { [enabled = state.enableMessageSendBlur] in
                    await userDefaults.setBlurMessageSendAnimation(enabled)
                }

            case .binding(\.$enableHapticFeedback):
                return .fireAndForget { [enabled = state.enableHapticFeedback] in
                    await userDefaults.setEnableHapticFeedback(enabled)
                }

            case .binding(\.$selectedInterfaceStyle):
                return .concatenate(
                    .fireAndForget { [style = state.selectedInterfaceStyle] in
                        await userDefaults.setSelectedInterfaceStyle(style)
                    },
                    EffectTask(value: .delegate(.selectedInterfaceStyle))
                )

            case .binding:
                return .none

            case .delegate:
                return .none

            case .dismissButtonActivated:
                return EffectTask(value: .delegate(.dismiss))

            case .onAppear:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                state.enableMessageSendBlur = userDefaults.blurMessageSendAnimation
                state.selectedInterfaceStyle = userDefaults.selectedInterfaceStyle
                state.enableHapticFeedback = userDefaults.enableHapticFeedback
                return .none

            }
        }
        .ifLet(\.accentColorSelection, action: /Action.accentColorSelection) {
            AccentColorSelectionFeature()
        }
    }
}
