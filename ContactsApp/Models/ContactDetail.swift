//
//  ContactDetail.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation

struct ContactDetail {
    
    var thumbnailImageData: Data?
    
    var profileImageData: Data?
    
    var firstName: String?
    
    var lastName: String?
    
    var numbers = [String]()
    
    
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
    
}
