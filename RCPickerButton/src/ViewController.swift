//
//  ViewController.swift
//  RCPickerButton
//
//  Created by Nick on 2/12/15.
//  Copyright © 2015 spromicky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = RCPickerButton(color: UIColor.redColor())
        button.frame = CGRect(x: 40, y: 40, width: 30, height: 85)
        view.addSubview(button)
    }
}

