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
    case json(DataResponse<Any>)
    case string(DataResponse<String>)
    case data(DataResponse<Data>)
}

typealias SuccessTask = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void
typealias FailureTask = (Error?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void

enum ResponseType {
    case json, string, data
}


struct RGNetwork {
    //  MARK: Initializations
    static let shared = RGNetwork()

    var reachabilityManager: NetworkReachabilityManager?

    private init() {
        self.reachabilityManager = NetworkReachabilityManager()
        self.reachabilityManager?.listener = { status in
            switch status {
            case .unknown:
                print("============ 未知网络 ============")

            case .notReachable:
                print("============ 没有网络(断网) ============")

            case .reachable(.wwan):
                print("============ 手机自带网络 ============")

            case .reachable(.ethernetOrWiFi):
                print("============ WIFI ============")
            }
        }
        self.reachabilityManager?.startListening()
    }


    //  MARK: - Public Methods
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
            let request = Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers)

            switch responseType {
            case .json:
                RGNetwork.responseJSON(with: request, success: success, failure: failure)

            case .string:
                RGNetwork.responseString(with: request, success: success, failure: failure)

            case .data:
                RGNetwork.responseData(with: request, success: success, failure: failure)
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

    /*
    private static func debugDescription<T>(with response: DataResponse<T>) -> String {
        var output: [String] = []

        output.append(response.request != nil ? "[Request]: \(response.request!.httpMethod ?? "GET") \(response.request!)" : "[Request]: nil")
        if let httpBody = response.request?.httpBody,
            let parameters = String(data: httpBody, encoding: .utf8) {
            output.append("[Parameters]: \n\(parameters)")
        }
        output.append("[Parameters]: nil")
        output.append(response.response != nil ? "[Response]: \(response.response!)" : "[Response]: nil")
        output.append("[Data]: \(response.data?.count ?? 0) bytes")
        output.append("[Result]: \(response.result.debugDescription)")
        output.append("[Timeline]: \(response.timeline.debugDescription)")

        return output.joined(separator: "\n")
    }
    */
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


//  MARK: - Deprecated
typealias SuccessClosure = ([String: Any], String, String, String) -> Void
typealias FailCloure = (Error?, String) -> Void

extension RGNetwork {
    //  MARK: ===== ===== Public Methods ===== =====
    /// GET 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showIndicator: 是否显示 Indicator
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    @available(*, deprecated, message: "Use 'request(with:,method:,parameters:,encoding:,headers:,showIndicator:,responseType:,success:,failure:)' instead", renamed: "request(with:method:parameters:encoding:headers:showIndicator:responseType:success:failure:)")
    /*
     @available(iOS, introduced: 7.0, deprecated: 11.0, message: "Use view.safeAreaLayoutGuide.topAnchor instead of topLayoutGuide.bottomAnchor")
     */
    public static func get(
        with urlString: String,
        parameters: Parameters?,
        showIndicator: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .get,
                          parameters: parameters,
                          showIndicator: showIndicator,
                          success: success,
                          fail: fail)
    }

    /// POST 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showIndicator: 是否显示 Indicator
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func post(
        with urlString: String,
        parameters: Parameters?,
        showIndicator: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .post,
                          parameters: parameters,
                          showIndicator: showIndicator,
                          success: success,
                          fail: fail)
    }

    /// PUT 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showIndicator: 是否显示 Indicator
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func put(
        with urlString: String,
        parameters: Parameters?,
        showIndicator: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .put,
                          parameters: parameters,
                          showIndicator: showIndicator,
                          success: success,
                          fail: fail)
    }

    /// DELETE 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showIndicator: 是否显示 Indicator
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func delete(
        with urlString: String,
        parameters: Parameters?,
        showIndicator: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        let network = RGNetwork.shared
        if network.reachabilityManager?.networkReachabilityStatus == .notReachable {
            RGToast.shared.toast(message: "当前无网络")
        } else {
            if showIndicator == true {
                RGNetwork.showIndicator()
            }
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.timeoutInterval = 15.0
            request.httpMethod = "DELETE"
            do {
                request = try URLEncoding(destination: .httpBody).encode(request, with: parameters)
            } catch let error as NSError {
                print("RGNetwork delete request parameters encoding error: \n", error)
            }
            let requestString = RGNetwork.requestURL(urlString, parameters: parameters)
            do {
                var response: URLResponse?
                let data = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
                let httpStatusCode = (response as! HTTPURLResponse).statusCode
                do {
                    let json =
                        try JSONSerialization
                            .jsonObject(with: data,
                                        options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    guard let jsonString = String(data: data, encoding: .utf8) else {
                        print("RGNetwork delete request get JSON string failed.")
                        RGNetwork.hideIndicator()
                        return
                    }
                    success(json, requestString, jsonString, "\(httpStatusCode)")
                    RGNetwork.hideIndicator()
                } catch let error as NSError {
                    fail(error, requestString)
                    RGNetwork.hideIndicator()
                }
            } catch let error as NSError {
                fail(error, requestString)
                RGNetwork.hideIndicator()
            }
        }
    }


    // MARK: ===== ===== Private Methods ===== =====
    // Request
    private static func request(
        with urlString: String,
        method: HTTPMethod,
        parameters: Parameters?,
        showIndicator: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        let network = RGNetwork.shared
        if network.reachabilityManager?.networkReachabilityStatus == .notReachable {
            RGToast.shared.toast(message: "当前无网络")
        } else {
            if showIndicator == true {
                RGNetwork.showIndicator()
            }

            let requestString = RGNetwork.requestURL(urlString, parameters: parameters)
            Alamofire
                .request(urlString, method: method, parameters: parameters)
                .responseString(completionHandler: { (response) in
                    print("RGNetwork \(method.rawValue) request debugDescription: \n", response.debugDescription)
                    let httpStatusCode = response.response?.statusCode
                    guard let data = response.data else { return }
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                        fail(response.error, requestString)
                        print("String in fact:\n", response.value!)
                        DispatchQueue.main.async {
                            RGToast.shared.toast(message: "网络访问失败")
                            RGNetwork.hideIndicator()
                        }
                        return
                    }
                    success(json, requestString, response.value!, "\(httpStatusCode!)")
                    DispatchQueue.main.async {
                        RGNetwork.hideIndicator()
                    }
                })
        }
    }

    // Request String Log
    private static func requestURL(_ urlString: String, parameters: [String: Any]?) -> String {
        if parameters?.keys.count == 0 && parameters == nil {
            return urlString
        } else {
            guard let keys = parameters?.keys else {
                return urlString
            }
            var requestString = urlString
            requestString.append("?")
            for key in keys {
                if let dic = parameters {
                    var value: String
                    if let stringValue = dic[key] as? String {
                        value = stringValue
                    } else {
                        value = "\(dic[key]!)"
                    }
                    requestString = requestString.appendingFormat("%@=%@&", key, value)
                } else {
                    return urlString
                }
            }
            requestString.remove(at: requestString.index(before: requestString.endIndex))
            return requestString
        }
    }
}
