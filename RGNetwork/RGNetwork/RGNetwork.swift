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

enum DownloadResponsePackage {
    case json(DownloadResponse<Any, AFError>)
    case string(DownloadResponse<String, AFError>)
    case data(DownloadResponse<Data, AFError>)
}


typealias ResponseJSON = [String: Any]
typealias ResponseString = String
typealias ResponseData = Data
typealias HttpStatusCode = Int

typealias SuccessTask = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void
typealias FailureTask = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponsePackage) -> Void

typealias DecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
typealias DecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

typealias DownloadSuccess = (ResponseJSON?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponsePackage) -> Void
typealias DownloadFailure = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponsePackage) -> Void


struct RGNetwork { }


//  MARK: - Public Methods

extension RGNetwork {

    // MARK: DataRequest

    /// 通用请求方法
    /// - Parameters:
    ///   - config: 网络请求配置信息
    ///   - queue: 执行请求的队列，默认为 `DispatchQueue.global()`
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    ///   - responseType: 返回数据格式类型，默认为 `.json`
    ///   - success: 请求成功的 Task
    ///   - failure: 请求失败的 Task
    public static func request(
        config: RGDataRequestConfig,
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
                    RGNetwork.responseJSON(with: request, config: config, success: success, failure: failure)

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


    // MARK: - UploadRequest

    /// 上传方法
    /// - Parameters:
    ///   - config: 上传相关配置信息
    ///   - queue: 执行上传的队列，默认为 `DispatchQueue.global()`
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    ///   - responseType: 返回数据格式类型，默认为 `.json`
    ///   - success: 上传成功的 Task
    ///   - failure: 上传失败的 Task
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
                    RGNetwork.responseJSON(with: request, config: config, success: success, failure: failure)

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


    // MARK: - DownloadRequest

    /// 下载方法
    /// - Parameters:
    ///   - config: 下载相关配置信息
    ///   - queue: 执行下载的队列，默认为 `DispatchQueue.global()`
    ///   - showIndicator: 是否显示 Indicator，默认为 `false`
    ///   - success: 下载成功的 Task
    ///   - failure: 下载失败的 Task
    public static func download(
        config: RGDownloadConfig,
        queue: DispatchQueue = DispatchQueue.global(),
        showIndicator: Bool = false,
        success: @escaping DownloadSuccess,
        failure: @escaping DownloadFailure
    ) {
        if showIndicator == true {
            RGNetwork.showIndicator()
            RGNetwork.showActivityIndicator()
        }

        queue.async {
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

                RGNetwork.downloadData(with: request, config: config, success: success, failure: failure)
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
        config: RGNetworkConfig,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        request.responseData { responseData in
            if config.isShowLog == true {
                dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")
            }

            let httpStatusCode = responseData.response?.statusCode
            guard let data = responseData.value else {
                failure(responseData.error, nil, nil, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }
            let string = String(data: data, encoding: .utf8)
            guard let code = httpStatusCode, code >= 200 && code < 300 else {
                failure(responseData.error, string, data, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(
                    with: data,
                    options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
                ) as? ResponseJSON else {
                    success(nil, string, data, httpStatusCode, request, .data(responseData))
                    RGNetwork.hideIndicator()
                    return
                }

                success(json, string, data, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
            } catch {
                success(nil, error.localizedDescription, data, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }
        }
    }

    private static func responseDecodable<T: Decodable>(
        with request: DataRequest,
        of type: T.Type = T.self,
        config: RGNetworkConfig,
        success: @escaping DecodableSuccess<T>,
        failure: @escaping DecodableFailure<T>
    ) {
        request.responseDecodable(of: type) { response in
            if config.isShowLog == true {
                dLog("RGNetwork.request.debugDescription: \n\(response.debugDescription)")
            }

            let httpStatusCode = response.response?.statusCode
            var responseData = Data()
            if let data = response.data {
                responseData = data
            }
            let string = String(data: responseData, encoding: .utf8)
            guard let value = response.value else {
                failure(response.error, nil, response.data, httpStatusCode, request, response)
                return
            }
            print(value)
            success(value, nil, response.data, httpStatusCode, request, response)
        }
    }

    private static func responseString(
        with request: DataRequest,
        success: @escaping SuccessTask,
        failure: @escaping FailureTask
    ) {
        request.responseString { (responseString) in
            dLog("RGNetwork.request.debugDescription: \n\(responseString.debugDescription)")

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
            dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")

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


// MARK: - Response of DownloadRequest

extension RGNetwork {

    private static func downloadData(
        with request: DownloadRequest,
        config: RGNetworkConfig,
        success: @escaping DownloadSuccess,
        failure: @escaping DownloadFailure
    ) {
        request.responseData { responseData in
            if config.isShowLog {
                dLog("RGNetwork.download.debugDescription: \n\(responseData.debugDescription)")
            }

            let httpStatusCode = responseData.response?.statusCode
            guard let data = responseData.value else {
                failure(responseData.error, nil, nil, httpStatusCode, request, .data(responseData))
                RGNetwork.hideIndicator()
                return
            }

            let string = String(data: data, encoding: .utf8)
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? ResponseJSON

            success(json, string, data, responseData.fileURL, httpStatusCode, request, .data(responseData))
            RGNetwork.hideIndicator()
        }
    }

}


// MARK: - URL Path Handle

extension RGNetwork {

    internal static func urlPathString(by urlString: String) throws -> String {
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
    internal static func showIndicator(
        mode: MBProgressHUDMode = .indeterminate,
        text: String = ""
    ) {
        DispatchQueue.mainAsync {
            guard let window = UIApplication.shared.keySceneWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.mode = mode
            hud.label.text = text
        }
    }

    /// 隐藏 indicator
    internal static func hideIndicator() {
        DispatchQueue.mainAsync {
            guard let window = UIApplication.shared.keySceneWindow else { return }
            MBProgressHUD.hide(for: window, animated: true)
        }
    }

}


// MARK: - Proxy

extension RGNetwork {

    /// 是否设置网络代理
    public static var isSetupProxy: Bool {
        if proxyType == kCFProxyTypeNone {
            dLog("当前未设置网络代理")
            return false
        } else {
            dLog("当前设置了网络代理")
            return true
        }
    }

    /// 网络代理主机名
    public static var proxyHostName: String {
        let hostName = proxyInfos.object(forKey: kCFProxyHostNameKey) as? String ?? "Proxy Host Name is nil"
        dLog("Proxy Host Name: \(hostName)")
        return hostName
    }

    /// 网络代理端口号
    public static var proxyPortNumber: String {
        let portNumber = proxyInfos.object(forKey: kCFProxyPortNumberKey) as? String ?? "Proxy Port Number is nil"
        dLog("Proxy Port Number: \(portNumber)")
        return portNumber
    }

    /// 网络代理类型
    public static var proxyType: CFString {
        let type = proxyInfos.object(forKey: kCFProxyTypeKey) ?? kCFProxyTypeNone
        dLog("Proxy Type: \(type)")
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
                dLog("当前开启了 VPN")
                flag = true
                break
            }
        }
        if flag == false {
            dLog("当前未开启 VPN")
        }
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


// MARK: - DispatchQueue

fileprivate extension DispatchQueue {

    static func mainAsync(execute: @escaping () -> Void) {
        if Thread.current.isMainThread {
            execute()
        } else {
            main.async { execute() }
        }
    }

}


// MARK: - UIApplication Extension

fileprivate extension UIApplication {

    var keySceneWindow: UIWindow? {
        if #available(iOS 13, *) {
            var keyWindow: UIWindow?
            for connectedScene in UIApplication.shared.connectedScenes {
                guard let windowScene = connectedScene as? UIWindowScene else {
                    continue
                }
                if #available(iOS 15, *) {
                    keyWindow = windowScene.keyWindow
                    break
                } else {
                    for window in windowScene.windows where window.isKeyWindow {
                        keyWindow = window
                    }
                }
            }
            return keyWindow
        } else {
            return UIApplication.shared.keyWindow
        }
    }

}


// MARK: - Debug Log

internal func dLog(
    _ item: @autoclosure () -> Any,
    separator: String = " ",
    terminator: String = "\n",
    file: String = #file,
    method: String = #function,
    line: Int = #line
) {
#if DEBUG
    print("\n/* ***** ***** ***** ***** ***** ***** */\n")
    print("\(URL(fileURLWithPath: file).lastPathComponent)[\(line)], \(method): \n")
    print(item(), separator: separator, terminator: terminator)
    print("")
#endif
}
