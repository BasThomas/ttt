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
import Kingfisher

class GameViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.kf.setImage(with: game.url)
    }
  }
  @IBOutlet var treeFoundButton: UIButton!
  
  lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
    $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    $0.cancelButtonTitle = "Annuleer"
    $0.showSwitchCameraButton = false
  })
  
  var audioPlayerCorrect: AVAudioPlayer?
  var audioPlayerError: AVAudioPlayer?
  var game: Game! {
    didSet {
      latestURLString = String(game.url.path.characters.dropFirst())
    }
  }
  var timer: Timer!
  var latestURLString: String?
  var verifyingScan = false
  var status: Status?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareSound()
    timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Network.status { [weak self] status in
        print("STATUS: \(status)")
        self?.status = status
        switch status {
        case .ready:
          ()
        case .ended:
          self?.timer.invalidate()
          _ = self?.navigationController?.popToRootViewController(animated: true)
          self?.dismiss(animated: true)
        case .found(id: _):
          ()
        }
      }
    }
  }
  
  deinit {
    timer.invalidate()
  }
  
  @IBAction func scan(_ sender: AnyObject) {
    guard QRCodeReader.isAvailable() else { return present(UIAlertController.error(with: "QR code-lezer niet beschikbaar"), animated: true) }
    
    readerVC.delegate = self
    
    readerVC.modalPresentationStyle = .formSheet
    present(readerVC, animated: true)
  }
  
  func updateImage(with url: URL) {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    audioPlayerCorrect?.play()
    treeFoundButton.isEnabled = true
    imageView.kf.setImage(with: url)
    latestURLString = String(url.path.characters.dropFirst())
  }
  
  private func prepareSound() {
    audioPlayerCorrect = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "correct", ofType: "wav")!))
    audioPlayerError = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "error", ofType: "wav")!))
    audioPlayerCorrect?.prepareToPlay()
    audioPlayerError?.prepareToPlay()
  }
}

extension GameViewController: QRCodeReaderViewControllerDelegate {
  
  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    guard !verifyingScan else { return }
    verifyingScan = true
    dismiss(animated: true) { [weak self] in
      guard
        let weakSelf = self,
        let imageURLString = self?.latestURLString else { return }
      Network.found(by: weakSelf.game.player, qr: result.value, latestURL: imageURLString) { [weak self] url, error in
        let generator = UINotificationFeedbackGenerator()
        if let error = error {
          let handler: ((UIAlertAction) -> Void)? = { [weak self] _ in
            guard self?.status == .ended else { return }
            self?.dismiss(animated: true)
          }
          self?.present(UIAlertController.error(with: error, completionHandler: handler), animated: true) {
            generator.notificationOccurred(.error)
            self?.audioPlayerError?.play()
          }
        } else if let url = url {
          self?.updateImage(with: url)
          generator.notificationOccurred(.success)
        }
        self?.verifyingScan = false
      }
    }
  }
  
  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    verifyingScan = false
    dismiss(animated: true) {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.warning)
    }
  }
}
