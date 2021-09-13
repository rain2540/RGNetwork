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


enum ResponseType {
    case json, string, data
}


enum DataResponsePackage {
    case json(DataResponse<Any, AFError>)
    case string(DataResponse<String, AFError>)
    case data(DataResponse<Data, AFError>)
}


typealias ResponseJSON = [String: Any]
typealias ResponseString = String
typealias ResponseData = Data
typealias HttpStatusCode = Int

typealias SuccessTask = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void
typealias FailureTask = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void
@available(*, deprecated, renamed: "FailureTask")
typealias FailTask = (Error?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void


struct RGNetwork { }


//  MARK: - Public Methods

extension RGNetwork {

    public static func request(
        config: RGDataRequestConfig,
        queue: DispatchQueue = DispatchQueue.global(),
        showIndicator: Bool = false,
        responseType: ResponseType = .json,
        success: @escaping SuccessTask,
        failure: @escaping FailTask
    ) {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        queue.async {
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
                RGNetwork.hideIndicator()
            }
        }
    }

    public static func upload(
        config: RGUploadConfig,
        queue: DispatchQueue = DispatchQueue.global(),
        showIndicator: Bool = false,
        responseType: ResponseType = .json,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        queue.async {
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
                RGNetwork.hideIndicator()
            }
        }
    }

}


// MARK: - Response of DataRequest / UploadRequest

extension RGNetwork {

    private static func responseJSON(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        request.responseJSON { (responseJSON) in
            print("RGNetwork.request.debugDescription: \n\(responseJSON.debugDescription)")

            let httpStatusCode = responseJSON.response?.statusCode
            var responseData = Data()
            if let data = responseJSON.data {
                responseData = data
            }
            let string = String(data: responseData, encoding: .utf8)
            guard let code = httpStatusCode, code >= 200 && code < 300 else {
                failure(responseJSON.error, string, responseJSON.data, httpStatusCode, request, .json(responseJSON))
                RGNetwork.hideIndicator()
                return
            }

            guard let json = responseJSON.value as? ResponseJSON else {
                success(nil, string, responseJSON.data, httpStatusCode, request, .json(responseJSON))
                RGNetwork.hideIndicator()
                return
            }

            success(json, string, responseJSON.data, httpStatusCode, request, .json(responseJSON))
            RGNetwork.hideIndicator()
        }
    }

    private static func responseString(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        request.responseString { (responseString) in
            print("RGNetwork.request.debugDescription: \n\(responseString.debugDescription)")

            let httpStatusCode = responseString.response?.statusCode
            var responseData = Data()
            if let data = responseString.data {
                responseData = data
            }
            let string = String(data: responseData, encoding: .utf8)
            guard let code = httpStatusCode, code >= 200 && code < 300 else {
                failure(responseString.error, string, responseString.data, httpStatusCode, request, .string(responseString))
                RGNetwork.hideIndicator()
                return
            }

            guard let resString = responseString.value else {
                success(nil, nil, responseString.data, httpStatusCode, request, .string(responseString))
                RGNetwork.hideIndicator()
                return
            }

            success(nil, resString, responseString.data, httpStatusCode, request, .string(responseString))
            RGNetwork.hideIndicator()
        }
    }

    private static func responseData(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        request.responseData { (responseData) in
            print("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")

            let httpStatusCode = responseData.response?.statusCode
            guard let data = responseData.value else {
                failure(responseData.error, nil, nil, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }
            let string = String(data: data, encoding: .utf8)

            success(nil, string, data, httpStatusCode, request, .data(responseData))
            RGNetwork.hideIndicator()
        }
    }

}


// MARK: - URL Path Handle

extension RGNetwork {

    private static func urlPathString(by urlString: String) throws -> String {
        if urlString.rg_hasHttpPrefix {
            let fixURLString = urlString
                .replacingOccurrences(of: "//", with: "/")
                .replacingOccurrences(of: ":/", with: "://")
            return fixURLString
        } else if let host = RGNetworkPreset.shared.baseURL, host.rg_hasHttpPrefix {
            if host.hasSuffix("/") && urlString.hasPrefix("/") {
                var fixHost = host
                fixHost.rg_removeLast(ifHas: "/")
                return fixHost + urlString
            } else if host.hasSuffix("/") == false && urlString.hasPrefix("/") == false {
                return host + "/" + urlString
            } else {
                return host + urlString
            }
        } else {
            throw RGNetworkError.wrongURLFormat
        }
    }

}


// MARK: - Indicator View

extension RGNetwork {

    /// 在 Status Bar 上显示 Activity Indicator
    /// - Parameters:
    ///   - startDelay: 开始延迟时间
    ///   - completionDelay: 结束延迟时间
    public static func showActivityIndicator(
        startDelay: TimeInterval = 0.0,
        completionDelay: TimeInterval = 0.7
    ) {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = startDelay
        NetworkActivityIndicatorManager.shared.completionDelay = completionDelay
    }

