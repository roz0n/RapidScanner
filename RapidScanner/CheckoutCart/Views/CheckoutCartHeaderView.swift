//
//  CheckoutCartHeaderView.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/11/23.
//

import UIKit

class CheckoutCartHeaderView: UIView {
  
  lazy var mainContainer: UIStackView = {
    let stack = UIStackView()
    stack.spacing = UIStackView.spacingUseSystem
    return stack
  }()
  
  lazy var checkoutLabelContainer: UIStackView = {
    let stack = UIStackView()
    stack.spacing = UIStackView.spacingUseSystem
    return stack
  }()
  
  
  lazy var titleLabel: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Checkout", for: .normal)
    button.tintColor = .white
    button.backgroundColor = .clear
    button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 8)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.titleLabel?.textAlignment = .left
    button.isUserInteractionEnabled = false
    return button
  }()
  
  lazy var quantityLabel: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("0", for: .normal)
    button.tintColor = .white
    button.titleLabel?.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
    button.titleLabel?.textAlignment = .left
    button.isUserInteractionEnabled = false
    button.layer.cornerRadius = 16
    return button
  }()
  
  lazy var checkoutButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tintColor = .white
    button.backgroundColor = .clear
    button.setImage(UIImage(systemName: "cart"), for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 24)
    return button
  }()
  
  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .systemBackground
    
    setupView()
    setupContraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupView() {
    clipsToBounds = true
    layer.cornerRadius = 12
    layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
  }
  
}

// MARK: - Constraints

private extension CheckoutCartHeaderView {
  
  func setupContraints() {
    layoutContainer()
    layoutCheckoutLabelContainer()
    
    layoutTitleLabel()
    layoutSpacer()
    layoutCheckoutLabelContainer()
    layoutQuantityLabel()
    layoutCheckoutButton()
  }
  
  func layoutContainer() {
    addSubview(mainContainer)
    mainContainer.translatesAutoresizingMaskIntoConstraints = false
    mainContainer.fill(view: self)
  }
  
  func layoutTitleLabel() {
    mainContainer.addArrangedSubview(titleLabel)
  }
  
  func layoutSpacer() {
    mainContainer.addArrangedSubview(UIView())
  }
  
  func layoutCheckoutLabelContainer() {
    mainContainer.addArrangedSubview(checkoutLabelContainer)
  }
  
  func layoutQuantityLabel() {
    checkoutLabelContainer.addArrangedSubview(quantityLabel)
  }
  
  func layoutCheckoutButton() {
    checkoutLabelContainer.addArrangedSubview(checkoutButton)
  }
  
}
