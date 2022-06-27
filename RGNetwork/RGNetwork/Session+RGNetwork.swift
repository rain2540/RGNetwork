//
//  Session+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension Session {

  /// 构建 Data Request
  /// - Parameter config: Data Request 配置信息
  /// - Returns: Data Request 对象
  public func request(config: RGDataRequestConfig) -> DataRequest {
    let urlPath = RGNetwork.urlPathString(by: config.urlString)
    let request = request(
      urlPath,
      method: config.method,
      parameters: config.parameters,
      encoding: config.encoding,
      headers: config.headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = config.timeoutInterval
      })
    return request
  }

  /// 构建 Upload Request
  /// - Parameter config: Upload Request 配置信息
  /// - Returns: Upload Request 对象
  public func upload(config: RGUploadConfig) -> UploadRequest {
    let urlPath = RGNetwork.urlPathString(by: config.urlString)
    let request = AF.upload(
      multipartFormData: config.multipartFormData,
      to: urlPath,
      method: config.method,
      headers: config.headers,
      requestModifier: { uploadRequest in
        uploadRequest.timeoutInterval = config.timeoutInterval
      })
    return request
  }

  /// 构建 Download Request
  /// - Parameter config: Download Request 配置信息
  /// - Returns: Download Request 对象
  public func download(config: RGDownloadConfig) -> DownloadRequest {
    let urlPath = RGNetwork.urlPathString(by: config.urlString)
    let request = AF.download(
      urlPath,
      method: config.method,
      parameters: config.parameters,
      encoding: config.encoding,
      headers: config.headers,
      requestModifier: { downloadRequest in
        downloadRequest.timeoutInterval = config.timeoutInterval
      },
      to: config.destination)
    return request
  }

}
