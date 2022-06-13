//
//  ResponseSerialization+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {

  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    showLog: Bool = true,
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) -> Self {
    if showIndicator == true {
      RGNetwork.showIndicator()
      RGNetwork.showActivityIndicator()
    }

    queue.async { [weak self] in
      guard let self = self else { return }
      self.responseData { responseData in
        if showLog == true {
          dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")
        }

        let httpStatusCode = responseData.response?.statusCode
        guard let data = responseData.value else {
          failure(responseData.error, nil, nil, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
        let string = String(data: data, encoding: .utf8)
        guard let code = httpStatusCode, code >= 200 && code < 300 else {
          failure(responseData.error, string, data, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
        do {
          let json = try JSONSerialization.jsonObject(
            with: data,
            options: [.fragmentsAllowed, .mutableContainers, .mutableLeaves]
          ) as? ResponseJSON

          success(json, string, data, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
        } catch {
          success(nil, error.localizedDescription, data, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
      }
    }

    return self
  }

  @discardableResult
  public func responseDecodable<T: Decodable>(
    of type: T.Type = T.self,
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    showLog: Bool = true,
    success: @escaping SuccessRequestDecodable<T>,
    failure: @escaping FailureRequestDecodable<T>
  ) -> Self {
    if showIndicator == true {
      RGNetwork.showIndicator()
      RGNetwork.showActivityIndicator()
    }

    queue.async { [weak self] in
      guard let self = self else { return }
      self.responseDecodable(of: type) { response in
        if showLog == true {
          dLog("RGNetwork.request.decodable.debugDescription: \n\(response.debugDescription)")
        }

        let httpStatusCode = response.response?.statusCode
        var responseData = Data()
        if let data = response.data {
          responseData = data
        }
        let string = String(data: responseData, encoding: .utf8)
        guard let code = httpStatusCode, code >= 200 && code < 300 else {
          failure(response.error, string, response.data, httpStatusCode, self, response)
          RGNetwork.hideIndicator()
          return
        }

        guard let value = response.value else {
          success(nil, string, response.data, httpStatusCode, self, response)
          RGNetwork.hideIndicator()
          return
        }

        success(value, string, response.data, httpStatusCode, self, response)
        RGNetwork.hideIndicator()
      }
    }

    return self
  }

}


// MARK: -

extension DownloadRequest {

  @discardableResult
  public func responseJSON(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    showLog: Bool = true,
    success: @escaping SuccessDownload,
    failure: @escaping FailureDownload
  ) -> Self {
    if showIndicator == true {
      RGNetwork.showIndicator()
      RGNetwork.showActivityIndicator()
    }

    queue.async { [weak self] in
      guard let self = self else { return }
      self.responseData { responseData in
        if showLog == true {
          dLog("RGNetwork.download.debugDescription: \n\(responseData.debugDescription)")
        }

        let httpStatusCode = responseData.response?.statusCode
        guard let data = responseData.value else {
          failure(responseData.error, nil, nil, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }

        let string = String(data: data, encoding: .utf8)
        guard let code = httpStatusCode, code >= 200 && code < 300 else {
          failure(responseData.error, string, data, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
        do {
          let json = try JSONSerialization.jsonObject(
            with: data,
            options: .fragmentsAllowed
          ) as? ResponseJSON

          success(json, string, data, responseData.fileURL, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
        } catch {
          success(nil, error.localizedDescription, data, responseData.fileURL, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
      }
    }

    return self
  }

}
