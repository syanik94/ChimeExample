//
//  UIViewController+Extensions.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/14/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSingleActionAlert(title: String, message: String, actionTitle: String, actionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel, handler: actionHandler)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}
