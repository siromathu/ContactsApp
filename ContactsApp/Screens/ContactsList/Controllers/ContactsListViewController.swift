//
//  ContactsListViewController.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit
import Contacts

class ContactsListViewController: UIViewController {
    
    
    // MARK: - Properties -
    
    /// Replacement value type objects instead of directly using Realm reference type objects to avoid threading issues
    var allContacts = [ContactDetail]() {
        didSet {
            if self.footerLabel != nil {
                self.footerLabel.text = "\(self.allContacts.count) contacts"
            }
        }
    }
    
    private var allGroups = [ContactGroup]()
    
    private var filteredGroups = [ContactGroup]()
    
    private var isContactsUpdated = false
    
    
    // MARK: - Controls -
    
    private var titleLabel: UILabel!
    
    private var contentStack: UIStackView!
    
    private var searchBar: UISearchBar!
    
    private var tableView: UITableView!
    
    private var footerLabel: UILabel!
    
    private var permissionView: UIView!
    
    private var permissionDescriptionLabel: UILabel!
    
    private var permissionActionButton: UIButton!
    
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CNContactStoreDidChange, object: nil)
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
        setupTitleLabel()
        setupContentStack()
        setupPermissionStack()
        
        // Will start fetching contacts in Realm first
        // If no contacts found, will try fetching from phone contacts
        fetchContactsFromDB()
        
        // Register for contacts update notification
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContacts), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .black)
        titleLabel.text = "Contacts"
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleLabel.height(40)
    }
    
    private func setupContentStack() {
        contentStack = UIStackView()
        contentStack.isHidden = true
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.spacing = 10
        view.addSubview(contentStack)
        contentStack.edgesToSuperview(excluding: .top, usingSafeArea: true)
        contentStack.topToBottom(of: titleLabel)
        
        setupSearchBar()
        setupTableView()
        setupFooterLabel()
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        contentStack.addArrangedSubview(searchBar)
        searchBar.height(50)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(ContactListItemCell.self, forCellReuseIdentifier: ContactListItemCell.identifier)
        contentStack.addArrangedSubview(tableView)
    }
    
    private func setupPermissionStack() {
        permissionView = UIView()
        permissionView.isHidden = true
        view.addSubview(permissionView)
        permissionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        permissionView.topToBottom(of: titleLabel)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        permissionView.addSubview(stack)
        stack.centerInSuperview()
        stack.widthToSuperview(multiplier: 0.8)
        stack.height(150)
        
        permissionDescriptionLabel = UILabel()
        permissionDescriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        permissionDescriptionLabel.textColor = .secondaryLabel
        permissionDescriptionLabel.textAlignment = .center
        permissionDescriptionLabel.text =
        """
        ContactsApp requires your permission to access your contacts.
        Your contacts are secure and will never leave this app!
        """
        permissionDescriptionLabel.numberOfLines = 0
        stack.addArrangedSubview(permissionDescriptionLabel)
        
        permissionActionButton = UIButton(type: .system)
        permissionActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        permissionActionButton.setTitle("Allow", for: [])
        permissionActionButton.setTitleColor(.white, for: [])
        permissionActionButton.backgroundColor = .systemBlue
        permissionActionButton.layer.cornerRadius = 8
        permissionActionButton.addTarget(self, action: #selector(onPressPermissionButton), for: .touchUpInside)
        
        let view = UIView()
        stack.addArrangedSubview(view)
        view.height(50)
        
        view.addSubview(permissionActionButton)
        permissionActionButton.centerInSuperview()
        permissionActionButton.widthToSuperview(multiplier: 0.8)
        permissionActionButton.heightToSuperview()
    }
        
    private func setupFooterLabel() {
        footerLabel = UILabel()
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        footerLabel.textColor = .systemGray
        footerLabel.textAlignment = .center
        footerLabel.text = "No contacts"
        contentStack.addArrangedSubview(footerLabel)
        footerLabel.height(20)
    }
    
    private func updateUI() {
        let status = ContactsManager.checkPermission()
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.permissionActionButton.setTitle("Allow", for: [])
                self.permissionActionButton.backgroundColor = .systemBlue
                self.permissionView.isHidden = false
                self.contentStack.isHidden = true
                
            case .granted:
                self.permissionActionButton.setTitle("Granted", for: [])
                self.permissionActionButton.backgroundColor = .systemGreen
                self.permissionView.isHidden = true
                self.contentStack.isHidden = false
                self.tableView.reloadData()
                
            case .denied:
                self.permissionActionButton.setTitle("Open Settings", for: [])
                self.permissionActionButton.backgroundColor = .systemRed
                self.permissionView.isHidden = false
                self.contentStack.isHidden = true
            }
        }
    }
    
}


// MARK: - Button functions -

extension ContactsListViewController {
    
    @objc private func onPressPermissionButton() {
        let status = ContactsManager.checkPermission()
        switch status {
        case .notDetermined:
            ContactsManager.getPermission { isGranted in
                self.updateUI()
                if isGranted { self.fetchContactsFromPhone() }
            }
        case .granted:
            fetchContactsFromDB()
        case .denied:
            openSettings()
        }
    }
}


// MARK: - Helper functions -

extension ContactsListViewController {
    
