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
  @IBOutlet var treeFoundButton: UIButton!
  
  var player: Player!
  var timer: Timer!
  
  var latestID: Int? {
    didSet {
      guard oldValue != latestID else { return }
      updateColor()
    }
  }
  var latestColor: UIColor?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateColor()
    timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Network.status { [weak self] status in
        switch status {
        case .ready, .ended:
          return
        case .found(id: let id):
          self?.latestID = id
        }
      }
    }
  }
  
  @IBAction func treeFound(_ sender: AnyObject) {
    Network.found(by: player)
    treeFoundButton.isEnabled = false
  }
  
  private func updateColor() {
    treeFoundButton.isEnabled = true
    colorView.backgroundColor = UIColor.gameColors.filter { $0 != latestColor }.random
    latestColor = colorView.backgroundColor
  }
}
