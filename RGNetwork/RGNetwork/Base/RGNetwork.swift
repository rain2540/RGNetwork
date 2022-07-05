//
//  RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2016/11/15.
//  Copyright © 2016年 Smartech. All rights reserved.
//

import Foundation
import Alamofire
//import AlamofireNetworkActivityIndicator
import MBProgressHUD


public typealias ResponseJSON = [String: Any]
public typealias ResponseString = String
public typealias ResponseData = Data
public typealias HttpStatusCode = Int


public typealias SuccessRequest = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void
public typealias FailureRequest = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void

public typealias SuccessRequestDecodable<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
public typealias FailureRequestDecodable<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

public typealias SuccessDownload = (ResponseJSON?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void
public typealias FailureDownload = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void

public typealias SuccessDownloadDecodable<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
public typealias FailureDownloadDecodable<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void


// MARK: -

struct RGNetwork { }


// MARK: - URL Path Handle

extension RGNetwork {

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
      dLog("RGNetwork.URLPathString.error: Wrong URL Format")
      return ""
    }
  }

}


// MARK: - Indicator View

extension RGNetwork {
  /*
  /// 在 Status Bar 上显示 Activity Indicator
  /// - Parameters:
  ///   - startDelay: 开始延迟时间
  ///   - completionDelay: 结束延迟时间
  public static func showActivityIndicator(
    startDelay: TimeInterval = 0.0,
    completionDelay: TimeInterval = 0.7
  ) {
    NetworkActivityIndicatorManager.shared.isEnabled = true
    NetworkActivityIndicatorManager.shared.startDelay = startDelay
    NetworkActivityIndicatorManager.shared.completionDelay = completionDelay
  }
   */
  /// 显示 indicator
  /// - Parameters:
  ///   - mode: 显示模式，默认为 .indeterminate
  ///   - text: 显示的文字，默认为空
  internal static func showIndicator(
    mode: MBProgressHUDMode = .indeterminate,
    text: String = ""
  ) {
    DispatchQueue.mainAsync {
      guard let window = UIApplication.shared.keySceneWindow else { return }
      let hud = MBProgressHUD.showAdded(to: window, animated: true)
      hud.mode = mode
      hud.label.text = text
    }
  }

  /// 隐藏 indicator
  internal static func hideIndicator() {
    DispatchQueue.mainAsync {
      guard let window = UIApplication.shared.keySceneWindow else { return }
      MBProgressHUD.hide(for: window, animated: true)
    }
  }

}


// MARK: - Proxy

extension RGNetwork {

  /// 是否设置网络代理
  public static var isSetupProxy: Bool {
    if proxyType == kCFProxyTypeNone {
      dLog("当前未设置网络代理")
      return false
    } else {
      dLog("当前设置了网络代理")
      return true
    }
  }

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

extension RGNetwork {

  /// 是否开启 VPN
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


// MARK: - String Extension

fileprivate extension String {

  /// 是否含有 http / https 前缀
  var rg_hasHttpPrefix: Bool {
    return self.hasPrefix("http://") || self.hasPrefix("https://")
  }

  /// 如果含有某个后缀，则删除
  /// - Parameter suffix: 需要删除的后缀
  mutating func rg_removeLast(ifHas suffix: String) {
    if hasSuffix(suffix) {
      removeLast()
    }
  }

}


// MARK: - DispatchQueue

fileprivate extension DispatchQueue {

  static func mainAsync(execute: @escaping () -> Void) {
    if Thread.current.isMainThread {
      execute()
    } else {
      main.async { execute() }
    }
  }

}


// MARK: - UIApplication Extension

fileprivate extension UIApplication {

  var keySceneWindow: UIWindow? {
    if #available(iOS 13, *) {
      var keyWindow: UIWindow?
      for connectedScene in UIApplication.shared.connectedScenes {
        guard let windowScene = connectedScene as? UIWindowScene else {
          continue
        }
        if #available(iOS 15, *) {
          keyWindow = windowScene.keyWindow
          break
        } else {
          for window in windowScene.windows where window.isKeyWindow {
            keyWindow = window
          }
        }
      }
      return keyWindow
    } else {
      return UIApplication.shared.keyWindow
    }
  }

}


// MARK: - Debug Log

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
