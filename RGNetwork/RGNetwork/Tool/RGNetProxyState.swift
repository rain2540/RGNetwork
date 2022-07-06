//
//  RGNetProxyState.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/5.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

public struct RGNetProxyState {

  /// 网络代理主机名
  public static var proxyHostName: String {
    let hostName = proxyInfos.object(forKey: kCFProxyHostNameKey) as? String ?? "Proxy Host Name is nil"
    dLog("Proxy Host Name: \(hostName)")
    return hostName
  }

  /// 网络代理端口号
  public static var proxyPortNumber: String {
    let portNumber = proxyInfos.object(forKey: kCFProxyPortNumberKey) as? String ?? "Proxy Port Number is nil"
    dLog("Proxy Port Number: \(portNumber)")
    return portNumber
  }

  /// 网络代理类型
  public static var proxyType: CFString {
    let type = proxyInfos.object(forKey: kCFProxyTypeKey) ?? kCFProxyTypeNone
    dLog("Proxy Type: \(type)")
    return type
  }

  /// 网络代理信息
  private static var proxyInfos: AnyObject {
    let proxySetting = CFNetworkCopySystemProxySettings()!.takeUnretainedValue()
    let url = URL(string: "https://www.baidu.com")!
    let proxyArray = CFNetworkCopyProxiesForURL(url as CFURL, proxySetting).takeUnretainedValue()

    let proxyInfo = (proxyArray as [AnyObject])[0]
    return proxyInfo
  }

}


// MARK: - VPN

extension RGNetProxyState {

  /// 是否开启 VPN
  /// - Virtual Private Network
  public static var isVPNOn: Bool {
    var flag = false
    let proxySetting = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [AnyHashable: Any] ?? [:]
    let keys = (proxySetting["__SCOPED__"] as? NSDictionary)?.allKeys as? [String] ?? []

    for key in keys {
      let checkStrings = ["tap", "tun", "ipsec", "ppp"]
      let condition = checkStrings.contains(key)

      if condition {
        dLog("当前开启了 VPN")
        flag = true
        break
      }
    }
    if flag == false {
      dLog("当前未开启 VPN")
    }
    return flag
  }

}
