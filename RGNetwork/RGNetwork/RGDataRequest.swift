//
//  RGDataRequest.swift
//  RGNetwork
//
//  Created by Rain on 2020/3/6.
//  Copyright © 2020 Smartech. All rights reserved.
//

import Foundation
import Alamofire

class RGDataRequest {

    public var tag: Int = 0

    public private(set) var config: RGDataRequestConfig


    // MARK: - Lifecycle

    /// create network request
    /// - Parameters:
    ///   - urlString: string of URL path
    ///   - method: HTTP method
    ///   - parameters: request parameters
    ///   - encoding: parameter encoding
    ///   - headers: HTTP headers
    ///   - timeoutInterval: 超时时长
    init(
        urlString: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        isShowLog: Bool = true
    ) {
        self.config = RGDataRequestConfig(
            urlString: urlString,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            timeoutInterval: timeoutInterval,
            isShowLog: isShowLog
        )
    }

}


// MARK: - Public

extension RGDataRequest {

    /// 执行请求
    /// - Parameters:
    ///   - queue: 执行请求的队列
    ///   - showIndicator: 是否显示 Indicator
    ///   - responseType: 返回数据格式类型
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    public func task(
        queue: DispatchQueue = DispatchQueue.global(),
        showIndicator: Bool = false,
        responseType: ResponseType = .json,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        RGNetwork.request(
            config: config,
            queue: queue,
            showIndicator: showIndicator,
            responseType: responseType,
            success: success,
            failure: failure
        )
    }

}
