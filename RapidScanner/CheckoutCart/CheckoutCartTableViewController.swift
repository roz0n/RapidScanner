//
//  CheckoutCartTableViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit

class CheckoutCartTableViewController: UIViewController {
  
  static var reuseIdentifier = "CheckoutCartCell"
  static var defaultShowHeight: CGFloat = 64
  
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
    
    setupTableView()
    setupContraints()
  }
  
  private func setupTableView() {
    tableView.register(UITableViewCell.self,
                       forCellReuseIdentifier: CheckoutCartTableViewController.reuseIdentifier)
    tableView.dataSource = dataSource
  }
  
//  private func setupCheckoutButton() {
//    headerView.checkoutButton.addTarget(self, action: #selector(tappedCheckoutButton), for: .touchUpInside)
//  }
//
//  @objc func tappedCheckoutButton() {
//
//  }
  
}

// MARK: - Constraints

private extension CheckoutCartTableViewController {
  
  func setupContraints() {
    layoutHeaderView()
    layoutTableView()
  }
  
  func layoutHeaderView() {
    headerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headerView)
    
    NSLayoutConstraint.activate([
      headerView.heightAnchor.constraint(equalToConstant: CheckoutCartTableViewController.defaultShowHeight),
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
