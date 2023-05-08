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
        var accentColor: AccentColorSelection = .blue
        var route: Route?
        var showRoute = false
        var blurMessageSendAnimation = false
        
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
    
    @Dependency(\.continuousClock) var clock
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
                    try await clock.sleep(for: .seconds(0.1))
                    await send(.endAnimation, animation: .default)
                }

            case .updateUserSettings:
                state.accentColor = userDefaults.selectedAccentColor
                state.blurMessageSendAnimation = userDefaults.blurMessageSendAnimation
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
