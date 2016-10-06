//
//  ViewController.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
  @IBOutlet var colorView: UIView!
  @IBOutlet var treeFoundButton: UIButton!
  
  var audioPlayer: AVAudioPlayer?
  var player: Player!
  var timer: Timer!
  
  var latestID: Int? {
    didSet {
      guard oldValue != latestID else { return }
      updateColor()
    }
  }
  var latestColor: UIColor?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateColor()
    prepareSound()
    timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Network.status { [weak self] status in
        switch status {
        case .ready:
          ()
        case .ended:
          self?.dismiss(animated: true)
          self?.timer.invalidate()
        case .found(id: let id):
          self?.latestID = id
        }
      }
    }
  }
  
  @IBAction func treeFound(_ sender: AnyObject) {
    Network.found(by: player)
    treeFoundButton.isEnabled = false
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
  }
  
  private func updateColor() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    audioPlayer?.play()
    treeFoundButton.isEnabled = true
    colorView.backgroundColor = UIColor.gameColors.filter { $0 != latestColor }.random
    latestColor = colorView.backgroundColor
  }
  
  private func prepareSound() {
    audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "feedback", ofType: "wav")!))
    audioPlayer?.prepareToPlay()
  }
}
