//
//  RGUploadConfig.swift
//  RGNetwork
//
//  Created by Rain on 2021/6/28.
//  Copyright © 2021 Smartech. All rights reserved.
//

import Foundation
import Alamofire

struct RGUploadConfig: RGNetworkConfig {

    let urlString: String
    let method: HTTPMethod
    let headers: HTTPHeaders?
    let timeoutInterval: TimeInterval
    let multipartFormData: (MultipartFormData) -> Void
    var isShowLog: Bool


    init(
        urlString: String,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval = 30.0,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) {
        self.urlString          =   urlString
        self.method             =   method
        self.headers            =   headers
        self.timeoutInterval    =   timeoutInterval
        self.isShowLog          =   isShowLog
        self.multipartFormData  =   multipartFormData
    }

}
