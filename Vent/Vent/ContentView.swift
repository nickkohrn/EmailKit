import SwiftUI

struct ContentView: View {
    @State private var text = ""
    private var isSendButtonDisabled: Bool { text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField(
                    "Write something...",
                    text: $text,
                    prompt: Text("Write something..."),
                    axis: .vertical
                )
                Button {
                    
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .imageScale(.large)
                        .fontWeight(.semibold)
                }
                .disabled(isSendButtonDisabled)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
