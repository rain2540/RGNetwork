//
//  RGNetworkTypeAlias.swift
//  RGNetwork
//
//  Created by RAIN on 2016/11/15.
//  Copyright © 2016年 Smartech. All rights reserved.
//

import Foundation
import Alamofire


public typealias ResponseJSON = [String: Any]
public typealias ResponseString = String
public typealias ResponseData = Data
public typealias HttpStatusCode = Int


public typealias RequestSuccess = (ResponseJSON?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void
public typealias RequestFailure = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<Data, AFError>) -> Void

public typealias RequestDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void
public typealias RequestDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DataRequest, DataResponse<T, AFError>) -> Void

public typealias DownloadSuccess = (ResponseJSON?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void
public typealias DownloadFailure = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<Data, AFError>) -> Void

public typealias DownloadDecodableSuccess<T: Decodable> = (T?, ResponseString?, ResponseData?, URL?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void
public typealias DownloadDecodableFailure<T: Decodable> = (Error?, ResponseString?, ResponseData?, HttpStatusCode?, DownloadRequest, DownloadResponse<T, AFError>) -> Void


@available(iOS 13, *)
public typealias RequestSerializingJSONSuccess = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

@available(iOS 13, *)
public typealias RequestSerializingJSONFailure = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

@available(iOS 13, *)
public enum RequestSerializingJSON {
  case success(RequestSerializingJSONSuccess)
  case failure(RequestSerializingJSONFailure)
}


@available(iOS 13, *)
public typealias RequestSerializingDecodableSuccess<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Value>
)

@available(iOS 13, *)
public typealias RequestSerializingDecodableFailure<Value: Decodable> = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Value>
)

@available(iOS 13, *)
public enum RequestSerializingDecodable<Value: Decodable> {
  case success(RequestSerializingDecodableSuccess<Value>)
  case failure(RequestSerializingDecodableFailure<Value>)
}


@available(iOS 13, *)
public typealias DownloadSerializingJSONSuccess = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Data>
)

@available(iOS 13, *)
public typealias DownloadSerializingJSONFailure = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Data>
)

@available(iOS 13, *)
public enum DownloadSerializingJSON {
  case success(DownloadSerializingJSONSuccess)
  case failure(DownloadSerializingJSONFailure)
}


@available(iOS 13, *)
public typealias DownloadSerializingDecodableSuccess<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Value>
)

@available(iOS 13, *)
public typealias DownloadSerializingDecodableFailure<Value: Decodable> = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Value>
)

@available(iOS 13, *)
public enum DownloadSerializingDecodable<Value: Decodable> {
  case success(DownloadSerializingDecodableSuccess<Value>)
  case failure(DownloadSerializingDecodableFailure<Value>)
}
