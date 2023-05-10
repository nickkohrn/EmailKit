import Foundation

public struct EmailClient {
    public var openEmail: @MainActor @Sendable (EmailConfiguration) async -> Void
}
