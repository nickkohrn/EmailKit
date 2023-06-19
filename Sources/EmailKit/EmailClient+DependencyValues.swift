import Dependencies

extension DependencyValues {
    public var emailClient: EmailClient {
        get { self[EmailClient.self] }
        set { self[EmailClient.self] = newValue }
    }
}
