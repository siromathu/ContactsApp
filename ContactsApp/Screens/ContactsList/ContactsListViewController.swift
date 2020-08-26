//
//  ContactsListViewController.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit

class ContactsListViewController: UIViewController {
    
    
    // MARK: - Properties -
    
    private var groups = [ContactGroup]()
    
    private var sortType = ContactSortType.firstNameAscending
    
    
    // MARK: - Controls -
    
    private var contentStack: UIStackView!
    
    private var searchBar: UISearchBar!
    
    private var tableView: UITableView!
    
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchContacts()
    }

}


// MARK: - UI setup functions -

extension ContactsListViewController {
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title label and tool bar
        // Search bar
        // Table
        // Ask permission button
        setupContentStack()
        setupTitleLabel()
        setupSearchBar()
        setupTableView()
    }
    
    private func setupContentStack() {
        contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.spacing = 10
        view.addSubview(contentStack)
        contentStack.edgesToSuperview(usingSafeArea: true)
    }
    
    private func setupTitleLabel() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label.text = "Contacts"
        label.textColor = UIColor.label
        label.textAlignment = .center
        contentStack.addArrangedSubview(label)
        label.height(40)
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        contentStack.addArrangedSubview(searchBar)
        searchBar.height(50)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
//        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(ContactListItemCell.self, forCellReuseIdentifier: ContactListItemCell.identifier)
        contentStack.addArrangedSubview(tableView)
    }
    
}


// MARK: - Helper functions -

extension ContactsListViewController {
    
    private func fetchContacts() {
        groups = ContactsManager.fetchAll()
        
//        switch sortType {
//        case .firstNameAscending:
//            groups.sort(by: { $0.title! < $1.title! })
//        case .firstNameDescending:
//            groups.sort(by: { $0.title! < $1.title! })
//        case .lastNameAscending:
//            groups.sort(by: { $0.title! < $1.title! })
//        case .lastNameDescending:
//            groups.sort(by: { $0.title! < $1.title! })
//        }
        
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}


// MARK: - Table view data source

extension ContactsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactListItemCell.identifier, for: indexPath) as! ContactListItemCell
        cell.selectionStyle = .none
        cell.configure(contact: groups[indexPath.section].contacts[indexPath.row])
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let titles = groups.compactMap({ $0.title })
        if let titleIndex = titles.firstIndex(of: title) {
            return titleIndex
        }
        
        return 0
    }
}


// MARK: - Table view delegate

extension ContactsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].title
    }
    
}
