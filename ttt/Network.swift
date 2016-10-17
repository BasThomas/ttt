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

fileprivate let baseURL = "http://145.93.32.69:8000" //"http://192.168.1.2:8000"

typealias Name = String

enum Network {
  
  static func start(with name: Name, completionHandler: @escaping (Game?, String?) -> Void) {
    Alamofire.request("\(baseURL)/api/start", method: .post, parameters: ["name": name]).responseJSON { response in
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
          let url = try json.getString(at: "url")
          guard let imageURL = URL(string: "\(baseURL)/\(url)") else {
            completionHandler(nil, "Ongeldige URL")
            return
          }
          completionHandler(Game(player: player, url: imageURL), nil)
        } catch {
          completionHandler(nil, error.localizedDescription)
        }
      default:
        return
      }
    }
  }
  
  static func found(by player: Player, qr: String, latestURL imageURL: String, completionHandler: @escaping (URL?, String?) -> Void) {
    Alamofire.request("\(baseURL)/api/found", method: .post, parameters: ["id": player.id, "qr": qr, "imageURL": imageURL]).responseJSON { response in
      guard
        let data = response.data,
        let statusCode = response.response?.statusCode else { return }
      switch statusCode {
      case 404:
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
          let urlString = try json.getString(at: "url")
          completionHandler(URL(string: "\(baseURL)/\(urlString)"), nil)
        } catch {
          completionHandler(nil, error.localizedDescription)
        }
      default:
        completionHandler(nil, "Unhandled status code. (\(statusCode))")
        return
      }
    }
  }
  
  static func status(completionHandler: @escaping (Status) -> Void) {
    Alamofire.request("\(baseURL)/api/status", method: .get).responseJSON { response in
      guard
        let data = response.data,
        let json = try? JSON(data: data),
        let status = try? Status(json: json) else { return }
      completionHandler(status)
    }
  }
  
  static func score(completionHandler: @escaping ([Score]) -> Void) {
    Alamofire.request("\(baseURL)/api/score", method: .get).responseJSON { response in
      print(response)
      guard
        let data = response.data,
        let json = try? JSON(data: data),
        let scores = try? json.getArray(at: "score").map(Score.init) else { return }
      completionHandler(scores)
    }
  }
}
