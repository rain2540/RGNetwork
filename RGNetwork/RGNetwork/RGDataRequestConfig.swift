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


    init(urlString: String,
         method: HTTPMethod = .get,
         parameters: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil,
         timeoutInterval: TimeInterval = 30.0
    ) {
        self.urlString          =   urlString
        self.method             =   method
        self.parameters         =   parameters
        self.encoding           =   encoding
        self.headers            =   headers
        self.timeoutInterval    =   timeoutInterval
    }

}
