//
//  ScoreTableViewController.swift
//  ttt
//
//  Created by Bas Broek on 17/10/2016.
//  Copyright © 2016 Bas Broek. All rights reserved.
//

import UIKit

class ScoreTableViewController: UITableViewController {
  
  var scores: [Score] = [] {
    didSet {
      scores = scores.sorted { $0.points > $1.points }
      tableView.reloadData()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Network.score { [weak self] in
      self?.scores = $0
    }
  }
  
  @IBAction func done(_ sender: AnyObject) {
    dismiss(animated: true)
  }
}

// MARK: - Table view data source
extension ScoreTableViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scores.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "score", for: indexPath)
    cell.textLabel?.text = scores[indexPath.row].name
    cell.detailTextLabel?.text = "\(scores[indexPath.row].points)"
    return cell
  }
}
