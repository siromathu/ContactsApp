//
//  RealmManager.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-26.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager {
    
    
    // MARK: - Realm configuration -
    
    class func setConfiguration() {
        // Check if the user has the unencrypted Realm
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let unencryptedRealmPath = "\(documentDirectory)/default.realm"
        let encryptedPath = "\(documentDirectory)/default_encrypted.realm"
        let isUnencryptedRealmExsist = fileManager.fileExists(atPath: unencryptedRealmPath)
        let isEncryptedRealmExsist = fileManager.fileExists(atPath: encryptedPath)
        let schemaVersion: UInt64 = 1
        
        //
        if isUnencryptedRealmExsist && !isEncryptedRealmExsist {
            let unencryptedRealm = try! Realm(configuration: Realm.Configuration(schemaVersion: schemaVersion))
            // if the user has unencrypted Realm write a copy to new path
            try? unencryptedRealm.writeCopy(toFile: URL(fileURLWithPath: encryptedPath), encryptionKey: RealmManager.getKey())
        }

        // Create new configuration from new encrypted realm db path
        var config = Realm.Configuration.defaultConfiguration
        config.encryptionKey = RealmManager.getKey()
        config.fileURL = URL(fileURLWithPath: encryptedPath)
        config.schemaVersion = schemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < schemaVersion) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    class func getKey() -> Data {
        // Get realm encryption from keychain
        if let key = KeychainManager.getKey(key: .realmKey) {
            return key
        } else {
            // No pre-existing key from this application, so generate a new one
            let keyData = NSMutableData(length: 64)!
            let _ = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
            KeychainManager.saveKey(value: keyData as Data, key: .realmKey)
            return keyData as Data
        }
    }
}


// MARK: - Contact CRUD functions -

extension RealmManager {
    
    class func fetchAllContacts() -> [ContactDetail]? {
        do {
            let realm = try Realm()
            let results = realm.objects(ContactDetailEntity.self)
            let contacts = results.toArray().compactMap({ ContactDetail(entity: $0) })
            return contacts

        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    class func insert(contacts: [ContactDetail]) {
        do {
            let realm = try Realm()
            let entities = contacts.compactMap({ ContactDetailEntity(contact: $0) })
            try realm.write {
                for entity in entities {
                    realm.add(entity)
                }
            }

        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    class func insert(contact: ContactDetail) {
        do {
            let realm = try Realm()
            let entity = ContactDetailEntity(contact: contact)
            try realm.write {
                realm.add(entity)
            }

        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    class func updateContacts() {
        
    }
    
    class func deleteAllContacts() {
        do {
            let realm = try Realm()
            let contacts = realm.objects(ContactDetailEntity.self).toArray()
            try realm.write {
                for contact in contacts {
                    realm.delete(contact, cascading: true)
                }
            }
            
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
}



// MARK: - Helper functions -

extension Results {
    
    func toArray() -> [Element] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [Any] {
        return self.map{$0}
    }
}

// MARK: - Realm Helper functions

protocol CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

extension Realm: CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }
    
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }
    
    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0 ..< list._rlmArray.count {
                    if let realmObject = list._rlmArray.object(at: index) as? RLMObjectBase {
                        toBeDeleted.insert(realmObject)
                    }
                }
            }
        }
        delete(element)
    }
}
