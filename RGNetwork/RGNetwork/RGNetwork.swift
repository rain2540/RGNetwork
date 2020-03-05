//
//  RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2016/11/15.
//  Copyright © 2016年 Smartech. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator
import MBProgressHUD

typealias ResponseJSON = [String: Any]
typealias ResponseString = String
typealias ResponseData = Data
typealias HttpStatusCode = Int

enum DataResponsePackage {
    case json(DataResponse<Any, AFError>)
    case string(DataResponse<String, AFError>)
    case data(DataResponse<Data, AFError>)
}

typealias SuccessTask = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void
typealias FailureTask = (Error?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void

enum ResponseType {
    case json, string, data
}


struct RGNetwork {

    //  MARK: Public Methods
    /// 通用请求方法
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - method: 请求方法
    ///   - parameters: 请求参数
    ///   - encoding: 请求参数编码
    ///   - headers: 请求头
    ///   - showIndicator: 是否显示 Indicator
    ///   - responseType: 返回数据格式类型
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    public static func request(
        with urlString: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        showIndicator: Bool = false,
        responseType: ResponseType = .json,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask)
    {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        DispatchQueue.global().async {
            do {
                let urlPath = try urlPathString(by: urlString)
                let request = AF.request(urlPath, method: method, parameters: parameters, encoding: encoding, headers: headers)

                switch responseType {
                    case .json:
                        RGNetwork.responseJSON(with: request, success: success, failure: failure)

                    case .string:
                        RGNetwork.responseString(with: request, success: success, failure: failure)

                    case .data:
                        RGNetwork.responseData(with: request, success: success, failure: failure)
                }
            } catch {
                print(error)
            }
        }
    }


    //  MARK: - Private Methods
    private static func responseJSON(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask)
    {
        request.responseJSON { (responseJSON) in
            print("RGNetwork request debugDescription: \n", responseJSON.debugDescription, separator: "")

            let httpStatusCode = responseJSON.response?.statusCode
            guard let json = responseJSON.value else {
                failure(responseJSON.error, httpStatusCode, request, .json(responseJSON))
                RGNetwork.hideIndicator()
                return
            }
            var responseData = Data()
            if let data = responseJSON.data {
                responseData = data
            }
            let string = String(data: responseData, encoding: .utf8)

            success(json as? [String : Any], string, responseJSON.data, httpStatusCode, request, .json(responseJSON))
            RGNetwork.hideIndicator()
        }
    }

    private static func responseString(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask)
    {
        request.responseString { (responseString) in
            print("RGNetwork request debugDescription: \n", responseString.debugDescription, separator: "")

            let httpStatusCode = responseString.response?.statusCode
            guard let string = responseString.value else {
                failure(responseString.error, httpStatusCode, request, .string(responseString))
                RGNetwork.hideIndicator()
                return
            }

            success(nil, string, responseString.data, httpStatusCode, request, .string(responseString))
            RGNetwork.hideIndicator()
        }
    }

    private static func responseData(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask)
    {
        request.responseData { (responseData) in
            print("RGNetwork request debugDescription: \n", responseData.debugDescription, separator: "")

            let httpStatusCode = responseData.response?.statusCode
            guard let data = responseData.value else {
                failure(responseData.error, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }
            let string = String(data: data, encoding: .utf8)

            success(nil, string, data, httpStatusCode, request, .data(responseData))
            RGNetwork.hideIndicator()
        }
    }

    private static func urlPathString(by urlString: String) throws -> String {
        if let host = RGNetworkConfig.shared.baseURL, host.hasHttpPrefix {
            return host + urlString
        } else if urlString.hasHttpPrefix {
            return urlString
        } else {
            throw RGNetworkError.wrongURLFormat
        }
    }

}


// MARK: - Indicator View
extension RGNetwork {
    /// 在 Status Bar 上显示 Activity Indicator
    ///
    /// - Parameters:
    ///   - startDelay: 开始延迟时间
    ///   - completionDelay: 结束延迟时间
    public static func showActivityIndicator(startDelay: TimeInterval = 0.0,
                                             completionDelay: TimeInterval = 0.7)
    {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = startDelay
        NetworkActivityIndicatorManager.shared.completionDelay = completionDelay
    }

    private static func showIndicator(mode: MBProgressHUDMode = .indeterminate,
                                      text: String = "")
    {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.mode = mode
            hud.label.text = text
        }
    }
    
    private static func hideIndicator() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            MBProgressHUD.hide(for: window, animated: true)
        }
    }
}


// MARK: - String Extension
fileprivate extension String {

    var hasHttpPrefix: Bool {
        return self.hasPrefix("http://") || self.hasPrefix("https://")
    }

}
