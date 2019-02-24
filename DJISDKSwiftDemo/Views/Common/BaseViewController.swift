//
//  BaseViewController.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    class func storyboardIdentifier() -> String {
        return ""
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
        
    }
}

