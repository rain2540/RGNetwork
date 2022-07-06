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
extension DataRequest {

  public func serializingJSON(
    automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
    dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
    emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
    emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
    additionalConfig: RGNetAdditionalConfig = .init()
  ) async -> RequestSerializeJSON {
    if additionalConfig.showIndicator {
      RGNetworkIndicator.show()
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
      RGNetworkIndicator.hide()
      return .failure((responseData.error, nil, nil, httpStatusCode, dataTask))
    }

    let string = String(data: data, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetworkIndicator.hide()
      return .failure((responseData.error, string, data, httpStatusCode, dataTask))
    }

    do {
      let json = try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
      ) as? ResponseJSON

      RGNetworkIndicator.hide()
      return .success((json, string, data, httpStatusCode, dataTask))
    } catch {
      RGNetworkIndicator.hide()
      return .success((nil, error.localizedDescription, data, httpStatusCode, dataTask))
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
  ) async -> RequestSerializeDecodable<Value> {
    if additionalConfig.showIndicator {
      RGNetworkIndicator.show()
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
      RGNetworkIndicator.hide()
      return .failure((response.error, string, response.data, httpStatusCode, dataTask))
    }

    guard let value = response.value else {
      RGNetworkIndicator.hide()
      return .success((nil, string, response.data, httpStatusCode, dataTask))
    }

    RGNetworkIndicator.hide()
    return .success((value, string, response.data, httpStatusCode, dataTask))
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
  ) async -> DownloadSerializeJSON {
    if additionalConfig.showIndicator {
      RGNetworkIndicator.show()
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
      RGNetworkIndicator.hide()
      return .failure((responseData.error, nil, nil, nil, httpStatusCode, downloadTask))
    }

    let string = String(data: data, encoding: .utf8)
    guard let code = httpStatusCode, code >= 200 && code < 300 else {
      RGNetworkIndicator.hide()
      return .failure((responseData.error, string, data, nil, httpStatusCode, downloadTask))
    }

    do {
      let json = try JSONSerialization.jsonObject(
        with: data,
        options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
      ) as? ResponseJSON

      RGNetworkIndicator.hide()
      return .success((json, string, data, responseData.fileURL, httpStatusCode, downloadTask))
    } catch {
      RGNetworkIndicator.hide()
      return .success((nil, error.localizedDescription, data, responseData.fileURL, httpStatusCode, downloadTask))
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
  ) async -> DownloadSerializeDecodable<Value> {
    if additionalConfig.showIndicator {
      RGNetworkIndicator.show()
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
      RGNetworkIndicator.hide()
      return .failure((response.error, string, resumeData, nil, httpStatusCode, downloadTask))
    }

    guard let value = response.value else {
      RGNetworkIndicator.hide()
      return .success((nil, string, resumeData, response.fileURL, httpStatusCode, downloadTask))
    }

    RGNetworkIndicator.hide()
    return .success((value, string, resumeData, response.fileURL, httpStatusCode, downloadTask))
  }

}
