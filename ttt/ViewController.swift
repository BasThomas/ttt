//
//  ViewController.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var colorView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func treeFound(_ sender: AnyObject) {
    Network.found()
  }
}
