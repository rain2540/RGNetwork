//
//  RGNetworkConfig.swift
//  RGNetwork
//
//  Created by Rain on 2021/6/28.
//  Copyright © 2021 Smartech. All rights reserved.
//

import Foundation
import Alamofire

protocol RGNetworkConfig {

    var urlString: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var timeoutInterval: TimeInterval { get }

}
