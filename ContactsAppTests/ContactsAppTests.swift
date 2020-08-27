//
//  ContactsAppTests.swift
//  ContactsAppTests
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import XCTest
@testable import ContactsApp

class ContactsAppTests: XCTestCase {
    
    var contactsListController: ContactsListViewController!
    
    var contactDetailController: ContactDetailViewController!
    
    let contactOne = ContactDetail(id: UUID().uuidString, firstName: "Matt", lastName: "Damon", numbers: [ContactItem(label: "mobile", value: "1111111111")])
    let contactTwo = ContactDetail(id: UUID().uuidString, firstName: "Mark", lastName: "Zuckerberg", numbers: [ContactItem(label: "mobile", value: "2222222222")])
    let contactThree = ContactDetail(id: UUID().uuidString, firstName: "Jeff", lastName: "Bezos", numbers: [ContactItem(label: "mobile", value: "3333333333")])

    override func setUpWithError() throws {
        contactsListController = ContactsListViewController()
        contactsListController.allContacts.append(contentsOf: [contactOne, contactTwo, contactThree])
        
        contactDetailController = ContactDetailViewController()
    }

    override func tearDownWithError() throws {
        contactsListController.allContacts.removeAll()
    }
    
    
    // Sample test contacts grouping test cases
    
    func testContactsGroupingFails() {
        let expectedGroups = [ContactGroup(title: "J", contacts: [contactThree])]
        let actualGroups = ContactsManager.sort(contacts: contactsListController.allContacts)
        XCTAssertNotEqual(actualGroups, expectedGroups, "Grouping failed as expected")
    }
    
    func testContactsGroupingPasses() {
        let groupOne = ContactGroup(title: "J", contacts: [contactThree])
        let groupTwo = ContactGroup(title: "M", contacts: [contactTwo, contactOne])
        let expectedGroups = [groupOne, groupTwo]
        let actualGroups = ContactsManager.sort(contacts: contactsListController.allContacts)
        XCTAssertEqual(actualGroups, expectedGroups, "Grouping failed")
    }
}
