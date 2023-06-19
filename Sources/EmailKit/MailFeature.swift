import ComposableArchitecture
import SwiftUI
import MessageUI

extension MFMailComposeError {
    static let unknown = MFMailComposeError(_nsError: NSError(domain: "MFMailComposeErrorDomain", code: 100, userInfo: nil))
}

public struct MailFeature: ReducerProtocol {
    public struct State: Equatable {
        public let configuration: EmailConfiguration

        public init(configuration: EmailConfiguration) {
            self.configuration = configuration
        }
    }

    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case didFinish(MFMailComposeError?)
            case onAppear
        }

        case delegateAction(DelegateAction)
        case didFinish(MFMailComposeError?)
        case onAppear
    }

    public init() { }

    public var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {

            case .delegateAction:
                return .none

            case let .didFinish(error):
                return .send(.delegateAction(.didFinish(error)))

            case .onAppear:
                return .send(.delegateAction(.onAppear))

            }
        }
    }
}

public struct MailComposeView: UIViewControllerRepresentable {
    public let configuration: EmailConfiguration
    public let onAppear: (() -> Void)?
    public let onFinish: ((MFMailComposeError?) -> Void)?

    public typealias UIViewControllerType = MFMailComposeViewController

    public init(
        configuration: EmailConfiguration,
        onAppear: (() -> Void)? = nil,
        onFinish: ((MFMailComposeError?) -> Void)? = nil
    ) {
        self.configuration = configuration
        self.onAppear = onAppear
        self.onFinish = onFinish
    }

    public func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) { }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
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
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(
            onAppear: onAppear,
            onFinish: onFinish
        )
    }


    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        public let onAppear: (() -> Void)?
        public let onFinish: ((MFMailComposeError?) -> Void)?

        public init(
            onAppear: (() -> Void)?,
            onFinish: ((MFMailComposeError?) -> Void)?
        ) {
            self.onAppear = onAppear
            self.onFinish = onFinish
        }

        public func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if let error {
                if let composeError = error as? MFMailComposeError {
                    onFinish?(composeError)
                } else {
                    onFinish?(.unknown)
                }
            }
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
            MailComposeView(
                configuration: viewStore.configuration,
                onAppear: { viewStore.send(.onAppear) },
                onFinish: { error in viewStore.send(.didFinish(error)) }
            )
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}
