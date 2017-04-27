//
//  RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2016/11/15.
//  Copyright © 2016年 Smartech. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD

typealias SuccessClosure = ([String: Any], String, String, String) -> Void
typealias FailCloure = (Error?, String) -> Void

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

    //  MARK: Public Methods
    /// GET 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showProgress: 是否显示 Progress
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func get(
        with urlString: String,
        parameters: [String: Any]?,
        showProgress: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .get,
                          parameters: parameters,
                          showProgress: showProgress,
                          success: success,
                          fail: fail)
    }

    /// POST 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showProgress: 是否显示 Progress
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func post(
        with urlString: String,
        parameters: [String: Any]?,
        showProgress: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .post,
                          parameters: parameters,
                          showProgress: showProgress,
                          success: success,
                          fail: fail)
    }

    /// PUT 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showProgress: 是否显示 Progress
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func put(
        with urlString: String,
        parameters: [String: Any]?,
        showProgress: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        RGNetwork.request(with: urlString,
                          method: .put,
                          parameters: parameters,
                          showProgress: showProgress,
                          success: success,
                          fail: fail)
    }

    /// DELETE 请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - showProgress: 是否显示 Progress
    ///   - success: 请求成功的 Task
    ///   - fail: 请求失败的 Task
    public static func delete(
        with urlString: String,
        parameters: [String: Any]?,
        showProgress: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        let network = RGNetwork.shared
        if network.reachabilityManager?.networkReachabilityStatus == .notReachable {
            RGToast.shared.toast(message: "当前无网络")
        } else {
            if showProgress == true {
                RGNetwork.showProgress()
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
                    guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else {
                        print("RGNetwork delete request get JSON string failed.")
                        RGNetwork.hideProgress()
                        return
                    }
                    RGNetwork.hideProgress()
                    success(json, requestString, jsonString, "\(httpStatusCode)")
                } catch let error as NSError {
                    RGNetwork.hideProgress()
                    fail(error, requestString)
                }
            } catch let error as NSError {
                RGNetwork.hideProgress()
                fail(error, requestString)
            }
        }
    }

    //  MARK: Private Methods
    //  Request
    fileprivate static func request(
        with urlString: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        showProgress: Bool,
        success: @escaping SuccessClosure,
        fail: @escaping FailCloure)
    {
        let network = RGNetwork.shared
        if network.reachabilityManager?.networkReachabilityStatus == .notReachable {
            RGToast.shared.toast(message: "当前无网络")
        } else {
            if showProgress == true {
                RGNetwork.showProgress()
            }

            let requestString = RGNetwork.requestURL(urlString, parameters: parameters)
            Alamofire
                .request(urlString, method: method, parameters: parameters)
                .responseJSON { (response) in
                    print("RGNetwork \(method.rawValue) request debugDescription: \n", response.debugDescription)
                    let httpStatusCode = response.response?.statusCode
                    let data = response.data
                    let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                    if let result = response.result.value {
                        success(result as! [String : Any], requestString, jsonString!, "\(httpStatusCode!)")
                        RGNetwork.hideProgress()
                    } else {
                        fail(response.result.error, requestString)
                        RGNetwork.hideProgress()
                        RGToast.shared.toast(message: "网络访问失败")
                    }
            }
        }
    }

    //  Request String Log
    fileprivate static func requestURL(_ urlString: String, parameters: [String: Any]?) -> String {
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

    //  Progress View
    fileprivate static func showProgress() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }

    fileprivate static func hideProgress() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss(withDelay: 0.5)
        }
    }
}
