//
//  UIViewController+EXtent.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/14.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit
import PKHUD
extension UIViewController {
    func showHud() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    func showSucess(title: String? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 2)
    }
    func hiddenHUD() {
        PKHUD.sharedHUD.hide(animated: true)
    }
    func showError(errorInfo: AnyObject? = nil) {
        if let _ = errorInfo {
            PKHUD.sharedHUD.contentView = PKHUDStatusView(title: "\(errorInfo)", subtitle: nil, image: nil)
        }else {
            PKHUD.sharedHUD.contentView = PKHUDErrorView()
        }

        if PKHUD.sharedHUD.isVisible == false {
            PKHUD.sharedHUD.show()
        }
        PKHUD.sharedHUD.hide(afterDelay: 2)
    }
}