import Foundation

public struct EmailClient {
    public var canSendMail: @MainActor @Sendable () async -> Bool
    public var openEmail: @MainActor @Sendable (EmailConfiguration) async -> Void
}
