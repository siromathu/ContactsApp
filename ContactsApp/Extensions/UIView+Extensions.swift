//
//  UIView+Extensions.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-27.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit


extension UIView {
 
    /// ShowLoader:  loading view ..
    /// - parameter Color:  ActivityIndicator and view loading color .
    func showLoader(message: String? = nil) {
        let loaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        loaderView.tag = -888754
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        loaderView.addSubview(stack)
        stack.centerInSuperview()
        stack.widthToSuperview()
        stack.height(60)
        
        let loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        loader.center = loaderView.center
        loader.style = .large
        loader.tintColor = .label
        loader.startAnimating()
        stack.addArrangedSubview(loader)
        
        if let message = message {
            let label = UILabel()
            label.text = message
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
        
        self.addSubview(loaderView)
        loaderView.edgesToSuperview()
        self.bringSubviewToFront(loaderView)
    }
 
    /// DismissLoader:  hide loading view
    func dismissLoader() {
        DispatchQueue.main.async { self.viewWithTag(-888754)?.removeFromSuperview() }
    }
}
