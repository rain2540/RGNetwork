//
//  RGDownloadConfig.swift
//  RGNetwork
//
//  Created by RAIN on 2021/9/14.
//  Copyright © 2021 Smartech. All rights reserved.
//

import Foundation
import Alamofire

public struct RGDownloadConfig: RGNetworkConfig {

  let urlString: String
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let timeoutInterval: TimeInterval
  let parameters: Parameters?
  let encoding: ParameterEncoding
  var isShowLog: Bool
  let destination: DownloadRequest.Destination?


  init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    isShowLog: Bool = true,
    destination: DownloadRequest.Destination? = nil
  ) {
    self.urlString          =   urlString
    self.method             =   method
    self.parameters         =   parameters
    self.encoding           =   encoding
    self.headers            =   headers
    self.timeoutInterval    =   timeoutInterval
    self.isShowLog          =   isShowLog
    self.destination        =   destination
  }

}
