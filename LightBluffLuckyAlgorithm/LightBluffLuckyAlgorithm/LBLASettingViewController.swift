//
//  SettingViewController.swift
//  LightBluffLuckyAlgorithm
//
//  Created by LightBluff LuckyAlgorithm on 2025/3/11.
//


import UIKit

class LBLASettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func back(_ sender :UIButton)
    {
        navigationController?.popViewController(animated: true)
    }

}
