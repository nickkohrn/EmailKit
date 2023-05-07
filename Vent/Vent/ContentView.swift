import ComposableArchitecture
import Pow
import SwiftUI

struct ContentView: View {
    let store: StoreOf<MessageFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                layout(viewStore: viewStore)
                    .font(.title)
                    .padding()
                    .edgesIgnoringSafeArea(.top)
                    .navigationTitle("Let It Go")
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Menu {
                                Picker(selection: viewStore.binding(\.$transition), content: {
                                    ForEach(MessageFeature.Transition.allCases) { transition in
                                        Label(transition.title, systemImage: transition.systemSymbolName)
                                            .tag(transition)
                                    }
                                }, label: {
                                    Label("Message Animation", systemImage: "wand.and.stars")
                                })
                                .pickerStyle(.menu)
                            } label: {
                                Label("Options", systemImage: "ellipsis.circle")
                            }
                        }
                    }
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

    @ViewBuilder
    private func moveLayout(
        viewStore: ViewStoreOf<MessageFeature>
    ) -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    TextField(
                        "Write something...",
                        text: viewStore.binding(\.$input),
                        prompt: Text("Write something...")
                            .font(.title),
                        axis: .vertical
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    Button {
                        viewStore.send(.sendInput)
                    } label: {
                        sendButtonImage()
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.bottom)
                    .disabled(viewStore.isSendButtonDisabled)
                    .buttonStyle(PushDownButtonStyle())
                    .foregroundColor(.accentColor)
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
                        removal: .movingParts.move(edge: .top)
                    )
                )
                .zIndex(1)
            }
        }
    }

    @ViewBuilder
    private func vanishLayout(
        viewStore: ViewStoreOf<MessageFeature>
    ) -> some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom) {
                    TextField(
                        "Write something...",
                        text: viewStore.binding(\.$input),
                        prompt: Text("Write something...")
                            .font(.title),
                        axis: .vertical
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    Button {
                        viewStore.send(.sendInput)
                    } label: {
                        sendButtonImage()
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.bottom)
                    .disabled(viewStore.isSendButtonDisabled)
                    .buttonStyle(PushDownButtonStyle())
                    .foregroundColor(.accentColor)
                }
                if viewStore.isAnimatingInput {
                    HStack(alignment: .bottom) {
                        TextField(
                            "Write something...",
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
                            sendButtonImage()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(true)
                        .opacity(0)
                        .padding(.bottom)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .movingParts.vanish(Color.accentColor)
                        )
                    )
                    .zIndex(1)
                }
            }
        }
    }

    @ViewBuilder
    private func layout(
        viewStore: ViewStoreOf<MessageFeature>
    ) -> some View {
        switch viewStore.transition {
        case .move: moveLayout(viewStore: viewStore)
        case .vanish: vanishLayout(viewStore: viewStore)
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
