//
//  Utils.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 15.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

extension UIViewController {
    
    /**
     Creates and shows simple.
     */
    func createAndShowAlert(_ title: String, _ message: String, _ acction: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acction, style: .default) { _ in })
        self.present(alert, animated: true){}
    }
}
