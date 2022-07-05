//
//  RGNetworkIndicator.swift
//  RGNetwork
//
//  Created by RAIN on 2022/7/5.
//  Copyright © 2022 Smartech. All rights reserved.
//

import UIKit
import MBProgressHUD

public struct RGNetworkIndicator {

  public static func show(
    mode: MBProgressHUDMode = .indeterminate,
    text: String = ""
  ) {
    DispatchQueue.mainAsync {
      guard let window = UIApplication.shared.keySceneWindow else { return }
      let hud = MBProgressHUD.showAdded(to: window, animated: true)
      hud.mode = mode
      hud.label.text = text
    }
  }


}
