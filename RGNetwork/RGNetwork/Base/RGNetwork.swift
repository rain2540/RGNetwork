//
//  RGNetwork.swift
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
public typealias RequestSerilizeJSONSuccess = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

@available(iOS 13, *)
public typealias RequestSerilizeJSONFailure = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Data>
)

@available(iOS 13, *)
public enum RequestSerializeJSON {
  case success(RequestSerilizeJSONSuccess)
  case failure(RequestSerilizeJSONFailure)
}


@available(iOS 13, *)
public typealias RequestSerializeDecodableSuccess<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Value>
)

@available(iOS 13, *)
public typealias RequestSerializeDecodableFailure<Value: Decodable> = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  httpStatusCode: HttpStatusCode?,
  task: DataTask<Value>
)

@available(iOS 13, *)
public enum RequestSerializeDecodable<Value: Decodable> {
  case success(RequestSerializeDecodableSuccess<Value>)
  case failure(RequestSerializeDecodableFailure<Value>)
}


@available(iOS 13, *)
public typealias DownloadSerializeJSONSuccess = (
  json: ResponseJSON?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Data>
)

@available(iOS 13, *)
public typealias DownloadSerializeJSONFailure = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Data>
)

@available(iOS 13, *)
public enum DownloadSerializeJSON {
  case success(DownloadSerializeJSONSuccess)
  case failure(DownloadSerializeJSONFailure)
}


@available(iOS 13, *)
public typealias DownloadSerializeDecodableSuccess<Value: Decodable> = (
  value: Value?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Value>
)

@available(iOS 13, *)
public typealias DownloadSerializeDecodableFailure<Value: Decodable> = (
  error: Error?,
  string: ResponseString?,
  data: ResponseData?,
  url: URL?,
  httpStatusCode: HttpStatusCode?,
  task: DownloadTask<Value>
)

@available(iOS 13, *)
public enum DownloadSerializeDecodable<Value: Decodable> {
  case success(DownloadSerializeDecodableSuccess<Value>)
  case failure(DownloadSerializeDecodableFailure<Value>)
}
