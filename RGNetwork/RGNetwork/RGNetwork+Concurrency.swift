//
//  RGNetwork+Concurrency.swift
//  RGNetwork
//
//  Created by RAIN on 2022/4/11.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseTuple = (
    json: ResponseJSON?,
    string: ResponseString?,
    data: ResponseData?,
    error: Error?,
    httpStatusCode: HttpStatusCode?,
    request: DataRequest?,
    responsePackage: DataResponsePackage?
)

@available(iOS 13, *)
extension RGNetwork {

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

}
