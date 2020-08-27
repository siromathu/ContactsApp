//
//  ContactItemEntity.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-27.
//  Copyright © 2020 Siroson. All rights reserved.
//

import Foundation
import RealmSwift

class ContactItemEntity: Object {
    
    @objc dynamic var label: String?
    
    @objc dynamic var value: String?
    
    convenience init(item: ContactItem) {
        self.init()
        self.label = item.label
        self.value = item.value
    }
}
