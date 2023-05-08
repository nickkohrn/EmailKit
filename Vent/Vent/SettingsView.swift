import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        ForEach(viewStore.colors, id: \.self) { color in
                            Label {
                                Text(color.description.localizedCapitalized)
                            } icon: {
                                Image(systemName: "square.fill")
                                    .imageScale(.large)
                                    .foregroundColor(color)
                            }
                            .tag(color)
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(
            initialState: .init(),
            reducer: SettingsFeature()
        ))
    }
}
