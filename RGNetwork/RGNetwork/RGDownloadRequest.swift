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
    self.config = RGDownloadConfig(
      urlString: urlString,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      timeoutInterval: timeoutInterval,
      destination: destination)
  }

}


// MARK: - Public

extension RGDownloadRequest {

  @discardableResult
  public func download(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessDownload,
    failure: @escaping FailureDownload
  ) throws -> DownloadRequest {
    do {
      let req = try AF.download(config: config)
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
  public func downloadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    success: @escaping SuccessDownloadDecodable<T>,
    failure: @escaping FailureDownloadDecodable<T>
  ) throws -> DownloadRequest {
    do {
    } catch {
      dLog(error)
      throw error
    }
  }

  public func download(
    queue: DispatchQueue = DispatchQueue.global(),
    showIndicator: Bool = false,
    success: @escaping DownloadSuccess,
    failure: @escaping DownloadFailure
  ) {
    RGNetwork.download(
      config: config,
      queue: queue,
      showIndicator: showIndicator,
      success: success,
      failure: failure)
  }

}
