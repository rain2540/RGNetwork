//
//  RGDownloadConfig.swift
//  RGNetwork
//
//  Created by RAIN on 2021/9/14.
//  Copyright © 2021 Smartech. All rights reserved.
//

import Foundation
import Alamofire

struct RGDownloadConfig: RGNetworkConfig {

    let urlString: String
    let method: HTTPMethod
    let headers: HTTPHeaders?
    let timeoutInterval: TimeInterval
    let parameters: Parameters?
    let encoding: ParameterEncoding
    let destination: DownloadRequest.Destination?

}
