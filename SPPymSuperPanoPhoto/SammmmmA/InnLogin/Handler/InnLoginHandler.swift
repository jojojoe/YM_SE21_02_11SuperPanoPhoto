//
//  InnLogonHandler.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/10.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import WebKit

class InnLoginHandler: NSObject {
    class func clearWebCache () {
        //清除cookies
        let storage:HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in storage.cookies ?? [] {
            storage.deleteCookie(cookie)
        }
     
        //清除WKWebView的缓存
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
    }
}
