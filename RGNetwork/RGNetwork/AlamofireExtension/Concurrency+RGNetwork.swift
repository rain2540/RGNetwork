//
//  Concurrency+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/4/11.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

@available(iOS 13, *)
public typealias SerializingRequestJSON = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

@available(iOS 13, *)
public typealias SerializingRequestDecodable<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Value>
)

@available(iOS 13, *)
public typealias SerializingDownloadJSON = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Data>
)

@available(iOS 13, *)
public typealias SerializingDownloadDecodable<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Value>
)


// MARK: -

@available(iOS 13, *)
extension DataRequest {

  public func serializingJSON(
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    showIndicator: Bool = false,
    showLog: Bool = true
  ) async -> SerializingRequestJSON {
    if showIndicator {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    let dataTask = serializingData(
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let responseData = await dataTask.response

    if showLog {
      dLog("RGNetwork.request.serializingJSON.debugDescription: \n\(responseData.debugDescription)")
    }

    let httpStatusCode = responseData.response?.statusCode
    guard let data = responseData.value else {
      RGNetwork.hideIndicator()
      return (nil, nil, nil, responseData.error, httpStatusCode, dataTask)
    }

    let string = String(data: data, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetwork.hideIndicator()
      return (nil, string, data, responseData.error, httpStatusCode, dataTask)
    }

    do {
      let json = try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
      ) as? ResponseJSON

      RGNetwork.hideIndicator()
      return (json, string, data, nil, httpStatusCode, dataTask)
    } catch {
      RGNetwork.hideIndicator()
      return (nil, error.localizedDescription, data, nil, httpStatusCode, dataTask)
    }
  }

  public func serializingDecodable<Value: Decodable>(
    of type: Value.Type = Value.self,
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<Value>.defaultDataPreprocessor,
    decoder: DataDecoder = JSONDecoder(),
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Value>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<Value>.defaultEmptyRequestMethods,
    showIndicator: Bool = false,
    showLog: Bool = true
  ) async -> SerializingRequestDecodable<Value> {
    if showIndicator {
      RGNetwork.showIndicator()
    }

    let dataTask = serializingDecodable(
      type,
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      decoder: decoder,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let response = await dataTask.response

    if showLog {
      dLog("RGNetwork.request.serializingDecodable.debugDescription: \n\(response.debugDescription)")
    }

    let httpStatusCode = response.response?.statusCode
    var responseData = Data()
    if let data = response.data {
      responseData = data
    }
    let string = String(data: responseData, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetwork.hideIndicator()
      return (nil, string, response.data, response.error, httpStatusCode, dataTask)
    }

    guard let value = response.value else {
      RGNetwork.hideIndicator()
      return (nil, string, response.data, nil, httpStatusCode, dataTask)
    }

    RGNetwork.hideIndicator()
    return (value, string, response.data, nil, httpStatusCode, dataTask)
  }

}


// MARK: -

@available(iOS 13, *)
extension DownloadRequest {

  public func serializingJSON(
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    showIndicator: Bool = false,
    showLog: Bool = true
  ) async -> SerializingDownloadJSON {
    if showIndicator {
      RGNetwork.showIndicator()
    }

    let downloadTask = serializingData(
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let responseData = await downloadTask.response

    if showLog {
      dLog("RGNetwork.download.serializingJSON.debugDescription: \n\(responseData.debugDescription)")
    }

    let httpStatusCode = responseData.response?.statusCode
    guard let data = responseData.value else {
      RGNetwork.hideIndicator()
      return (nil, nil, nil, nil, responseData.error, httpStatusCode, downloadTask)
    }

    let string = String(data: data, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetwork.hideIndicator()
      return (nil, string, data, nil, responseData.error, httpStatusCode, downloadTask)
    }

    do {
      let json = try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
      ) as? ResponseJSON

      RGNetwork.hideIndicator()
      return (json, string, data, responseData.fileURL, nil, httpStatusCode, downloadTask)
    } catch {
      RGNetwork.hideIndicator()
      return (nil, error.localizedDescription, data, responseData.fileURL, nil, httpStatusCode, downloadTask)
    }
  }

  public func serializingDecodable<Value: Decodable>(
    of type: Value.Type = Value.self,
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<Value>.defaultDataPreprocessor,
    decoder: DataDecoder = JSONDecoder(),
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Value>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<Value>.defaultEmptyRequestMethods,
    showIndicator: Bool = false,
    showLog: Bool = true
  ) async -> SerializingDownloadDecodable<Value> {
    if showIndicator {
      RGNetwork.showIndicator()
    }

    let downloadTask = serializingDecodable(
      type,
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      decoder: decoder,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let response = await downloadTask.response

    if showLog {
      dLog("RGNetwork.download.serializingDecodable.debugDescription: \n\(response.debugDescription)")
    }

    let httpStatusCode = response.response?.statusCode
    var resumeData = Data()
    if let data = response.resumeData {
      resumeData = data
    }
    let string = String(data: resumeData, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetwork.hideIndicator()
      return (nil, string, resumeData, nil, response.error, httpStatusCode, downloadTask)
    }

  }

}


// MARK: - Deprecated

@available(*, deprecated)
typealias ResponseTuple = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  request: DataRequest?,
  responsePackage: DataResponsePackage?
)

@available(*, deprecated)
typealias DownloadTuple = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  request: DownloadRequest?,
  responsePackage: DownloadResponsePackage?
)


// MARK: Request with Concurrency

@available(iOS 13, *)
extension RGNetwork {

