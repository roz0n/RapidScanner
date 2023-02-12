//
//  CheckoutCartTableViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit

class CheckoutCartTableViewController: UIViewController {
  
  static var reuseIdentifier = "CheckoutCartCell"
  
  var headerView: CheckoutCartHeaderView
  var tableView: UITableView
  var dataSource: CheckoutCartDataSource
  
  // MARK: - Lifecycle
  
  init(headerView: CheckoutCartHeaderView = CheckoutCartHeaderView(),
       tableView: UITableView = UITableView(frame: .zero, style: .plain),
       dataSource: CheckoutCartDataSource = CheckoutCartDataSource()) {
    self.headerView = headerView
    self.tableView = tableView
    self.dataSource = dataSource
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTableView()
    configureLayout()
  }
  
  private func configureTableView() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: CheckoutCartTableViewController.reuseIdentifier)
    tableView.dataSource = dataSource
  }
  
}

// MARK: - Layout

private extension CheckoutCartTableViewController {
  
  func configureLayout() {
    layoutHeaderView()
    layoutTableView()
  }
  
  func layoutHeaderView() {
    headerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headerView)
    
    NSLayoutConstraint.activate([
      headerView.heightAnchor.constraint(equalToConstant: 64),
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
  }
  
  func layoutTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
}
