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
      requestModifier: requestModifier
    )
  }

}


// MARK: - Public

extension RGDataRequest {

  /// 执行请求
  /// - Parameters:
  ///   - queue: 执行请求的队列
  ///   - showIndicator: 是否显示 Indicator
  ///   - success: 请求成功的 Task
  ///   - failure: 请求失败的 Task
  @discardableResult
  public func task(
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) -> DataRequest {
    let request = dataRequest.responseJSON(
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }

  @discardableResult
  public func taskDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) -> DataRequest {
    let request = dataRequest.responseDecodable(
      of: type,
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }

}
