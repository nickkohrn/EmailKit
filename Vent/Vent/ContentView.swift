import ComposableArchitecture
import Pow
import SwiftUI

struct ContentView: View {
    let store: StoreOf<MessageFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        TextField(
                            "Write something...",
                            text: viewStore.binding(\.$input),
                            prompt: Text("Write something..."),
                            axis: .vertical
                        )
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.clear)
                        )
                        Button {
                            viewStore.send(.sendInput)
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom)
                        .disabled(viewStore.isSendButtonDisabled)
                    }
                }
                if viewStore.isAnimatingInput {
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            TextField(
                                "",
                                text: .constant(viewStore.inputToAnimate),
                                prompt: nil,
                                axis: .vertical
                            )
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor)
                            )
                            Button {

                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.semibold)
                            }
                            .disabled(true)
                            .opacity(0)
                            .padding(.bottom)
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .movingParts.move(edge: .top)
                        )
                    )
                }
            }
            .font(.title)
            .padding()
            .edgesIgnoringSafeArea(.top)
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
