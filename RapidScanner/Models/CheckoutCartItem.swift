//
//  CheckoutCartItem.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/12/23.
//

import Foundation

struct CheckoutCartItem: Equatable  {
  var scanData: BarcodeScanResult
  var quantity: Int
}
