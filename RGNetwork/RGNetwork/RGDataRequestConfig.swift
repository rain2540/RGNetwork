//
//  RGDataRequestConfig.swift
//  RGNetwork
//
//  Created by Rain on 2021/6/28.
//  Copyright © 2021 Smartech. All rights reserved.
//

import Foundation
import Alamofire

struct RGDataRequestConfig: RGNetworkConfig {

    let urlString: String
    let method: HTTPMethod
    let headers: HTTPHeaders?
    let timeoutInterval: TimeInterval
    let parameters: Parameters?
    let encoding: ParameterEncoding

}
