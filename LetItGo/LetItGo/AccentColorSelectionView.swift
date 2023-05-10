import ComposableArchitecture
import SwiftUI

struct AccentColorSelectionView: View {
    let store: StoreOf<AccentColorSelectionFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        ForEach(viewStore.colors) { color in
                            Button {
                                viewStore.send(.selectedAccentColor(color))
                            } label: {
                                HStack {
                                    Label {
                                        Text(color.color.description.localizedCapitalized)
                                            .foregroundColor(.primary)
                                    } icon: {
                                        Image(systemName: "square.fill")
                                            .imageScale(.large)
                                            .foregroundColor(color.color)
                                    }
                                    Spacer()
                                    if viewStore.selectedAccentColor == color {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(viewStore.selectedAccentColor.color)
                                    }
                                }
                            }
                            .tag(color)
                        }
                    }
                }
                .navigationTitle("Accent Color")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { viewStore.send(.onAppear) }
            }
            .accentColor(viewStore.selectedAccentColor.color)
        }
    }
}

struct AccentColorSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AccentColorSelectionView(store: .init(
            initialState: .init(),
            reducer: AccentColorSelectionFeature()
        ))
    }
}
