import Foundation

public struct EmailClient {
    public var canSendMail: @MainActor @Sendable () async -> Bool
}
