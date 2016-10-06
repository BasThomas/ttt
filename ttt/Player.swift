//
//  Player.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import Foundation
import Freddy

struct Player {
  let id: Int
  let name: String
}

extension Player: JSONDecodable {
  
  init(json value: JSON) throws {
    self.id = try value.getInt(at: "id")
    self.name = try value.getString(at: "name")
  }
}
