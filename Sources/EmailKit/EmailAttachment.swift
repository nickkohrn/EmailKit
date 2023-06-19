import Foundation

public struct EmailAttachment: Equatable {
    public let data: Data
    public let filename: String

    public init(
        data: Data,
        filename: String
    ) {
        self.data = data
        self.filename = filename
    }
}
