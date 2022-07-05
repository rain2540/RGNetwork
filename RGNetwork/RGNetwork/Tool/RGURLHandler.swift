//
//  RGURLHandler.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/5.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

struct RGURLHandler {

  internal static func urlPathString(by urlString: String) -> String {
    if urlString.rg_hasHttpPrefix {
      let fixURLString = urlString
        .replacingOccurrences(of: "//", with: "/")
        .replacingOccurrences(of: ":/", with: "://")
      return fixURLString
    } else if let host = RGNetworkPreset.shared.baseURL, host.rg_hasHttpPrefix {
      if host.hasSuffix("/") && urlString.hasPrefix("/") {
        var fixHost = host
        fixHost.rg_removeLast(ifHas: "/")
        return fixHost + urlString
      } else if host.hasSuffix("/") == false && urlString.hasPrefix("/") == false {
        return host + "/" + urlString
      } else {
        return host + urlString
      }
    } else {
      dLog("RGURLHandler.URLPathString.error: Wrong URL Format")
      return ""
    }
  }

}
