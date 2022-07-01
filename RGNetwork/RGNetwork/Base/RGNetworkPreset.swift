//
//  RGNetworkPreset.swift
//  RGNetwork
//
//  Created by RAIN on 2019/12/6.
//  Copyright © 2019 Smartech. All rights reserved.
//

import Foundation

class RGNetworkPreset {

  static let shared = RGNetworkPreset()

  var baseURL: String? = nil

  private init() { }

}
