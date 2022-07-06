//
//  UIApplication+RGNetwork.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/6.
//  Copyright © 2022 Smartech. All rights reserved.
//

import UIKit

internal extension UIApplication {

  var keySceneWindow: UIWindow? {
    if #available(iOS 13, *) {
      var keyWindow: UIWindow?
      for connectedScene in UIApplication.shared.connectedScenes {
        guard let windowScene = connectedScene as? UIWindowScene else {
          continue
        }
        if #available(iOS 15, *) {
          keyWindow = windowScene.keyWindow
          break
        } else {
          for window in windowScene.windows where window.isKeyWindow {
            keyWindow = window
          }
        }
      }
      return keyWindow
    } else {
      return UIApplication.shared.keyWindow
    }
  }

}
