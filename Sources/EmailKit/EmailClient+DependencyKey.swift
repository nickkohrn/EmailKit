import ComposableArchitecture
import Foundation
import UIKit

extension EmailClient: DependencyKey {
    public static let liveValue: EmailClient = {
        return EmailClient(
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
