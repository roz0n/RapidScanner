//
//  UIViewExtension.swift
//  CoSign
//
//  Created by Arnaldo Rozon on 9/23/22.
//
import UIKit

extension UIView {
  
  enum UIViewSide {
    case top, bottom, left, right
  }
  
  func fill(view: UIView, margins: [UIViewSide: CGFloat]? = nil) {
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(margins?[.top] ?? 0)),
      leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(margins?[.left] ?? 0)),
      trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -CGFloat(margins?[.right] ?? 0)),
      bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -CGFloat(margins?[.bottom] ?? 0))
    ])
  }
  
  func setBorder(side: UIViewSide, color: UIColor, width: CGFloat, padding: CGFloat? = 0) {
    let border = UIView()
    
    border.translatesAutoresizingMaskIntoConstraints = false
    border.backgroundColor = color
    
    self.addSubview(border)
    
    let topConstraint = topAnchor.constraint(equalTo: border.topAnchor, constant: padding ?? 0)
    let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor, constant: -(padding ?? 0))
    let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor, constant: -(padding ?? 0))
    let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor, constant: padding ?? 0)
    let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
    let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
    
    switch side {
      case .top:
        NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
      case .right:
        NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
      case .bottom:
        NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
      case .left:
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
    }
  }
  
}
