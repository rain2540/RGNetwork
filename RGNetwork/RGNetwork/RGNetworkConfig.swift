//
//  RGNetworkConfig.swift
//  RGNetwork
//
//  Created by RAIN on 2019/12/6.
//  Copyright © 2019 Smartech. All rights reserved.
//

import Foundation

class RGNetworkConfig {

    static let shared = RGNetworkConfig()

    var baseURL: String? = nil

    private init() { }

}
