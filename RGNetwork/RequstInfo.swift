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
    case rgDataRequest = "RGDataRequest"
    case urlSessionCallback = "URLSession 回调"
    case urlSessionAsync = "URLSession 并发"
    case alamofireAsync = "Alamofire 并发"

    static var list: [RequstInfo] {
        return [
            rgNetwork,
            rgDataRequest,
            urlSessionCallback,
            urlSessionAsync,
            alamofireAsync,
        ]
    }

}
