//
//  ViewController.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader

class GameViewController: UIViewController {
  @IBOutlet var colorView: UIView!
  @IBOutlet var treeFoundButton: UIButton!
  
  lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
    $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    $0.cancelButtonTitle = "Annuleer"
    $0.showSwitchCameraButton = false
  })
  
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
  
  @IBAction func scan(_ sender: AnyObject) {
    //    Network.found(by: player)
    //    treeFoundButton.isEnabled = false
    //    let generator = UINotificationFeedbackGenerator()
    //    generator.notificationOccurred(.success)
    
    guard QRCodeReader.isAvailable() else { return present(UIAlertController.error(with: "QR code-lezer niet beschikbaar"), animated: true) }
    
    readerVC.delegate = self
    
    readerVC.modalPresentationStyle = .formSheet
    present(readerVC, animated: true)
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

extension GameViewController: QRCodeReaderViewControllerDelegate {
  
  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    dismiss(animated: true) { [weak self] in
      guard let weakSelf = self else { return }
      // FIXME: Generate feedback after handling server here.
      Network.found(by: weakSelf.player, qr: result.value) { [weak self] error in
        let generator = UINotificationFeedbackGenerator()
        if let error = error {
          self?.present(UIAlertController.error(with: error), animated: true) {
            generator.notificationOccurred(.success)
          }
        } else {
          generator.notificationOccurred(.success)
        }
      }
    }
  }
  
  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    dismiss(animated: true) {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.warning)
    }
  }
}
