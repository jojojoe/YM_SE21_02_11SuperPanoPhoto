//
//  Extension.swift
//  TagPost
//
//  Created by Di on 2019/3/19.
//  Copyright © 2019 Di. All rights reserved.
//

import SwifterSwift
import UIKit


public extension UIApplication {
    static var topSafeAreaHeight: CGFloat {
        var topSafeAreaHeight: CGFloat = 0
         if #available(iOS 11.0, *) {
               let window = UIApplication.shared.windows[0]
               let safeFrame = window.safeAreaLayoutGuide.layoutFrame
               topSafeAreaHeight = safeFrame.minY
             }
        return topSafeAreaHeight
    }
    
    static var bottomSafeAreaHeight: CGFloat {
           var bottomSafeAreaHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                  let window = UIApplication.shared.windows[0]
                  let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                 bottomSafeAreaHeight = UIScreen.height - safeFrame.height - UIApplication.topSafeAreaHeight
                }
           return bottomSafeAreaHeight
       }
}

public extension Int {
    func k() -> String {
        if self >= 1000 {
            var sign: String {
                return self >= 0 ? "" : "-"
            }
            let abs = Swift.abs(self)
            if abs >= 1000, abs < 1_000_000 {
                return String(format: "\(sign)%.2fK", abs.double / 1000.0)
            }
            return String(format: "\(sign)%.2fM", abs.double / 1_000_000.0)
        }
        return string
    }
}


public extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }
}

public extension Bundle {
    var icon: UIImage {
        guard
            let infoDictionary = infoDictionary,
            let iconsDictionary = infoDictionary["CFBundleIcons"] as? [String: Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [Any],
            let lastIconName = iconFiles.last as? String,
            let lastIcon = UIImage(named: lastIconName)
        else {
            assertionFailure("没有设置 AppIcon.")
            return UIImage()
        }

        return lastIcon
    }

    var shortVersion: String {
        guard
            let infoDictionary = infoDictionary,
            let version = infoDictionary["CFBundleShortVersionString"] as? String
        else {
            assertionFailure("get app version failure.")
            return ""
        }
        return version
    }

    var buildNumber: String {
        guard
            let infoDictionary = infoDictionary,
            let buildNumber = infoDictionary["CFBundleVersion"] as? String
        else {
            assertionFailure("get buildNumber failure.")
            return ""
        }
        return buildNumber
    }
}

//public protocol Then {}
//extension Then {
//    @discardableResult
//    public func then(_ block: (Self) -> Void) -> Self {
//        block(self)
//        return self
//    }
//}
//
//extension NSObject: Then {}
