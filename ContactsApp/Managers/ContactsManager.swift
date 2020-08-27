//
//  ContactsManager.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation
import Contacts

enum ContactsManager {
    
    
    // MARK: - Types -
    
    enum PermissionStatus {
        case denied
        case granted
        case notDetermined
    }
    
    
    // MARK: - Helper functions -
    
    static func checkPermission() -> PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .granted
        case .denied, .restricted: return .denied
        @unknown default: return .notDetermined
        }
    }
    
    static func getPermission(completion: @escaping ((Bool) -> Void)) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { isGranted, error in
            completion(isGranted)
        }
    }
    
    static func fetchAll(completion: @escaping (([ContactDetail]?) -> Void)) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { isGranted, error in
            if isGranted {
                let keys = [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactImageDataKey, CNContactThumbnailImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = .userDefault
                
                do {
                    var contacts = [ContactDetail]()
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        var newContact = ContactDetail()
                        newContact.id = contact.identifier
                        newContact.firstName = contact.givenName
                        newContact.lastName = contact.familyName
                        newContact.thumbnailImageData = contact.thumbnailImageData
                        newContact.profileImageData = contact.imageData
                        
                        newContact.numbers = contact.phoneNumbers.compactMap({ number -> ContactItem in
                            let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: number.label ?? "")
                            return ContactItem(label: localizedLabel, value: number.value.stringValue)
                        })
                        
                        newContact.emails = contact.emailAddresses.compactMap({ email -> ContactItem in
                            let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? "")
                            return ContactItem(label: localizedLabel, value: String(email.value))
                        })
                        
                        contacts.append(newContact)
                    })
                    
                    completion(contacts)
                    
                } catch let error {
                    debugPrint("Failed to enumerate contact", error)
                    completion(nil)
                }
                
            } else {
                debugPrint("Permission denied")
                completion(nil)
            }
        }
    }
    
    static func sort(contacts: [ContactDetail]) -> [ContactGroup] {
        // Separate contacts based on first character of first name
        let grouped = Dictionary(grouping: contacts, by: { $0.firstName!.first })
        var contactsGroups = [ContactGroup]()
        for item in grouped {
            var newGroup = ContactGroup()
            newGroup.title = item.key != nil ? String(item.key!) : "#"
            let sortedContacts = item.value.sorted(by: { $0.getFullName() < $1.getFullName() })
            newGroup.contacts = sortedContacts
            contactsGroups.append(newGroup)
        }
        
        contactsGroups.sort(by: { $0.title! < $1.title! })
        return contactsGroups
    }
}
