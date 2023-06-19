import Foundation

public struct EmailConfiguration {
    public let toAddress: String
    public let subject: String
    public let body: String
    public var attachments: [Data]

    public init(
        toAddress: String,
        subject: String,
        body: String,
        attachments: [Data] = []
    ) {
        self.toAddress = toAddress
        self.subject = subject
        self.body = body
        self.attachments = attachments
    }
}