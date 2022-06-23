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

}


// MARK: - Public

extension RGUploadRequest {

  @discardableResult
  public func upload(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) throws -> UploadRequest {
    do {
      let req = try AF.upload(config: config)
      let request = req.responseJSON(
        queue: queue,
        showIndicator: showIndicator,
        showLog: config.isShowLog,
        success: success,
        failure: failure)
      return request
    } catch {
      dLog(error)
      throw error
    }
  }

  @discardableResult
  public func uploadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) throws -> UploadRequest {
  }

}
