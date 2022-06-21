//
//  RequstInfo.swift
//  RGNetwork
//
//  Created by RAIN on 2022/4/11.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation

enum RequstInfo: String {

  case rgNetwork = "RGNetwork"
  case rgNetworkDecodable = "RGNetwork Decodable"
  case rgDataRequest = "RGDataRequest"
  case urlSessionCallback = "URLSession 回调"
  case urlSessionAsync = "URLSession 并发"
  case alamofireAsync = "Alamofire 并发"
  case rgNetworkAsync = "RGNetwork 并发"
  case taskGroup = "并发任务组"

  static var list: [RequstInfo] {
    return [
      rgNetwork,
      rgNetworkDecodable,
      rgDataRequest,
      urlSessionCallback,
      urlSessionAsync,
      alamofireAsync,
      rgNetworkAsync,
      taskGroup,
    ]
  }

}
