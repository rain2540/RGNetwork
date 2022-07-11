//
//  RGUploadRequest.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/21.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

open class RGUploadRequest {

  public var tag: Int = 0

  public let uploadRequest: UploadRequest


  // MARK: - Lifecycle

  init(
    urlString: String,
    method: HTTPMethod = .post,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0,
    multipartData: @escaping (MultipartFormData) -> Void
  ) {
    let urlPath = RGURLHandler.urlPathString(by: urlString)
    self.uploadRequest = AF.upload(
      multipartFormData: multipartData,
      to: urlPath,
      method: method,
      headers: headers,
      timeoutInterval: timeoutInterval)
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
    let urlPath = RGURLHandler.urlPathString(by: urlString)
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
