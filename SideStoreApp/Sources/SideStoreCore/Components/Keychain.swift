//
//  Keychain.swift
//  AltStore
//
//  Created by Riley Testut on 6/4/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import Foundation
import KeychainAccess

//import AltSign

@propertyWrapper
public struct KeychainItem<Value> {
    public let key: String

    public var wrappedValue: Value? {
        get {
            switch Value.self {
            case is Data.Type: return try? Keychain.shared.keychain.getData(key) as? Value
            case is String.Type: return try? Keychain.shared.keychain.getString(key) as? Value
            default: return nil
            }
        }
        set {
            switch Value.self {
            case is Data.Type: Keychain.shared.keychain[data: key] = newValue as? Data
            case is String.Type: Keychain.shared.keychain[key] = newValue as? String
            default: break
            }
        }
    }

    public init(key: String) {
        self.key = key
    }
}

public class Keychain {
    public static let shared = Keychain()

    fileprivate let keychain = KeychainAccess.Keychain(service: Bundle.Info.appbundleIdentifier).accessibility(.afterFirstUnlock).synchronizable(true)

    @KeychainItem(key: "appleIDEmailAddress")
    public var appleIDEmailAddress: String?

    @KeychainItem(key: "appleIDPassword")
    public var appleIDPassword: String?

    @KeychainItem(key: "signingCertificatePrivateKey")
    public var signingCertificatePrivateKey: Data?

    @KeychainItem(key: "signingCertificateSerialNumber")
    public var signingCertificateSerialNumber: String?

    @KeychainItem(key: "signingCertificate")
    public var signingCertificate: Data?

    @KeychainItem(key: "signingCertificatePassword")
    public var signingCertificatePassword: String?

    @KeychainItem(key: "patreonAccessToken")
    public var patreonAccessToken: String?

    @KeychainItem(key: "patreonRefreshToken")
    public var patreonRefreshToken: String?

    @KeychainItem(key: "patreonCreatorAccessToken")
    public var patreonCreatorAccessToken: String?

    @KeychainItem(key: "patreonAccountID")
    public var patreonAccountID: String?

    private init() {}

    public func reset() {
        appleIDEmailAddress = nil
        appleIDPassword = nil
        signingCertificatePrivateKey = nil
        signingCertificateSerialNumber = nil
    }
}
