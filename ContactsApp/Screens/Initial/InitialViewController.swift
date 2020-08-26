//
//  InitialViewController.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-25.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit
import TinyConstraints

class InitialViewController: UIViewController {
    
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogo()
        setupBaseViewController()
    }
    
}


// MARK: - UI setup functions -

extension InitialViewController {
    
    private func setupLogo() {
        let img = UIImageView()
        img.backgroundColor = UIColor.systemRed
        view.addSubview(img)
        img.centerInSuperview()
        img.width(150)
        img.height(150)
    }
    
    private func setupBaseViewController() {
        let con = ContactsListViewController()
        con.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(con, animated: false, completion: nil)
        }
    }
}
