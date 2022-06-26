//
//  RGNetwork+Concurrency.swift
//  RGNetwork
//
//  Created by RAIN on 2022/4/11.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

@available(iOS 13, *)
public typealias SerializingJSON = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  error: Error?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

typealias ResponseTuple = (
    json: ResponseJSON?,
    string: ResponseString?,
    data: ResponseData?,
    error: Error?,
    httpStatusCode: HttpStatusCode?,
    request: DataRequest?,
    responsePackage: DataResponsePackage?
)

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


@available(iOS 13, *)
extension DataRequest {

  public func serializingJSON(
    showIndicator: Bool = false,
    showLog: Bool = true
  ) async -> SerializingJSON {
    if showIndicator {
      RGNetwork.showIndicator()
      RGNetwork.showActivityIndicator()
    }

    let dataTask = serializingData()
    let responseData = await dataTask.response

    if showLog {
      dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")
    }

    let httpStatusCode = responseData.response?.statusCode
    guard let data = responseData.value else {
      RGNetwork.hideIndicator()
      return (nil, nil, nil, responseData.error, httpStatusCode, dataTask)
    }
  }

}


// MARK: - Request with Concurrency

@available(iOS 13, *)
extension RGNetwork {

    /// 通用请求方法
    /// - Parameters:
    ///   - config: 网络请求配置信息
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    /// - Returns: 请求后返回的结果
    public static func request(
        config: RGDataRequestConfig,
        showIndicator: Bool = false
    ) async -> ResponseTuple {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

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
                }
            )
                .validate(statusCode: 200 ..< 300)

            let responseInfo = await RGNetwork.dataResponse(with: request, config: config)
            return responseInfo
        } catch {
            dLog(error)
            RGNetwork.hideIndicator()
            return (nil, error.localizedDescription, nil, error, nil, nil, nil)
        }
    }

    /// 上传方法
    /// - Parameters:
    ///   - config: 上传相关配置信息
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    /// - Returns: 上传后返回的结果
    public static func upload(
        config: RGUploadConfig,
        showIndicator: Bool = false
    ) async -> ResponseTuple {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        do {
            let urlPath = try urlPathString(by: config.urlString)
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
        } catch {
            dLog(error)
            RGNetwork.hideIndicator()
            return (nil, error.localizedDescription, nil, error, nil, nil, nil)
        }
    }

    /// 下载方法
    /// - Parameters:
    ///   - config: 下载相关配置信息
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    /// - Returns: 下载后返回的结果
    public static func download(
        config: RGDownloadConfig,
        showIndicator: Bool = false
    ) async -> DownloadTuple {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        do {
            let urlPath = try urlPathString(by: config.urlString)
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
        } catch {
            dLog(error)
            RGNetwork.hideIndicator()
            return (nil, error.localizedDescription, nil, nil, error, nil, nil, nil)
        }
    }

}


// MARK: - Response with Concurrency

@available(iOS 13, *)
extension RGNetwork {

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
            return (nil, string, data, responseData.error,httpStatusCode, request, .data(responseData))
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
