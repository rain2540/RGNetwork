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

    queue.async { [weak self] in
      guard let self = self else { return }
      self.responseData { responseData in
        if showLog == true {
          dLog("RGNetwork.request.debugDescription: \n\(responseData.debugDescription)")
        }

        let httpStatusCode = responseData.response?.statusCode
        guard let data = responseData.value else {
          failure(responseData.error, nil, nil, httpStatusCode, self, responseData)
          RGNetwork.hideIndicator()
          return
        }
      }
    }
  }

}