    private func fetchContactsFromDB() {
        allContacts.removeAll()
        allGroups.removeAll()
        filteredGroups.removeAll()
        
        // Get contacts from DB
        // If no countacts are found in DB, its probable because its the first time app is allowed to fetch contacts from phone
        if let contacts = RealmManager.fetchAllContacts(), !contacts.isEmpty {
            allContacts.append(contentsOf: contacts)
            allGroups = ContactsManager.sort(contacts: allContacts)
            filteredGroups.append(contentsOf: allGroups)
            
            DispatchQueue.main.async {
                self.permissionView.isHidden = true
                self.contentStack.isHidden = false
                self.tableView.reloadData()
            }
            
            // Will fetch contacts in background and update Realm if required
            // Will alert user if permission is denied or not available and that contacts are not upto date
            if ContactsManager.checkPermission() == .granted {
                // TODO: - App will not get notification when suspended or not running, But too heavy a task to do everytime app is opened, will have to figure out something else -
                fetchContactsFromPhone()
                
            } else {
                let message = "Contacts from your phone and ContactsApp are not in sync because you have not granted permission to access them. What you are viewing now is the contacts fetched last time the permission was granted."
                showOpenSettingsAlert(message: message)
            }
   
        } else {
            fetchContactsFromPhone()
        }
    }
    
    private func fetchContactsFromPhone(isBackground: Bool = false) {
        switch ContactsManager.checkPermission() {
        case .granted:
            DispatchQueue.main.async { self.view.showLoader(message: "Fetching contacts") }
            
            ContactsManager.fetchAll { contacts in
                DispatchQueue.main.async { self.view.dismissLoader() }

                guard contacts != nil else { return }
                debugPrint("CONTACTS FETCHED")
                
                self.allContacts.removeAll()
                self.allGroups.removeAll()
                self.filteredGroups.removeAll()

                self.allContacts.append(contentsOf: contacts!)
                RealmManager.deleteAllContacts()
                RealmManager.insert(contacts: self.allContacts)

                self.allGroups = ContactsManager.sort(contacts: self.allContacts)
                self.filteredGroups.append(contentsOf: self.allGroups)
                self.isContactsUpdated = false

                DispatchQueue.main.async {
                    self.permissionView.isHidden = true
                    self.contentStack.isHidden = false
                    self.tableView.reloadData()
                }
            }
            
            // Updating bool value after a delay to avoid multiple update contacts notification
            // This is a system issue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isContactsUpdated = false
            }
                            
        case .notDetermined:
            if !isBackground {
                self.permissionActionButton.setTitle("Allow", for: [])
                self.permissionActionButton.backgroundColor = .systemBlue
                self.permissionView.isHidden = false
                self.contentStack.isHidden = true
            } else {
                self.isContactsUpdated = false
                ContactsManager.getPermission { isGranted in
                    self.updateUI()
                    if isGranted { self.fetchContactsFromPhone() }
                }
            }
            
        case .denied:
            if !isBackground {
                self.permissionActionButton.setTitle("Open Settings", for: [])
                self.permissionActionButton.backgroundColor = .systemRed
                self.permissionView.isHidden = false
                self.contentStack.isHidden = true
            } else {
                self.isContactsUpdated = false
                let message = "You made some changes in your phone contacts and its not reflected here because permission is denied for ContactsApp"
                showOpenSettingsAlert(message: message)
            }
        }
    }
    
    @objc private func refreshContacts() {
        // Ignore multiple calls from NotificationCenter
        if !isContactsUpdated {
            debugPrint("REFRESHING CONTACTS FROM PHONE")
            
            isContactsUpdated = true
            fetchContactsFromPhone(isBackground: true)
        }
    }
    
    private func filterContacts(searchText: String) {
        filteredGroups.removeAll()
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredGroups.append(contentsOf: allGroups)
            
        } else {
            let filteredContacts = allContacts.filter { contact -> Bool in
                let firstName = contact.firstName?.lowercased() ?? ""
                let lastName = contact.lastName?.lowercased() ?? ""
                let numbers = contact.numbers.compactMap({ $0.value })
                let emails = contact.emails.compactMap({ $0.value })
                return firstName.contains(searchText) || lastName.contains(searchText) || !numbers.filter({ $0.contains(searchText) }).isEmpty || !emails.filter({ $0.contains(searchText) }).isEmpty
            }
            
            var newGroup = ContactGroup()
            newGroup.title = "Top Matches"
            newGroup.contacts = filteredContacts
            filteredGroups.append(newGroup)
        }
        
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    private func openSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    private func showContactDetailViewController(contact: ContactDetail) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let con = storyBoard.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        con.contact = contact
        DispatchQueue.main.async { self.present(con, animated: true, completion: nil) }
    }
    
    private func showOpenSettingsAlert(message: String) {
        let title = "Alert!!!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            self.openSettings()
        }
        alert.addAction(okAction)
        alert.addAction(openSettingsAction)
        DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
    }
    
}


// MARK: - Table view data source

extension ContactsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactListItemCell.identifier, for: indexPath) as! ContactListItemCell
        cell.selectionStyle = .none
        cell.configure(contact: filteredGroups[indexPath.section].contacts[indexPath.row])
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let titles = filteredGroups.compactMap({ $0.title })
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
        let contact = filteredGroups[indexPath.section].contacts[indexPath.row]
        showContactDetailViewController(contact: contact)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredGroups[section].title
    }
    
}


// MARK: - Search bar delegate -

extension ContactsListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filterContacts(searchText: "")
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContacts(searchText: searchText.lowercased())
    }
    
}


// MARK: - Scroll view delegate -

extension ContactsListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            DispatchQueue.main.async { self.searchBar.resignFirstResponder() }
        }
    }
}