    /// 显示 indicator
    /// - Parameters:
    ///   - mode: 显示模式，默认为 .indeterminate
    ///   - text: 显示的文字，默认为空
    private static func showIndicator(
        mode: MBProgressHUDMode = .indeterminate,
        text: String = ""
    ) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.mode = mode
            hud.label.text = text
        }
    }

    /// 隐藏 indicator
    private static func hideIndicator() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            MBProgressHUD.hide(for: window, animated: true)
        }
    }

}


// MARK: - Proxy

extension RGNetwork {

    /// 是否设置网络代理
    public static var isSetupProxy: Bool {
        if proxyType == kCFProxyTypeNone {
            #if DEBUG
            print("当前未设置网络代理")
            #endif
            return false
        } else {
            #if DEBUG
            print("当前设置了网络代理")
            #endif
            return true
        }
    }

    /// 网络代理主机名
    public static var proxyHostName: String {
        let hostName = proxyInfos.object(forKey: kCFProxyHostNameKey) as? String ?? "Proxy Host Name is nil"
        #if DEBUG
        print("Proxy Host Name: \(hostName)")
        #endif
        return hostName
    }

    /// 网络代理端口号
    public static var proxyPortNumber: String {
        let portNumber = proxyInfos.object(forKey: kCFProxyPortNumberKey) as? String ?? "Proxy Port Number is nil"
        #if DEBUG
        print("Proxy Port Number: \(portNumber)")
        #endif
        return portNumber
    }

    /// 网络代理类型
    public static var proxyType: CFString {
        let type = proxyInfos.object(forKey: kCFProxyTypeKey) ?? kCFProxyTypeNone
        #if DEBUG
        print("Proxy Type: \(type)")
        #endif
        return type
    }

    /// 网络代理信息
    private static var proxyInfos: AnyObject {
        let proxySetting = CFNetworkCopySystemProxySettings()!.takeUnretainedValue()
        let url = URL(string: "https://www.baidu.com")!
        let proxyArray = CFNetworkCopyProxiesForURL(url as CFURL, proxySetting).takeUnretainedValue()

        let proxyInfo = (proxyArray as [AnyObject])[0]
        return proxyInfo
    }

}


// MARK: - VPN

extension RGNetwork {

    /// 是否开启 VPN
    public static var isVPNOn: Bool {
        var flag = false
        let proxySetting = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [AnyHashable: Any] ?? [:]
        let keys = (proxySetting["__SCOPED__"] as? NSDictionary)?.allKeys as? [String] ?? []

        for key in keys {
            let checkStrings = ["tap", "tun", "ipsec", "ppp"]
            let condition = checkStrings.contains(key)

            if condition {
                #if DEBUG
                print("当前开启了 VPN")
                #endif
                flag = true
                break
            }
        }
        #if DEBUG
        if flag == false {
            print("当前未开启 VPN")
        }
        #endif
        return flag
    }

}


// MARK: - String Extension

fileprivate extension String {

    /// 是否含有 http / https 前缀
    var rg_hasHttpPrefix: Bool {
        return self.hasPrefix("http://") || self.hasPrefix("https://")
    }

    /// 如果含有某个后缀，则删除
    /// - Parameter suffix: 需要删除的后缀
    mutating func rg_removeLast(ifHas suffix: String) {
        if hasSuffix(suffix) {
            removeLast()
        }
    }

}


// MARK: - Deprecated

extension RGNetwork {

    /// 通用请求方法
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - method: 请求方法，默认为 `GET`
    ///   - parameters: 请求参数，默认为 `nil`
    ///   - encoding: 请求参数编码，默认为 `URLEncoding.default`
    ///   - headers: 请求头，默认为 `nil`
    ///   - timeoutInterval: 超时时长，默认为 30 秒
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    ///   - responseType: 返回数据格式类型，默认为 `.json`
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    @available(*, deprecated, renamed: "request(config:queue:showIndicator:responseType:success:failure:)")
    public static func request(
        with urlString: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        showIndicator: Bool = false,
        responseType: ResponseType = .json,
        success: @escaping SuccessTask,
        failure: @escaping FailTask
    ) {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        DispatchQueue.global().async {
            do {
                let urlPath = try urlPathString(by: urlString)

                let request = AF.request(
                    urlPath,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: headers,
                    requestModifier: { urlRequest in
                        urlRequest.timeoutInterval = timeoutInterval
                    }
                )
                .validate(statusCode: 200 ..< 300)

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
                RGNetwork.hideIndicator()
            }
        }
    }

}
