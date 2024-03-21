//
//  File.swift
//  
//
//  Created by Simao Coutinho on 21/03/2024.
//

import Foundation
import Security

struct SecureData {
    // Store data securely in Keychain
    func saveToKeychain(data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            // Handle error
            return
        }
    }

    // Retrieve data from Keychain
    func loadFromKeychain(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            // Handle error
            return nil
        }

        return result as? Data
    }
}
