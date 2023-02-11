//
//  BarcodeScanResult.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import Foundation

struct BarcodeScanResult: Codable, Equatable {
  var data: String
  var symbology: String
}
