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
