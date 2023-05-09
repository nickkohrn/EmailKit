import ComposableArchitecture
import Foundation
import SwiftUI

struct MessagingFeature: ReducerProtocol {
    struct State: Equatable {
        enum Route: Equatable {
            case settings(SettingsFeature.State)
        }
        
        @BindingState var input = ""
        var inputToAnimate = ""
        var isAnimatingInput = false
        var selectedAccentColor: AccentColorSelection = .blue
        var route: Route?
        var showRoute = false
        var blurMessageSendAnimation = false
        var enableHapticFeedback = false
        
        var isSendButtonDisabled: Bool {
            input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: Equatable, BindableAction {
        enum Route: Equatable {
            case settings(SettingsFeature.Action)
        }
        
        case binding(BindingAction<State>)
        case dismissRoute
        case endAnimation
        case onAppear
        case route(Route)
        case sendInput
        case settingsButtonActivated
        case startAnimation
        case updateUserSettings
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .dismissRoute:
                state.showRoute = false
                return EffectTask(value: .updateUserSettings)
                
            case .endAnimation:
                state.isAnimatingInput = false
                return .none
                
            case .onAppear:
                return .run { send in
                    await userDefaults.registerInitialDefaults()
                    await send(.updateUserSettings)
                }

            case .route(.settings(.delegate(.dismiss))):
                return .concatenate(
                    EffectTask(value: .updateUserSettings),
                    EffectTask(value: .dismissRoute)
                )
                
            case .route:
                return .none
                
            case .sendInput:
                return .run { send in
                    await send(.startAnimation, animation: .default)
                }
                
            case .settingsButtonActivated:
                state.route = .settings(.init())
                state.showRoute = true
                return .none
                
            case .startAnimation:
                state.isAnimatingInput = true
                state.inputToAnimate = state.input
                state.input = ""
                return .run { send in
                    await send(.endAnimation, animation: .default)
                }

            case .updateUserSettings:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                state.blurMessageSendAnimation = userDefaults.blurMessageSendAnimation
                state.enableHapticFeedback = userDefaults.enableHapticFeedback
                return .none
                
            }
        }
        .ifLet(\.route, action: /Action.route) {
            EmptyReducer()
                .ifCaseLet(/State.Route.settings, action: /Action.Route.settings) {
                    SettingsFeature()
                }
        }
    }
}
