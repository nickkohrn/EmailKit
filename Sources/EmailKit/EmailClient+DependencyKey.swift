import Dependencies
import Foundation
import MessageUI
import UIKit

extension EmailClient: DependencyKey {
    public static let liveValue: EmailClient = {
        return EmailClient(
            canSendMail: {
                MFMailComposeViewController.canSendMail()
            },
            openEmail: { configuration in
                let to = configuration.toAddress
                let subject = configuration.subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
                let body = configuration.body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
                let urlString = "mailto:\(to)?subject=\(subject)&body=\(body)"
                guard let url = URL(string: urlString) else { return }
                guard UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url)
            }
        )
    }()
}
