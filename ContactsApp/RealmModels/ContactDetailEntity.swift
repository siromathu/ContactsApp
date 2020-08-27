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
    
    @objc dynamic var thumbnailImageData: Data?
    
    @objc dynamic var profileImageData: Data?
    
    @objc dynamic var firstName: String?
    
    @objc dynamic var lastName: String?
    
    var numbers = List<ContactItemEntity>()
    
    var emails = List<ContactItemEntity>()
    
    
    // MARK: - Helper functions -
    
    func getFullName() -> String {
        var fullName = ""
        if firstName != nil { fullName = fullName + firstName! }
        if lastName != nil {
            if !fullName.isEmpty { fullName = fullName + " " }
            fullName = fullName + lastName!
        }
        return fullName
    }
    
    func getInitials() -> String {
        var initials = ""
        if firstName != nil, !firstName!.isEmpty {
            initials = initials + String(firstName!.first!)
        }
        
        if lastName != nil, !lastName!.isEmpty {
            initials = initials + String(lastName!.first!)
        }
        
        return initials
    }
    
    func getNumbers() -> String {
        var numbers = ""
        numbers = self.numbers.compactMap({ $0.value }).joined(separator: ", ")
        return numbers
    }
    
}


class ContactItemEntity: Object {
    
    @objc dynamic var label: String?
    
    @objc dynamic var value: String?
}
