//
//  ResponseSerialization+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/6/2.
//  Copyright © 2022 Smartech. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {

  public func responseJSON(
    queue: DispatchQueue = .main,
    showIndicator: Bool = false,
    showLog: Bool = true,
    success: @escaping SuccessRequest,
    failure: @escaping FailureRequest
  ) {
    if showIndicator == true {
      RGNetwork.showIndicator()
      RGNetwork.showActivityIndicator()
    }
  }

}
