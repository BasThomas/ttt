//
//  UIAlertController+Success.swift
//  ttt
//
//  Created by Bas Broek on 10/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit

extension UIAlertController {
  
  static func success(with title: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    return alert
  }
}
