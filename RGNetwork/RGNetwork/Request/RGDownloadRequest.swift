//
//  RGDownloadRequest.swift
//  RGNetwork
//
//  Created by RAIN on 2021/9/23.
//  Copyright © 2021 Smartech. All rights reserved.
//

import UIKit
import Alamofire

class RGDownloadRequest {

  var tag: Int = 0

  public private(set) var config: RGDownloadConfig
  public let downloadRequest: DownloadRequest


  // MARK: - Lifecycle

  convenience init(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    destination: DownloadRequest.Destination? = nil
  ) {
    self.init(
      urlString: urlString,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = timeoutInterval
      },
      destination: destination)
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
    let urlPath = RGNetwork.urlPathString(by: urlString)
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


// MARK: - Public

extension RGDownloadRequest {

  @discardableResult
  public func download(
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessDownload,
    failure: @escaping FailureDownload
  ) -> DownloadRequest {
    let request = downloadRequest.responseJSON(
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }

  @discardableResult
  public func downloadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessDownloadDecodable<T>,
    failure: @escaping FailureDownloadDecodable<T>
  ) -> DownloadRequest {
    let request = downloadRequest.responseDecodable(
      of: type,
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }

}
