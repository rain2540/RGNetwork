//
//  RGNetwork+Decodable.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/1.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Deprecated

@available(*, deprecated)
typealias DecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
@available(*, deprecated)
typealias DecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

@available(*, deprecated)
typealias DownloadDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
@available(*, deprecated)
typealias DownloadDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void


extension RGNetwork {

  // MARK: DataRequest

  /// 通用请求方法，用于获取满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - config: 网络请求配置信息
  ///   - queue: 执行请求的队列，默认为 `DispatchQueue.global()`
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - success: 请求成功的 Task
  ///   - failure: 请求失败的 Task
  @available(*, deprecated)
  public static func requestDecodable<T: Decodable>(
    of type: T.Type = T.self,
    config: RGDataRequestConfig,
    queue: DispatchQueue = DispatchQueue.global(),
    showIndicator: Bool = false,
    success: @escaping DecodableSuccess<T>,
    failure: @escaping DecodableFailure<T>
  ) {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    queue.async {
      let urlPath = urlPathString(by: config.urlString)

      let request = AF.request(
        urlPath,
        method: config.method,
        parameters: config.parameters,
        encoding: config.encoding,
        headers: config.headers,
        requestModifier: { urlRequest in
          urlRequest.timeoutInterval = config.timeoutInterval
        })
        .validate(statusCode: 200 ..< 300)

      RGNetwork.responseDecodable(of: type, with: request, config: config, success: success, failure: failure)
    }
  }


  // MARK: UploadRequest

  /// 上传方法，用于获取满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - config: 上传相关配置信息
  ///   - queue: 执行上传的队列，默认为 `DispatchQueue.global()`
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - success: 上传成功的 Task
  ///   - failure: 上传失败的 Task
  @available(*, deprecated)
  public static func uploadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    config: RGUploadConfig,
    queue: DispatchQueue = .global(),
    showIndicator: Bool = false,
    success: @escaping DecodableSuccess<T>,
    failure: @escaping DecodableFailure<T>
  ) {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    queue.async {
      let urlPath = urlPathString(by: config.urlString)

      let request = AF.upload(
        multipartFormData: config.multipartFormData,
        to: urlPath,
        method: config.method,
        headers: config.headers,
        requestModifier: { uploadRequest in
          uploadRequest.timeoutInterval = config.timeoutInterval
        })
        .validate(statusCode: 200 ..< 300)

      RGNetwork.responseDecodable(of: type, with: request, config: config, success: success, failure: failure)
    }
  }


  // MARK: DownloadRequest

  /// 下载方法，用于获取满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - config: 下载相关配置信息
  ///   - queue: 执行下载的队列，默认为 `DispatchQueue.global()`
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - success: 下载成功的 Task
  ///   - failure: 下载失败的 Task
  @available(*, deprecated)
  public static func downloadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    config: RGDownloadConfig,
    queue: DispatchQueue = DispatchQueue.global(),
    showIndicator: Bool = false,
    success: @escaping DownloadDecodableSuccess<T>,
    failure: @escaping DownloadDecodableFailure<T>
  ) {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    queue.async {
      let urlPath = urlPathString(by: config.urlString)

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
        .validate(statusCode: 200 ..< 300)

      RGNetwork.responseDownloadDecodable(of: type, with: request, config: config, success: success, failure: failure)
    }
  }

}


// MARK: Response of DataRequest / UploadRequest

extension RGNetwork {

  @available(*, deprecated)
  private static func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    with request: DataRequest,
    config: RGNetworkConfig,
    success: @escaping DecodableSuccess<T>,
    failure: @escaping DecodableFailure<T>
  ) {
    request.responseDecodable(of: type) { response in
      if config.isShowLog == true {
        dLog("RGNetwork.request.debugDescription: \n\(response.debugDescription)")
      }

      let httpStatusCode = response.response?.statusCode
      var responseData = Data()
      if let data = response.data {
        responseData = data
      }
      let string = String(data: responseData, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(response.error, string, response.data, httpStatusCode, request, response)
        RGNetwork.hideIndicator()
        return
      }

      guard let value = response.value else {
        success(nil, string, response.data, httpStatusCode, request, response)
        RGNetwork.hideIndicator()
        return
      }

      success(value, string, response.data, httpStatusCode, request, response)
      RGNetwork.hideIndicator()
    }
  }

}


// MARK: Response of DownloadRequest

extension RGNetwork {

  @available(*, deprecated)
  private static func responseDownloadDecodable<T: Decodable>(
    of type: T.Type = T.self,
    with request: DownloadRequest,
    config: RGNetworkConfig,
    success: @escaping DownloadDecodableSuccess<T>,
    failure: @escaping DownloadDecodableFailure<T>
  ) {
    request.responseDecodable(of: type) { response in
      if config.isShowLog {
        dLog("RGNetwork.download.debugDescription: \n\(response.debugDescription)")
      }

      let httpStatusCode = response.response?.statusCode
      var resumeData = Data()
      if let data = response.resumeData {
        resumeData = data
      }
      let string = String(data: resumeData, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(response.error, string, resumeData, httpStatusCode, request, response)
        RGNetwork.hideIndicator()
        return
      }

      guard let value = response.value else {
        success(nil, string, resumeData, response.fileURL, httpStatusCode, request, response)
        RGNetwork.hideIndicator()
        return
      }

      success(value, string, resumeData, response.fileURL, httpStatusCode, request, response)
      RGNetwork.hideIndicator()
    }
  }

}
