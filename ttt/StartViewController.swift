//
//  StartViewController.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit

private let startIdentifier = "start"

class StartViewController: UIViewController {
  @IBOutlet var startButton: UIButton!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startButton.isEnabled = true
  }
  
  @IBAction func start(_ sender: AnyObject) {
    startButton.isEnabled = false
    Network.start { [weak self] game, message in
      if let message = message {
        self?.present(UIAlertController.error(with: message), animated: true) {
          let generator = UINotificationFeedbackGenerator()
          generator.notificationOccurred(.error)
        }
        self?.startButton.isEnabled = true
      } else {
        self?.performSegue(withIdentifier: startIdentifier, sender: game)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let destination = segue.destination as? GameViewController,
      let game = sender as? Game,
      segue.identifier == startIdentifier else { return }
    destination.game = game
  }
}
