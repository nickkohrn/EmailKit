import ComposableArchitecture
import Foundation
import SwiftUI

struct SettingsFeature: ReducerProtocol {
    struct State: Equatable {
        @BindingState var selectedColor: Color = .blue

        var colors: [Color] {
            [.blue,
             .brown,
             .cyan,
             .green,
             .indigo,
             .mint,
             .orange,
             .pink,
             .purple,
             .red,
             .teal,
             .yellow]
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .binding:
                return .none

            case .onAppear:
                return .none

            }
        }
    }
}
