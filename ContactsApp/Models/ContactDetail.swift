//
//  ContactDetail.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation

struct ContactDetail: Equatable {
    
    
    // MARK: - Properties -
    
    var id: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var numbers = [ContactItem]()
    
    var emails = [ContactItem]()
    
    var thumbnailImageData: Data?
    
    var profileImageData: Data?
    
    
    // MARK: - Initializers -
    
    init() { }
    
    init(id: String, firstName: String, lastName: String, numbers: [ContactItem]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.numbers = numbers
    }
    
    init(entity: ContactDetailEntity) {
        self.id = entity.id
        self.firstName = entity.firstName
        self.lastName = entity.lastName
        self.thumbnailImageData = entity.thumbnailImageData
        self.profileImageData = entity.profileImageData
        let numberItems = entity.numbers.compactMap({ ContactItem(entity: $0) })
        self.numbers.append(contentsOf: numberItems)
        let emailItems = entity.emails.compactMap({ ContactItem(entity: $0) })
        self.emails.append(contentsOf: emailItems)
    }
    
    
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


struct ContactItem: Equatable {
    
    var label: String?
    
    var value: String?
    
    init(label: String?, value: String?) {
        self.label = label
        self.value = value
    }
    
    init(entity: ContactItemEntity) {
        self.label = entity.label
        self.value = entity.value
    }
    
}
