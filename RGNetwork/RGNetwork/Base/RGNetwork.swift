//
//  RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2016/11/15.
//  Copyright © 2016年 Smartech. All rights reserved.
//

import Foundation
import Alamofire


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


// MARK: - String Extension

internal extension String {

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

internal extension DispatchQueue {

  static func mainAsync(execute: @escaping () -> Void) {
    if Thread.current.isMainThread {
      execute()
    } else {
      main.async { execute() }
    }
  }

}


// MARK: - UIApplication Extension

internal extension UIApplication {

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
