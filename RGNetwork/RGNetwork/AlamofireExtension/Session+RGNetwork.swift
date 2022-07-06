//
//  Session+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension Session {

  public func request(
    urlString: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    timeoutInterval: TimeInterval = 30.0
  ) -> DataRequest {
    let urlPath = RGURLHandler.urlPathString(by: urlString)
    let request = request(
      urlPath,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      requestModifier: { urlRequest in
        urlRequest.timeoutInterval = timeoutInterval
      })
    return request
  }

      to: urlPath,
      })
    return request
  }

      urlPath,
      },
    return request
  }

}
