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


public typealias RequestSuccess = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void
public typealias RequestFailure = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void

public typealias RequestDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
public typealias RequestDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

public typealias DownloadSuccess = (ResponseJSON?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void
public typealias DownloadFailure = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void

public typealias DownloadDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
public typealias DownloadDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void







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
