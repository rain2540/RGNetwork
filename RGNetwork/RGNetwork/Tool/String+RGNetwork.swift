//
//  String+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/6.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

internal extension String {

  /// 如果含有某个后缀，则删除
  /// - Parameter suffix: 需要删除的后缀
  mutating func rg_removeLast(ifHas suffix: String) {
    if hasSuffix(suffix) {
      removeLast()
    }
  }

}
