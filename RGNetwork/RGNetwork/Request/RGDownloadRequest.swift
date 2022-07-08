//
//  RGDownloadRequest.swift
//  RGNetwork
//
//  Created by RAIN on 2021/9/23.
//  Copyright © 2021 Smartech. All rights reserved.
//

import UIKit
import Alamofire

open class RGDownloadRequest {

  public var tag: Int = 0

  public let downloadRequest: DownloadRequest


  // MARK: - Lifecycle

  init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    destination: DownloadRequest.Destination? = nil
  ) {
    let urlPath = RGURLHandler.urlPathString(by: urlString)
    self.downloadRequest = AF.download(
      urlPath,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = timeoutInterval
      },
      to: destination)
  }

  init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    requestModifier: Session.RequestModifier? = nil,
    destination: DownloadRequest.Destination? = nil
  ) {
    let urlPath = RGURLHandler.urlPathString(by: urlString)
    self.downloadRequest = AF.download(
      urlPath,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      interceptor: interceptor,
      requestModifier: requestModifier,
      to: destination)
  }

}
