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
