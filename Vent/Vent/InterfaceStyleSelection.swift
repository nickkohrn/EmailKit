import Foundation

public enum InterfaceStyleSelection: String, Equatable, Identifiable, CaseIterable {
    case message
    case poof
    case vanish

    public var id: String { rawValue }
    public var title: String { rawValue.localizedCapitalized }

    public var systemSymbolName: String {
        switch self {
        case .message: return "arrow.up.circle.fill"
        case .poof: return "trash.circle.fill"
        case .vanish: return "circle.dotted"
        }
    }

    public var explanation: String {
        switch self {
        case .message: return "The message interface style simulates a text message being sent."
        case .poof: return "The poof interface style simulates a message dissolving in a cartoonish cloud."
        case .vanish: return "The vanish interface style simulates a message vanishing without a trace."
        }
    }
}
