//
//  RGNetworkRequest.swift
//  RGNetwork
//
//  Created by Rain on 2020/3/6.
//  Copyright © 2020 Smartech. All rights reserved.
//

import Foundation
import Alamofire

class RGNetworkRequest {
    
    let urlString: String
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: ParameterEncoding
    let headers: HTTPHeaders?
    let timeoutInterval: TimeInterval
    
    
    // MARK: - Lifecycle
    /// create network request
    /// - Parameters:
    ///   - urlString: string of URL path
    ///   - method: HTTP method
    ///   - parameters: request parameters
    ///   - encoding: parameter encoding
    ///   - headers: HTTP headers
    ///   - timeoutInterval: 超时时长
    init(urlString: String,
         method: HTTPMethod = .get,
         parameters: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil,
         timeoutInterval: TimeInterval = 30.0)
    {
        self.urlString          =   urlString
        self.method             =   method
        self.parameters         =   parameters
        self.encoding           =   encoding
        self.headers            =   headers
        self.timeoutInterval    =   timeoutInterval
    }
    
}


// MARK: - Public
extension RGNetworkRequest {

    /// 执行请求
    /// - Parameters:
    ///   - showIndicator: 是否显示 Indicator
    ///   - responseType: 返回数据格式类型
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    public func task(showIndicator: Bool = false,
                     responseType: ResponseType = .json,
                     success: @escaping SuccessTask,
                     failure: @escaping FailureTask)
    {
        RGNetwork.request(
            with: urlString,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            timeoutInterval: timeoutInterval,
            showIndicator: showIndicator,
            responseType: responseType,
            success: success,
            failure: failure
        )
    }
    
}
