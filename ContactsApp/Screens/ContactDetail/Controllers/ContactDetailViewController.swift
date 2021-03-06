//
//  ContactDetailViewController.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailViewController: UIViewController {

    
    // MARK: - Properties -
    
    var contact: ContactDetail!
    
    
    // MARK: - Controls -
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    deinit {
        debugPrint("DEINIT CONTACT DETAIL VIEW CONTROLLER")
    }

}


// MARK: - Button functions -

extension ContactDetailViewController {
    
    @IBAction func dismiss(sender: UIButton) {
        DispatchQueue.main.async { self.dismiss(animated: true, completion: nil) }
    }
}


// MARK: - Helper functions -

extension ContactDetailViewController {
    
    private func callNumber(phoneNumber: String?) {
        guard let number = phoneNumber?.replacingOccurrences(of: " ", with: ""),
            let url = URL(string: "telprompt://\(number)") else {
            showAlert(title: "Error", message: "Invalid phone number")
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            showAlert(title: "Error", message: "Calling is allowed only in physical device")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func sendEmail(id: String?) {
        guard let email = id else {
            showAlert(title: "Error", message: "Invalid email address")
            return
        }
        
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Error", message: "Cannot send email, please make sure email is setup in your device")
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([email])
        DispatchQueue.main.async {self.present(mail, animated: true) }
    }
    
}


// MARK: - Mail composer -

extension ContactDetailViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


// MARK: - Table view data source -

extension ContactDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 { return contact.numbers.count }
        else if section == 3 { return contact.emails.count }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageTableViewCell.identifier, for: indexPath) as! ProfileImageTableViewCell
            cell.selectionStyle = .none
            let image = contact.profileImageData != nil ? UIImage(data: contact.profileImageData!) : nil
            cell.profielImageView.image = image
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailTableViewCell.identifier, for: indexPath) as! ProfileDetailTableViewCell
            cell.selectionStyle = .none
            cell.placeholderLabel.text = "Name"
            cell.detailLabel.text = contact.getFullName()
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailTableViewCell.identifier, for: indexPath) as! ProfileDetailTableViewCell
            cell.selectionStyle = .none
            cell.placeholderLabel.text = contact.numbers[indexPath.row].label
            cell.detailLabel.text = contact.numbers[indexPath.row].value
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailTableViewCell.identifier, for: indexPath) as! ProfileDetailTableViewCell
            cell.selectionStyle = .none
            cell.placeholderLabel.text = contact.emails[indexPath.row].label
            cell.detailLabel.text = contact.emails[indexPath.row].value
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailTableViewCell.identifier, for: indexPath) as! ProfileDetailTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
}


// MARK: - Table view delegate -

extension ContactDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 250
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return 30
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            let number = contact.numbers[indexPath.row].value
            callNumber(phoneNumber: number)
        case 3:
            let email = contact.emails[indexPath.row].value
            sendEmail(id: email)
        default:
            break
        }
    }
    
}
