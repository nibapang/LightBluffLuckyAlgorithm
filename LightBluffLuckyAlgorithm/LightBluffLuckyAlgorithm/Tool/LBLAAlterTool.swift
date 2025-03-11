//
//  Utils.swift
//  LightBluffLuckyAlgorithm
//
//  Created by jin fu on 2025/3/11.
//


import UIKit

//MARK: - Alert

class LBLAAlterTool {
    static func showAlert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
