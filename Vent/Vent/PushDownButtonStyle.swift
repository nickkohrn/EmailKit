import Pow
import SwiftUI

struct PushDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .conditionalEffect(
                .pushDown,
                condition: configuration.isPressed
            )
    }
}
