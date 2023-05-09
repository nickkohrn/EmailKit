import Foundation
import SwiftUI

extension Color: RawRepresentable {

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else { return nil }
        do {
            guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else { return nil }
            self = Color(color)
        } catch {
            return nil
        }

    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }

    }

}
