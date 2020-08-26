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
    
    static func fetchAll() -> [ContactGroup] {
        var contacts = [ContactDetail]()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { isGranted, error in
            if isGranted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactThumbnailImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = .userDefault
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        var newContact = ContactDetail()
                        newContact.firstName = contact.givenName
                        newContact.lastName = contact.familyName
                        newContact.thumbnailImageData = contact.thumbnailImageData
                        newContact.profileImageData = contact.imageData
                        newContact.numbers = contact.phoneNumbers.compactMap({ $0.value.stringValue })
                        contacts.append(newContact)
                    })
                    
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            }
        }
        
        // Separate contacts based on first character of first name
        let grouped = Dictionary(grouping: contacts, by: { $0.firstName!.first })
        var contactsGroups = [ContactGroup]()
        for item in grouped {
            var newGroup = ContactGroup()
            newGroup.title = item.key != nil ? String(item.key!) : "#"
            newGroup.contacts = item.value
            contactsGroups.append(newGroup)
        }
        
        contactsGroups.sort(by: { $0.title! < $1.title! })
        
        return contactsGroups
    }
    
    static func sort(contacts: [ContactDetail], by type: ContactSortType) -> [ContactGroup] {
        // Separate contacts based on first character of first name
        let grouped = Dictionary(grouping: contacts, by: { $0.firstName!.first })
        var contactsGroups = [ContactGroup]()
        for item in grouped {
            var newGroup = ContactGroup()
            newGroup.title = item.key != nil ? String(item.key!) : "#"
            newGroup.contacts = item.value
            contactsGroups.append(newGroup)
        }
        
        return contactsGroups
    }
}
