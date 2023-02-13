//
//  CheckoutCartDataSource.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/11/23.
//

import UIKit

class CheckoutCartDataSource: NSObject, UITableViewDataSource {
  
  var barcodeScanData: [CheckoutCartItem] = []
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return barcodeScanData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutCartTableViewController.reuseIdentifier, for: indexPath)
    let data = barcodeScanData[indexPath.row]
    var content = cell.defaultContentConfiguration()
    
    content.text = "\(data.scanData.data)"
    content.secondaryText = "Quantity: \(data.quantity)"
    cell.contentConfiguration = content
    
    return cell
  }
  
  
}
