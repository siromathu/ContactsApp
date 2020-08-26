//
//  KeychainManager.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-26.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation
import KeychainSwift

struct KeychainManager {
    
    
    // MARK: - Types -
    
    enum KeychainItem {
        case realmKey
        
        var value: String {
            switch self {
            case .realmKey: return "realm_key"
            }
        }
    }
    
    
    // MARK: - Helper functions -
    
    static func saveKey(value: Data?, key: KeychainItem) {
        guard let data = value else { return }
        let keychain = KeychainSwift()
        keychain.set(data, forKey: key.value, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    static func getKey(key: KeychainItem) -> Data? {
        let keychain = KeychainSwift()
        return keychain.getData(key.value)
    }
}
