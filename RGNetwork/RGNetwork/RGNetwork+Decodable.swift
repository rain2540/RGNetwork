//
//  RGNetwork+Decodable.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/1.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

typealias DecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
typealias DecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

typealias DownloadDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
typealias DownloadDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void

extension RGNetwork {

  // MARK: DataRequest

  /// 通用请求方法，用于获取满足 `Decodable` 协议的实体类对象
  /// - Parameters:
  ///   - type: 实体对象的类别
  ///   - config: 网络请求配置信息
  ///   - queue: 执行请求的队列，默认为 `DispatchQueue.global()`
  ///   - showIndicator: 是否显示 Indicator，默认为 `false`
  ///   - success: 请求成功的 Task
  ///   - failure: 请求失败的 Task
  public static func requestDecodable<T: Decodable>(
    of type: T.Type = T.self,
    config: RGDataRequestConfig,
    queue: DispatchQueue = DispatchQueue.global(),
    showIndicator: Bool = false,
    success: @escaping DecodableSuccess<T>,
    failure: @escaping DecodableFailure<T>
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
          })
          .validate(statusCode: 200 ..< 300)

        RGNetwork.responseDecodable(of: type, with: request, config: config, success: success, failure: failure)
      } catch {
        dLog(error)
        RGNetwork.hideIndicator()
      }
    }
  }

}
