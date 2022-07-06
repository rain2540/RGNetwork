//
//  DispatchQueue+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/6.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

internal extension DispatchQueue {

  static func mainAsync(execute: @escaping () -> Void) {
    if Thread.current.isMainThread {
      execute()
    } else {
      main.async { execute() }
    }
  }

}
