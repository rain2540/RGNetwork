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

  public let uploadRequest: UploadRequest


  // MARK: - Lifecycle

  convenience init(
    urlString: String,
    method: HTTPMethod = .post,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    multipartData: @escaping (MultipartFormData) -> Void
  ) {
    self.init(
      urlString: urlString,
      method: method,
      headers: headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = timeoutInterval
      },
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
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) -> UploadRequest {
    let request = uploadRequest.responseJSON(
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }

  @discardableResult
  public func uploadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) -> UploadRequest {
    let request = uploadRequest.responseDecodable(
      of: type,
      queue: queue,
      additionalConfig: additionalConfig,
      success: success,
      failure: failure)
    return request
  }
  
}
