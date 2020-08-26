//
//  ContactListItemCell.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit
import TinyConstraints

class ContactListItemCell: UITableViewCell {
    
    
    // MARK: - Properties -
    
    static let identifier = "ContactListItemCell"
    
    private var contentStack: UIStackView!
    
    private var profileView: UIView!
    
    private var profileImageView: UIImageView!
    
    private var initialsLabel: UILabel!
    
    private var nameLabel: UILabel!
    
    
    // MARK: - Lifecycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Pubic helper functions -
    
    func configure(contact: ContactDetail) {
        setupUI()
        
        profileImageView.image = contact.thumbnailImageData != nil ? UIImage(data: contact.thumbnailImageData!) : nil
        nameLabel.text = contact.getFullName()
        initialsLabel.text = contact.getInitials()
    }
    
}


// MARK: - UI Setup functions -

extension ContactListItemCell {
    
    private func setupUI() {
        setupContentStack()
        setupProfileView()
        setupInitialsLabel()
        setupProfileImageView()
        setupNameLabel()
    }
    
    private func setupContentStack() {
        guard contentStack == nil else { return }
        contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.spacing = 10
        addSubview(contentStack)
        contentStack.edgesToSuperview(insets: TinyEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    private func setupProfileView() {
        guard profileView == nil else { return }
        profileView = UIView()
        profileView.layer.cornerRadius = 30
        profileView.clipsToBounds = true
        contentStack.addArrangedSubview(profileView)
        profileView.width(60)
    }
    
    private func setupProfileImageView() {
        guard profileImageView == nil else { return }
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileView.addSubview(profileImageView)
        profileImageView.edgesToSuperview()
    }
    
    private func setupInitialsLabel() {
        guard initialsLabel == nil else { return }
        initialsLabel = UILabel()
        initialsLabel.textColor = .label
        initialsLabel.font = UIFont.systemFont(ofSize: 16, weight: .black)
        initialsLabel.textAlignment = .center
        initialsLabel.backgroundColor = .systemGray
        profileView.addSubview(initialsLabel)
        initialsLabel.edgesToSuperview()
    }
    
    private func setupNameLabel() {
        guard nameLabel == nil else { return }
        nameLabel = UILabel()
        nameLabel.textColor = .label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentStack.addArrangedSubview(nameLabel)
    }
    
}
