//
//  CaptureResultTableViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit

class CaptureResultTableViewController: UITableViewController {
  
  static var reuseIdentifier = "captureResultCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "captureResultCell")
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CaptureResultTableViewController.reuseIdentifier, for: indexPath)
    cell.textLabel?.text = "\(indexPath.row)"
    return cell
  }
  
}