  /// 通用请求方法
  /// - Parameters:
  ///   - config: 网络请求配置信息
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  /// - Returns: 请求后返回的结果
  @available(*, deprecated)
  public static func request(
    config: RGDataRequestConfig,
    showIndicator: Bool = false
  ) async -> ResponseTuple {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    let urlPath = urlPathString(by: config.urlString)

    let request = AF.request(
      urlPath,
      method: config.method,
      parameters: config.parameters,
      encoding: config.encoding,
      headers: config.headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = config.timeoutInterval
      }
    )
      .validate(statusCode: 200 ..< 300)

    let responseInfo = await RGNetwork.dataResponse(with: request, config: config)
    return responseInfo
  }

  /// 上传方法
  /// - Parameters:
  ///   - config: 上传相关配置信息
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  /// - Returns: 上传后返回的结果
  @available(*, deprecated)
  public static func upload(
    config: RGUploadConfig,
    showIndicator: Bool = false
  ) async -> ResponseTuple {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    let urlPath = urlPathString(by: config.urlString)
    let request = AF.upload(
      multipartFormData: config.multipartFormData,
      to: urlPath,
      method: config.method,
      headers: config.headers,
      requestModifier: { uploadRequest in
        uploadRequest.timeoutInterval = config.timeoutInterval
      }
    )
      .validate(statusCode: 200 ..< 300)

    let responseInfo = await RGNetwork.dataResponse(with: request, config: config)
    return responseInfo
  }

  /// 下载方法
  /// - Parameters:
  ///   - config: 下载相关配置信息
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  /// - Returns: 下载后返回的结果
  @available(*, deprecated)
  public static func download(
    config: RGDownloadConfig,
    showIndicator: Bool = false
  ) async -> DownloadTuple {
    if showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

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
      to: config.destination
    )
      .validate(statusCode: 200 ..< 300)

    let responseInfo = await RGNetwork.downloadResponse(with: request, config: config)
    return responseInfo
  }

}


// MARK: Response with Concurrency

@available(iOS 13, *)
extension RGNetwork {

  @available(*, deprecated)
  private static func dataResponse(
    with request: DataRequest,
    config: RGNetworkConfig
  ) async -> ResponseTuple {
    let dataTask = request.serializingData()
    let responseData = await dataTask.response

    if config.isShowLog {
      dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")
    }

    let httpStatusCode = responseData.response?.statusCode
    guard let data = responseData.value else {
      RGNetwork.hideIndicator()
      return (nil, nil, nil, responseData.error, httpStatusCode, request, .data(responseData))
    }
    let string = String(data: data, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetwork.hideIndicator()
      return (nil, string, data, responseData.error, httpStatusCode, request, .data(responseData))
    }
    do {
      guard let json = try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
      ) as? ResponseJSON else {
        RGNetwork.hideIndicator()
        return (nil, string, data, nil, httpStatusCode, request, .data(responseData))
      }
      RGNetwork.hideIndicator()
      return (json, string, data, nil, httpStatusCode, request, .data(responseData))
    } catch {
      RGNetwork.hideIndicator()
      return (nil, error.localizedDescription, data, nil, httpStatusCode, request, .data(responseData))
    }
  }

  @available(*, deprecated)
  private static func downloadResponse(
    with request: DownloadRequest,
    config: RGNetworkConfig
  ) async -> DownloadTuple {
    let downloadTask = request.serializingData()
    let responseData = await downloadTask.response

    if config.isShowLog {
      dLog("RGNetwork.download.debugDescription: \n\(responseData.debugDescription)")
    }

    let httpStatusCode = responseData.response?.statusCode
    guard let data = responseData.value else {
      RGNetwork.hideIndicator()
      return (nil, nil, nil, nil, responseData.error, httpStatusCode, request, .data(responseData))
    }

    let string = String(data: data, encoding: .utf8)
    let json = try? JSONSerialization.jsonObject(
      with: data,
      options: .fragmentsAllowed
    ) as? ResponseJSON

    RGNetwork.hideIndicator()
    return (json, string, data, responseData.fileURL, nil, httpStatusCode, request, .data(responseData))
  }

}
