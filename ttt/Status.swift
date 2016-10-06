//
//  Status.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import Foundation
import Freddy

enum Status {
  case ready
  case found(id: Int)
  case ended
}

extension Status: JSONDecodable {
  
  init(json value: JSON) throws {
    let string = try value.getString(at: "status")
    let split = string.characters.split { $0 == "-" }.map(String.init)
    if
      let found = split.first,
      let idString = split.last,
      let id = Int(idString),
      found == "found" {
      self = .found(id: id)
      return
    }
    
    switch string {
    case "ready":
      self = .ready
    case "ended":
      self = .ended
    default:
      fatalError("invalid value \(value)")
    }
  }
}
