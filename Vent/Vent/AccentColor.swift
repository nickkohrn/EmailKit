import Foundation
import SwiftUI

public enum AccentColorSelection: String, Equatable, Hashable, CaseIterable, Identifiable {
    case blue,
         brown,
         cyan,
         green,
         indigo,
         mint,
         orange,
         pink,
         purple,
         red,
         teal,
         yellow

    public var id: String { rawValue }

    public var color: Color {
        switch self {
        case .blue: return .blue
        case .brown: return .brown
        case .cyan: return .cyan
        case .green: return .green
        case .indigo: return .indigo
        case .mint: return .mint
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        case .yellow: return .yellow
        }
    }
}
