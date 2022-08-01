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

  /// Adds a handler using a `DataResponseSerializer` to be called once the request has finished.
  /// - Deserialize to a `JSON` object.
  /// - Parameters:
  ///   - queue: The queue on which the completion handler is called. `.main` by default.
  ///   - dataPreprocessor: `DataPreprocessor` which processes the received `Data` before calling the `completionHandler`. `PassthroughPreprocessor()` by default.
  ///   - emptyResponseCodes: HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
  ///   - emptyRequestMethods: `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
  ///   - additionalConfig: Set additional config using a `RGNetAdditionalConfig`. `.init(showIndicator: false, showLog: true)` by default.
  ///   - success: A closure to be executed once the request has finished with success.
  ///   - failure: A closure to be executed once the request has finished with failure.
  /// - Returns: The request.
  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping RequestSuccess,
    failure: @escaping RequestFailure) -> Self
  {
    if additionalConfig.showIndicator == true {
      RGNetworkIndicator.show()
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
        RGNetworkIndicator.hide()
        return
      }

      let string = String(data: data, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(responseData.error, string, data, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(
          with: data,
          options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
        ) as? ResponseJSON

        success(json, string, data, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
      } catch {
        success(nil, error.localizedDescription, data, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
        return
      }
    }

    return self
  }

  /// Adds a handler using a `DecodableResponseSerializer` to be called once the request has finished.
  /// - Parameters:
  ///   - type: `Decodable` type to decode from response data.
  ///   - queue: The queue on which the completion handler is dispatched. `.main` by default.
  ///   - dataPreprocessor: `DataPreprocessor` which processes the received `Data` before calling the `completionHandler`. `PassthroughPreprocessor()` by default.
  ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
  ///   - emptyResponseCodes: HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
  ///   - emptyRequestMethods: `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
  ///   - additionalConfig: Set additional config using a `RGNetAdditionalConfig`. `.init(showIndicator: false, showLog: true)` by default.
  ///   - success: A closure to be executed once the request has finished with success.
  ///   - failure: A closure to be executed once the request has finished with failure.
  /// - Returns: The request.
  @discardableResult
  public func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
    decoder: DataDecoder = JSONDecoder(),
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping RequestDecodableSuccess<T>,
    failure: @escaping RequestDecodableFailure<T>) -> Self
  {
    if additionalConfig.showIndicator == true {
      RGNetworkIndicator.show()
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
        RGNetworkIndicator.hide()
        return
      }

      guard let value = response.value else {
        success(nil, string, response.data, httpStatusCode, self, response)
        RGNetworkIndicator.hide()
        return
      }

      success(value, string, response.data, httpStatusCode, self, response)
      RGNetworkIndicator.hide()
    }

    return self
  }

}


// MARK: -

extension DownloadRequest {

  /// Adds a handler using a `DataResponseSerializer` to be called once the request has finished.
  /// - Deserialize to a `JSON` object.
  /// - Parameters:
  ///   - queue: The queue on which the completion handler is called. `.main` by default.
  ///   - dataPreprocessor: `DataPreprocessor` which processes the received `Data` before calling the `completionHandler`. `PassthroughPreprocessor()` by default.
  ///   - emptyResponseCodes: HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
  ///   - emptyRequestMethods: `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
  ///   - additionalConfig: Set additional config using a `RGNetAdditionalConfig`. `.init(showIndicator: false, showLog: true)` by default.
  ///   - success: A closure to be executed once the request has finished with success.
  ///   - failure: A closure to be executed once the request has finished with failure.
  /// - Returns: The request.
  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping DownloadSuccess,
    failure: @escaping DownloadFailure) -> Self
  {
    if additionalConfig.showIndicator == true {
      RGNetworkIndicator.show()
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
        RGNetworkIndicator.hide()
        return
      }

      let string = String(data: data, encoding: .utf8)
      guard let code = httpStatusCode, code >= 200 && code < 300 else {
        failure(responseData.error, string, data, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(
          with: data,
          options: .fragmentsAllowed
        ) as? ResponseJSON

        success(json, string, data, responseData.fileURL, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
      } catch {
        success(nil, error.localizedDescription, data, responseData.fileURL, httpStatusCode, self, responseData)
        RGNetworkIndicator.hide()
        return
      }
    }

    return self
  }

  /// Adds a handler using a `DecodableResponseSerializer` to be called once the request has finished.
  /// - Parameters:
  ///   - type: `Decodable` type to decode from response data.
  ///   - queue: The queue on which the completion handler is dispatched. `.main` by default.
  ///   - dataPreprocessor: `DataPreprocessor` which processes the received `Data` before calling the `completionHandler`. `PassthroughPreprocessor()` by default.
  ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
  ///   - emptyResponseCodes: HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
  ///   - emptyRequestMethods: `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
  ///   - additionalConfig: Set additional config using a `RGNetAdditionalConfig`. `.init(showIndicator: false, showLog: true)` by default.
  ///   - success: A closure to be executed once the request has finished with success.
  ///   - failure: A closure to be executed once the request has finished with failure.
  /// - Returns: The request.
  @discardableResult
  public func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
    decoder: DataDecoder = JSONDecoder(),
    emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init(),
    success: @escaping DownloadDecodableSuccess<T>,
    failure: @escaping DownloadDecodableFailure<T>) -> Self
  {
    if additionalConfig.showIndicator == true {
      RGNetworkIndicator.show()
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
        RGNetworkIndicator.hide()
        return
      }

      guard let value = response.value else {
        success(nil, string, resumeData, response.fileURL, httpStatusCode, self, response)
        RGNetworkIndicator.hide()
        return
      }

      success(value, string, resumeData, response.fileURL, httpStatusCode, self, response)
      RGNetworkIndicator.hide()
    }

    return self
  }

}
