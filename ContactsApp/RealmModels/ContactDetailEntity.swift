//
//  ContactDetailEntity.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-26.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation
import RealmSwift

class ContactDetailEntity: Object {
    
    
    // MARK: - Properties -
    
    @objc dynamic var id: String?
    
    @objc dynamic var firstName: String?
    
    @objc dynamic var lastName: String?
    
    @objc dynamic var thumbnailImageData: Data?
    
    @objc dynamic var profileImageData: Data?
    
    var numbers = List<ContactItemEntity>()
    
    var emails = List<ContactItemEntity>()
    
    
    // MARK: - Initializers -
    
    convenience init(contact: ContactDetail) {
        self.init()
        self.id = contact.id
        self.firstName = contact.firstName
        self.lastName = contact.lastName
        self.thumbnailImageData = contact.thumbnailImageData
        self.profileImageData = contact.profileImageData
        let numberItems = contact.numbers.compactMap({ ContactItemEntity(item: $0) })
        self.numbers.append(objectsIn: numberItems)
        let emailItems = contact.emails.compactMap({ ContactItemEntity(item: $0) })
        self.emails.append(objectsIn: emailItems)
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
