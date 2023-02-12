//
//  CheckoutCartDataSource.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/11/23.
//

import UIKit

class CheckoutCartDataSource: NSObject, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutCartTableViewController.reuseIdentifier, for: indexPath)
    cell.textLabel?.text = "\(indexPath.row)"
    return cell
  }
  
  
}
