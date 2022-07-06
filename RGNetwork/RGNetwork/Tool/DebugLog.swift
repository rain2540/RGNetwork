//
//  DebugLog.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/6.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

internal func dLog(
  _ item: @autoclosure () -> Any,
  separator: String = " ",
  terminator: String = "\n",
  file: String = #file,
  method: String = #function,
  line: Int = #line
) {
#if DEBUG
  print("\n/* ***** ***** ***** ***** ***** ***** */\n")
  print("\(URL(fileURLWithPath: file).lastPathComponent)[\(line)], \(method): \n")
  print(item(), separator: separator, terminator: terminator)
  print("")
#endif
}
