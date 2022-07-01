//
//  RGNetAdditionalConfig.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/1.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

public struct RGNetAdditionalConfig {

  public let showIndicator: Bool
  public let showLog: Bool


  public init(showIndicator: Bool = false, showLog: Bool = true) {
    self.showIndicator = showIndicator
    self.showLog = showLog
  }

}
