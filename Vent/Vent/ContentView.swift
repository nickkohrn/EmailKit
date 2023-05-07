import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<MessageFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                HStack {
                    TextField(
                        "Write something...",
                        text: viewStore.binding(\.$input),
                        prompt: Text("Write something..."),
                        axis: .vertical
                    )
                    Button {
                        viewStore.send(.sendInput)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                    }
                    .disabled(viewStore.isSendButtonDisabled)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(store: .init(
                initialState: .init(),
                reducer: MessageFeature()
            ))
            .previewDisplayName("Empty")
            
            ContentView(store: .init(
                initialState: .init(input: "This is a message."),
                reducer: MessageFeature()
            ))
            .previewDisplayName("Populated")
        }
    }
}
