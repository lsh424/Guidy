//
//  ViewController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/12.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var arButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonLayout()
    }
    
    func setButtonLayout() {
        guideButton.layer.cornerRadius = 5
        guideButton.layer.borderWidth = 2
        guideButton.layer.borderColor = UIColor.lightGray.cgColor
        
        arButton.layer.cornerRadius = 5
        arButton.layer.borderWidth = 2
        arButton.layer.borderColor = UIColor.lightGray.cgColor
    }

}

