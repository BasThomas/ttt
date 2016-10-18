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
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var startButton: UIButton!
  
  private var isStarted = false
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startButton.isEnabled = true
    nameTextField.text = nil
    nameTextField.setValue(UIColor.init(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.5), forKeyPath: "_placeholderLabel.textColor")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if isStarted {
      isStarted = false
      presentScore()
    }
  }
  
  @IBAction func start(_ sender: AnyObject) {
    guard
      let name = nameTextField.text,
      !name.isEmpty else {
      present(UIAlertController.error(with: "Geen gebruikersnaam ingevuld"), animated: true) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
      }
      return
    }
    startButton.isEnabled = false
    Network.start(with: name) { [weak self] game, message in
      if let message = message {
        self?.present(UIAlertController.error(with: message), animated: true) {
          let generator = UINotificationFeedbackGenerator()
          generator.notificationOccurred(.error)
        }
        self?.startButton.isEnabled = true
      } else {
        self?.isStarted = true
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
  
  private func presentScore() {
    performSegue(withIdentifier: "showScore", sender: self)
  }
}
