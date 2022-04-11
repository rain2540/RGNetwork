//
//  RGNetwork+Concurrency.swift
//  RGNetwork
//
//  Created by RAIN on 2022/4/11.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseTuple = (
    json: ResponseJSON?,
    string: ResponseString?,
    data: ResponseData?,
    error: Error?,
    httpStatusCode: HttpStatusCode?,
    request: DataRequest?,
    responsePackage: DataResponsePackage?
)

extension RGNetwork {

}
