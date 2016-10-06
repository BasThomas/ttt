//
//  Array+Random.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import Foundation

extension Array {
  
  var random: Element {
    let res = Int(arc4random_uniform(UInt32(self.count)))
    return self[res]
  }
}
