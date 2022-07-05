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
    additionalConfig: RGNetAdditionalConfig = .init()
  ) async -> SerializingRequestJSON {
    if additionalConfig.showIndicator {
      RGNetwork.showIndicator()
      // RGNetwork.showActivityIndicator()
    }

    let dataTask = serializingData(
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let responseData = await dataTask.response

    if additionalConfig.showLog {
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
    additionalConfig: RGNetAdditionalConfig = .init()
  ) async -> SerializingRequestDecodable<Value> {
    if additionalConfig.showIndicator {
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

    if additionalConfig.showLog {
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
    additionalConfig: RGNetAdditionalConfig = .init()
  ) async -> SerializingDownloadJSON {
    if additionalConfig.showIndicator {
      RGNetwork.showIndicator()
    }

    let downloadTask = serializingData(
      automaticallyCancelling: shouldAutomaticallyCancel,
      dataPreprocessor: dataPreprocessor,
      emptyResponseCodes: emptyResponseCodes,
      emptyRequestMethods: emptyRequestMethods)

    let responseData = await downloadTask.response

    if additionalConfig.showLog {
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
    additionalConfig: RGNetAdditionalConfig = .init()
  ) async -> SerializingDownloadDecodable<Value> {
    if additionalConfig.showIndicator {
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

    if additionalConfig.showLog {
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

    guard let value = response.value else {
      RGNetwork.hideIndicator()
      return (nil, string, resumeData, response.fileURL, nil, httpStatusCode, downloadTask)
    }

    RGNetwork.hideIndicator()
    return (value, string, resumeData, response.fileURL, nil, httpStatusCode, downloadTask)
  }

}
