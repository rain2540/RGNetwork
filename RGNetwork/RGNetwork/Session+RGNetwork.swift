//
//  Session+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension Session {

  public func request(config: RGDataRequestConfig) throws -> DataRequest {
    do {
      let urlPath = try RGNetwork.urlPathString(by: config.urlString)
      let request = request(
        urlPath,
        method: config.method,
        parameters: config.parameters,
        encoding: config.encoding,
        headers: config.headers,
        requestModifier: { urlRequest in
          urlRequest.timeoutInterval = config.timeoutInterval
        })
      return request
    } catch {
      throw error
    }
  }

  public func upload(config: RGUploadConfig) throws -> UploadRequest {
    do {
      let urlPath = try RGNetwork.urlPathString(by: config.urlString)
      let request = AF.upload(
        multipartFormData: config.multipartFormData,
        to: urlPath,
        method: config.method,
        headers: config.headers,
        requestModifier: { uploadRequest in
          uploadRequest.timeoutInterval = config.timeoutInterval
        })
      return request
    } catch {
      throw error
    }
  }

  public func download(config: RGDownloadConfig) throws -> DownloadRequest {
    do {
    } catch {
      throw error
    }
  }

}
