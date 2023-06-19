import ComposableArchitecture
import SwiftUI
import MessageUI

public struct MailFeature: ReducerProtocol {
    public struct State: Equatable {
        public let configuration: EmailConfiguration

        public init(configuration: EmailConfiguration) {
            self.configuration = configuration
        }
    }

    public enum Action: Equatable {
        case onAppear
    }

    public init() { }

    public var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {

            case .onAppear:
                return .none

            }
        }
    }
}

public struct MailComposeView: UIViewControllerRepresentable {
    public let configuration: EmailConfiguration

    public typealias UIViewControllerType = MFMailComposeViewController

    public init(configuration: EmailConfiguration) {
        self.configuration = configuration
    }

    public func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) { }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        if MFMailComposeViewController.canSendMail() {
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = context.coordinator
            view.setToRecipients([configuration.toAddress])
            view.setSubject(configuration.subject)
            view.setMessageBody(
                configuration.body,
                isHTML: false
            )
            for attachment in configuration.attachments {
                view.addAttachmentData(
                    attachment.data,
                    mimeType: "text/plain",
                    fileName: attachment.filename
                )
            }
            return view
        } else {
            return MFMailComposeViewController()
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }


    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate{
        public override init() {
            super.init()
        }

        public func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
        }
    }
}

public struct MailView: View {
    public let store: StoreOf<MailFeature>

    public init(store: StoreOf<MailFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MailComposeView(configuration: viewStore.configuration)
        }
    }
}
