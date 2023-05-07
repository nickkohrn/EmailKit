import ComposableArchitecture
import Pow
import SwiftUI

struct ContentView: View {
    let store: StoreOf<MessageFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 0.5)
                            )
                            Button {
                                viewStore.send(.sendInput)
                            } label: {
                                sendButtonImage()
                            }
                            .frame(minWidth: 44, minHeight: 44)
                            .disabled(viewStore.isSendButtonDisabled)
                            .buttonStyle(PushDownButtonStyle())
                            .symbolRenderingMode(.multicolor)
                        }
                    }
                    if viewStore.isAnimatingInput {
                        VStack {
                            Spacer()
                            HStack(alignment: .bottom) {
                                TextField(
                                    "Write something...",
                                    text: .constant(viewStore.inputToAnimate),
                                    prompt: nil,
                                    axis: .vertical
                                )
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor)
                                )
                                Button {

                                } label: {
                                    sendButtonImage()
                                }
                                .frame(minWidth: 44, minHeight: 44)
                                .disabled(true)
                                .opacity(0)
                                .padding(.bottom)
                            }
                        }
                        .transition(
                            .asymmetric(
                                insertion: .identity,
                                removal: .movingParts.move(edge: .top).combined(with: .movingParts.blur)
                            )
                        )
                        .zIndex(1)
                    }
                }
                .padding()
                .edgesIgnoringSafeArea(.top)
                .navigationTitle("Let It Go")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }

    @ViewBuilder
    private func sendButtonImage() -> some View {
        Image(systemName: "paperplane.circle.fill")
            .imageScale(.large)
            .fontWeight(.semibold)
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
