//
//  Score.swift
//  ttt
//
//  Created by Bas Broek on 17/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import Foundation
import Freddy

struct Score {
  let name: String
  let points: Int
}

extension Score: JSONDecodable {
  
  init(json value: JSON) throws {
    self.name = try value.getString(at: "name")
    self.points = try value.getInt(at: "points")
  }
}
