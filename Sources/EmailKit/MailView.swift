import SwiftUI
import MessageUI

public struct MailView: UIViewControllerRepresentable{
    public let configuration: EmailConfiguration

    public typealias UIViewControllerType = MFMailComposeViewController

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
