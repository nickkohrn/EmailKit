import ComposableArchitecture
import Foundation
import SwiftUI

struct AccentColorSelectionFeature: ReducerProtocol {
    struct State: Equatable {
        let colors = AccentColorSelection.allCases
        var selectedAccentColor = AccentColorSelection.blue
    }

    enum Action: Equatable {
        enum DelegateAction: Equatable {
            case selectedAccentColor
        }

        case delegate(DelegateAction)
        case onAppear
        case selectedAccentColor(AccentColorSelection)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {

            case .delegate:
                return .none

            case .onAppear:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                return .none

            case .selectedAccentColor(let color):
                state.selectedAccentColor = color
                return .run { send in
                    await userDefaults.setSelectedAccentColor(color)
                    await send(.delegate(.selectedAccentColor))
                }

            }
        }
    }
}
