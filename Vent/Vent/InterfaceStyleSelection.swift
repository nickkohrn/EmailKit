import Foundation

public enum InterfaceStyleSelection: String, Equatable, Identifiable, CaseIterable {
    case message
    case vanish

    public var id: String { rawValue }
    public var title: String { rawValue.localizedCapitalized }

    public var systemSymbolName: String {
        switch self {
        case .message: return "arrow.up.circle.fill"
        case .vanish: return "circle.dotted"
        }
    }

    public var explanation: String {
        switch self {
        case .message: return "The message interface style simulates a text message being sent."
        case .vanish: return "The vanish interface style simulates a message vanishing without a trace."
        }
    }
}
