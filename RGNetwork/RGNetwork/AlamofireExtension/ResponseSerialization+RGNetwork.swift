//
//  ResponseSerialization+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {

  /// 处理 `DataRequest` 响应数据
  /// - 反序列化为 `JSON` 对象
  /// - Parameters:
  ///   - queue: 执行请求的队列，默认为主队列
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - showLog: 是否显示 debug 日志，默认为 `true`
  ///   - success: 请求成功的操作
  ///   - failure: 请求失败的操作
  /// - Returns: `DataRequest` 对象
  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) -> Self {
    if additionalConfig.showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    responseData(
      queue: queue,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods
    ) { [weak self] responseData in
      guard let self = self else { return }
      if additionalConfig.showLog == true {
        dLog("RGNetwork.request.responseJSON.debugDescription: \n\(responseData.debugDescription)")
      }

      let httpStatusCode = responseData.response?.statusCode
      guard let data = responseData.value else {
        failure(responseData.error, nil, nil, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }

      let string = String(data: data, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(responseData.error, string, data, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(
          with: data,
          options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
        ) as? ResponseJSON

        success(json, string, data, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
      } catch {
        success(nil, error.localizedDescription, data, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }
    }

    return self
  }

  /// 处理 `DataRequest` 响应数据
  /// - 反序列化为满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - queue: 执行请求的队列，默认为主队列
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - showLog: 是否显示 debug 日志，默认为 `true`
  ///   - success: 请求成功的操作
  ///   - failure: 请求失败的操作
  /// - Returns: `DataRequest` 对象
  @discardableResult
  public func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
    decoder: DataDecoder = JSONDecoder(),
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) -> Self {
    if additionalConfig.showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    responseDecodable(
      of: type,
      queue: queue,
      dataPreprocessor: dataPreprocessor,
      decoder: decoder,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods
    ) { [weak self] response in
      guard let self = self else { return }
      if additionalConfig.showLog == true {
        dLog("RGNetwork.request.responseDecodable.debugDescription: \n\(response.debugDescription)")
      }

      let httpStatusCode = response.response?.statusCode
      var responseData = Data()
      if let data = response.data {
        responseData = data
      }
      let string = String(data: responseData, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(response.error, string, response.data, httpStatusCode, self, response)
        RGNetwork.hideIndicator()
        return
      }

      guard let value = response.value else {
        success(nil, string, response.data, httpStatusCode, self, response)
        RGNetwork.hideIndicator()
        return
      }

      success(value, string, response.data, httpStatusCode, self, response)
      RGNetwork.hideIndicator()
    }

    return self
  }

}


// MARK: -

extension DownloadRequest {

  /// 处理 `DownloadRequest` 响应数据
  /// - 反序列化为 `JSON` 对象
  /// - Parameters:
  ///   - queue: 执行下载的队列，默认为主队列
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - showLog: 是否显示 debug 日志，默认为 `true`
  ///   - success: 下载成功的操作
  ///   - failure: 下载失败的操作
  /// - Returns: `DownloadRequest` 对象
  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessDownload,
    failure: @escaping FailureDownload
  ) -> Self {
    if additionalConfig.showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    responseData(
      queue: queue,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods
    ) { [weak self] responseData in
      guard let self = self else { return }
      if additionalConfig.showLog == true {
        dLog("RGNetwork.download.responseJSON.debugDescription: \n\(responseData.debugDescription)")
      }

      let httpStatusCode = responseData.response?.statusCode
      guard let data = responseData.value else {
        failure(responseData.error, nil, nil, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }

      let string = String(data: data, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(responseData.error, string, data, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(
          with: data,
          options: .fragmentsAllowed
        ) as? ResponseJSON

        success(json, string, data, responseData.fileURL, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
      } catch {
        success(nil, error.localizedDescription, data, responseData.fileURL, httpStatusCode, self, responseData)
        RGNetwork.hideIndicator()
        return
      }
    }

    return self
  }

  /// 处理 `DownloadRequest` 响应数据
  /// - 反序列化为满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - queue: 执行下载的队列，默认为主队列
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - showLog: 是否显示 debug 日志，默认为 `true`
  ///   - success: 下载成功的操作
  ///   - failure: 下载失败的操作
  /// - Returns: `DownloadRequest` 对象
  @discardableResult
  public func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping SuccessDownloadDecodable<T>,
    failure: @escaping FailureDownloadDecodable<T>
  ) -> Self {
    if additionalConfig.showIndicator == true {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    responseDecodable(of: type, queue: queue) { [weak self] response in
      guard let self = self else { return }
      if additionalConfig.showLog == true {
        dLog("RGNetwork.download.responseDecodable.debugDescription: \n\(response.debugDescription)")
      }

      let httpStatusCode = response.response?.statusCode
      var resumeData = Data()
      if let data = response.resumeData {
        resumeData = data
      }
      let string = String(data: resumeData, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(response.error, string, resumeData, httpStatusCode, self, response)
        RGNetwork.hideIndicator()
        return
      }

      guard let value = response.value else {
        success(nil, string, resumeData, response.fileURL, httpStatusCode, self, response)
        RGNetwork.hideIndicator()
        return
      }

      success(value, string, resumeData, response.fileURL, httpStatusCode, self, response)
      RGNetwork.hideIndicator()
    }

    return self
  }

}
