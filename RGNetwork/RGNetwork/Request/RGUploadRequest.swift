//
//  RGUploadRequest.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/21.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

class RGUploadRequest {

  public var tag: Int = 0

  public private(set) var config: RGUploadConfig


  // MARK: - Lifecycle

  init(
    urlString: String,
    method: HTTPMethod = .post,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    isShowLog: Bool = true,
    multipartData: @escaping (MultipartFormData) -> Void
  ) {
    self.config = RGUploadConfig(
      urlString: urlString,
      method: method,
      headers: headers,
      timeoutInterval: timeoutInterval,
      isShowLog: isShowLog,
      multipartFormData: multipartData)
  }

  init(
    urlString: String,
    usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
    method: HTTPMethod = .post,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    fileManager: FileManager = .default,
    requestModifier: Session.RequestModifier? = nil,
    multipartFormData: @escaping (MultipartFormData) -> Void
  ) {
    let urlPath = RGNetwork.urlPathString(by: urlString)
    self.uploadRequest = AF.upload(
      multipartFormData: multipartFormData,
      to: urlPath,
      usingThreshold: encodingMemoryThreshold,
      method: method,
      headers: headers,
      interceptor: interceptor,
      fileManager: fileManager,
      requestModifier: requestModifier)
  }

}


// MARK: - Public

extension RGUploadRequest {

  @discardableResult
  public func upload(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) -> UploadRequest {
    let req = AF.upload(config: config)
    let request = req.responseJSON(
      queue: queue,
      showIndicator: showIndicator,
      showLog: config.isShowLog,
      success: success,
      failure: failure)
    return request
  }

  @discardableResult
  public func uploadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) -> UploadRequest {
    let req = AF.upload(config: config)
    let request = req.responseDecodable(
      of: type,
      queue: queue,
      showIndicator: showIndicator,
      showLog: config.isShowLog,
      success: success,
      failure: failure)
    return request
  }
  
}
