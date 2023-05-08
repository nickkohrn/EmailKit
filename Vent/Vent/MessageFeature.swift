import ComposableArchitecture
import Foundation
import SwiftUI

struct MessageFeature: ReducerProtocol {
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
                return .none
                
            case .endAnimation:
                state.isAnimatingInput = false
                return .none
                
            case .onAppear:
                state.accentColor = userDefaults.accentColor
                return .none

            case .route(.settings(.delegate(.dismiss))):
                return EffectTask(value: .dismissRoute)

            case .route(.settings(.delegate(.selectedAccentColor))):
                state.accentColor = userDefaults.accentColor
                return .none
                
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
