//
//  ViewController.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
  @IBOutlet var colorView: UIView!
  
  var player: Player!
  var timer: Timer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    colorView.backgroundColor = UIColor.gameColors.random
    timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Network.status { status in
        print("Status: \(status)")
      }
    }
  }
  
  @IBAction func treeFound(_ sender: AnyObject) {
    Network.found(by: player)
  }
}
