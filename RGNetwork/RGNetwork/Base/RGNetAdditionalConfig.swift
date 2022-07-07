//
//  RGNetAdditionalConfig.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/1.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

public struct RGNetAdditionalConfig {

  /// 是否显示 Indicator
  public let showIndicator: Bool
  /// 是否显示日志
  public let showLog: Bool


  public init(showIndicator: Bool = false, showLog: Bool = true) {
    self.showIndicator  = showIndicator
    self.showLog        = showLog
  }

}
