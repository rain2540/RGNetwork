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

  /// 显示 indicator
  /// - Parameters:
  ///   - mode: 显示模式，默认为 .indeterminate
  ///   - text: 显示的文字，默认为空
  public static func show(
    mode: MBProgressHUDMode = .indeterminate,
    text: String = ""
  ) {
      guard let window = UIApplication.shared.keySceneWindow else { return }
    DispatchQueue.rg_mainAsync {
      let hud = MBProgressHUD.showAdded(to: window, animated: true)
      hud.mode = mode
      hud.label.text = text
    }
  }

  /// 隐藏 indicator
  public static func hide() {
      guard let window = UIApplication.shared.keySceneWindow else { return }
    DispatchQueue.rg_mainAsync {
      MBProgressHUD.hide(for: window, animated: true)
    }
  }

}
