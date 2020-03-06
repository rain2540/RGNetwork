//
//  RGBaseRequest.swift
//  RGNetwork
//
//  Created by Rain on 2020/3/6.
//  Copyright © 2020 Smartech. All rights reserved.
//

import Foundation
import Alamofire

class RGBaseRequest {
    
    let urlString: String
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: ParameterEncoding
    let headers: HTTPHeaders?
    
    
    // MARK: - Lifecycle
    init(urlString: String,
         method: HTTPMethod = .get,
         parameters: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil)
    {
        self.urlString  =   urlString
        self.method     =   method
        self.parameters =   parameters
        self.encoding   =   encoding
        self.headers    =   headers
    }
    
}


// MARK: - Public
extension RGBaseRequest {
    
    public func task(showIndicator: Bool = false,
                     responseType: ResponseType = .json,
                     success: @escaping SuccessTask,
                     failure: @escaping FailureTask)
    {
        RGNetwork.request(
            with: urlString,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            showIndicator: showIndicator,
            responseType: responseType,
            success: success,
            failure: failure
        )
    }
    
}
