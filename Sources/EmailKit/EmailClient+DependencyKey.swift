import Dependencies
import Foundation
import MessageUI
import UIKit

extension EmailClient: DependencyKey {
    public static let liveValue: EmailClient = {
        return EmailClient(
            canSendMail: {
                MFMailComposeViewController.canSendMail()
            }
        )
    }()
}
