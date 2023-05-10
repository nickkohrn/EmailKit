import Foundation

public struct EmailConfiguration {
    public let toAddress: String
    public let subject: String
    public let body: String

    public init(
        toAddress: String,
        subject: String,
        body: String
    ) {
        self.toAddress = toAddress
        self.subject = subject
        self.body = body
    }
}