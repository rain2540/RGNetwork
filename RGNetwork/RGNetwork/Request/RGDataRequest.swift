//
//  RGDataRequest.swift
//  RGNetwork
//
//  Created by Rain on 2020/3/6.
//  Copyright © 2020 Smartech. All rights reserved.
//

import Foundation
import Alamofire

class RGDataRequest {

  public var tag: Int = 0

  public private(set) var dataRequest: DataRequest


  // MARK: - Lifecycle

  /// create network request
  /// - Parameters:
  ///   - urlString: string of URL path
  ///   - method: HTTP method
  ///   - parameters: request parameters
  ///   - encoding: parameter encoding
  ///   - headers: HTTP headers
  ///   - timeoutInterval: 超时时长
  convenience init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0
  ) {
    self.init(
      urlString: urlString,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = timeoutInterval
      }
    )
  }

  init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    requestModifier: Session.RequestModifier? = nil
  ) {
    let urlPath = RGNetwork.urlPathString(by: urlString)
    self.dataRequest = AF.request(
      urlPath,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      interceptor: interceptor,
      requestModifier: requestModifier)
  }

}
