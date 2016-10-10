//
//  Network.swift
//  ttt
//
//  Created by Bas Broek on 06/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

fileprivate let baseURL = "http://145.93.33.189:8000/api" //"http://192.168.1.2:8000/api"

enum Network {
  
  static func start(completionHandler: @escaping (Player?, String?) -> Void) {
    Alamofire.request("\(baseURL)/start", method: .post, parameters: [:]).responseJSON { response in
      guard
        let data = response.data,
        let statusCode = response.response?.statusCode else { return }
      switch statusCode {
      case 412:
        do {
          let json = try JSON(data: data)
          let message = try json.getString(at: "message")
          completionHandler(nil, message)
        } catch {
          completionHandler(nil, error.localizedDescription)
        }
      case 200:
        do {
          let json = try JSON(data: data)
          let player = try Player(json: json)
          completionHandler(player, nil)
        } catch {
          completionHandler(nil, error.localizedDescription)
        }
      default:
        return
      }
    }
  }
  
  static func found(by player: Player, qr: String, completionHandler: @escaping (String?) -> Void) {
    Alamofire.request("\(baseURL)/found", method: .post, parameters: ["id": player.id, "qr": qr]).responseJSON { response in
      guard
        let data = response.data,
        let statusCode = response.response?.statusCode else { return }
      switch statusCode {
      case 404:
        do {
          let json = try JSON(data: data)
          let message = try json.getString(at: "message")
          completionHandler(message)
        } catch {
          completionHandler(error.localizedDescription)
        }
      case 200:
        completionHandler(nil)
      default:
        completionHandler("Unhandled status code. (\(statusCode))")
        return
      }
    }
  }
  
  static func status(completionHandler: @escaping (Status) -> Void) {
    Alamofire.request("\(baseURL)/status", method: .get).responseJSON { response in
      guard
        let data = response.data,
        let json = try? JSON(data: data),
        let status = try? Status(json: json) else { return }
      completionHandler(status)
    }
  }
}
