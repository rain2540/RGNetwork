//
//  RGNetwork+Decodable.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/1.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

typealias DecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
typealias DecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

typealias DownloadDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
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
      RGNetwork.showActivityIndicator()
    }

    queue.async {
      do {
        let urlPath = try urlPathString(by: config.urlString)

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
      } catch {
        dLog(error)
        RGNetwork.hideIndicator()
      }
    }
  }


  // MARK: - UploadRequest

  /// 上传方法，用于获取满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - config: 上传相关配置信息
  ///   - queue: 执行上传的队列，默认为 `DispatchQueue.global()`
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - success: 上传成功的 Task
  ///   - failure: 上传失败的 Task
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
      RGNetwork.showActivityIndicator()
    }

    queue.async {
      do {
        let urlPath = try urlPathString(by: config.urlString)

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
      } catch {
        dLog(error)
        RGNetwork.hideIndicator()
      }
    }
  }


// MARK: - Response of DataRequest / UploadRequest

extension RGNetwork {

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

}
