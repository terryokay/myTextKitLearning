//
//  ViewController.swift
//  TextKit
//
//  Created by hu yr on 2017/2/13.
//  Copyright © 2017年 terry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mylabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mylabel.text = "点击 http://www.baidu.com"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

