import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct UserDefaultsClient {
    public static let messageSendAnimationKey = "messageSendAnimationKey"

    public var arrayForKey: @Sendable (String) -> [Any]?
    public var boolForKey: @Sendable (String) -> Bool
    public var dataForKey: @Sendable (String) -> Data?
    public var doubleForKey: @Sendable (String) -> Double
    public var integerForKey: @Sendable (String) -> Int
    public var register: @Sendable ([String: Any]) async -> Void
    public var remove: @Sendable (String) async -> Void
    public var setBool: @Sendable (Bool, String) async -> Void
    public var setData: @Sendable (Data?, String) async -> Void
    public var setDouble: @Sendable (Double, String) async -> Void
    public var setInteger: @Sendable (Int, String) async -> Void
    public var setObject: @Sendable (Any, String) async -> Void
    public var setString: @Sendable (_ string: String, _ key: String) async -> Void
    public var stringForKey: @Sendable (String) -> String?

    public var messageSendAnimation: String {
        stringForKey(Self.messageSendAnimationKey) ?? ""
    }

    public func setMessageAnimation(_ string: String) async {
        await setString(string, Self.messageSendAnimationKey)
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: Self = {
        let defaults = { UserDefaults.standard }
        return Self(
            arrayForKey: { defaults().array(forKey: $0) },
            boolForKey: { defaults().bool(forKey: $0) },
            dataForKey: { defaults().data(forKey: $0) },
            doubleForKey: { defaults().double(forKey: $0) },
            integerForKey: { defaults().integer(forKey: $0) },
            register: { defaults().register(defaults: $0) },
            remove: { defaults().removeObject(forKey: $0) },
            setBool: { defaults().set($0, forKey: $1) },
            setData: { defaults().set($0, forKey: $1) },
            setDouble: { defaults().set($0, forKey: $1) },
            setInteger: { defaults().set($0, forKey: $1) },
            setObject: { defaults().set($0, forKey: $1) },
            setString: { defaults().set($0, forKey: $1) },
            stringForKey: { defaults().string(forKey: $0) }
        )
    }()

    public static let previewValue = Self(
        arrayForKey: { _ in [] },
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        integerForKey: { _ in 0 },
        register: { _ in },
        remove: { _ in },
        setBool: { _, _ in },
        setData: { _, _ in },
        setDouble: { _, _ in },
        setInteger: { _, _ in },
        setObject: { _, _ in },
        setString: { _, _ in },
        stringForKey: { _ in "" }
    )

    public static let testValue = Self(
        arrayForKey: unimplemented("\(Self.self).arrayForKey", placeholder: nil),
        boolForKey: unimplemented("\(Self.self).boolForKey", placeholder: false),
        dataForKey: unimplemented("\(Self.self).dataForKey", placeholder: nil),
        doubleForKey: unimplemented("\(Self.self).doubleForKey", placeholder: 0),
        integerForKey: unimplemented("\(Self.self).integerForKey", placeholder: 0),
        register: unimplemented("\(Self.self).register"),
        remove: unimplemented("\(Self.self).remove"),
        setBool: unimplemented("\(Self.self).setBool"),
        setData: unimplemented("\(Self.self).setData"),
        setDouble: unimplemented("\(Self.self).setDouble"),
        setInteger: unimplemented("\(Self.self).setInteger"),
        setObject: unimplemented("\(Self.self).setObject"),
        setString: unimplemented("\(Self.self).setString"),
        stringForKey: unimplemented("\(Self.self).stringForKey", placeholder: "")
    )
}

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
