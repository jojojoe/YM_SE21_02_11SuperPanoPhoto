//
//  InnNativeWebLoginViewController.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/12.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import WebKit
import DeviceKit
import ZKProgressHUD

class InnNativeWebLoginViewController: UIViewController {
    var loginLoadingView:UIView = UIView()
    var indicatorLoadingLabel:UILabel = UILabel()
    var webView:WKWebView = WKWebView()
    var topOverlayerView:UIView = UIView()
    var topSettingOverlayerView:UIView = UIView()
    var tipView:UIView = UIView()
    var tipLab:UILabel = UILabel()
    var closeBtn = UIButton()
    var retryBtn = UIButton()
    var appstore_appId:String?
    var appstore_appName:String?
    var loginCookieDict:[String:String]?
    var beginRequestUserInfo = false
    var fetchUserInfoComplete:((_ success:Bool, _ errorMessage:String?,_ userDetailsDic:[String:Any?]?) -> Void)?
    var loginComplete:((_ success:Bool,_ cookiesDict:[String:String])->Void)?
    var beginGetUserInfoHandler:(()->Void)?
    var closeLoginPageHandler:(()->Void)?
    var cancelLoginPageHandler:(()->Void)?
    var authCompleteHandler:(() -> Void)?
    var userName:String?
    var userId:String?
    let appName =  UIApplication.shared.displayName ?? ""
    
    var showCloseBtn = false {
        didSet {
            closeBtn.isHidden = !showCloseBtn
        }
    }
    
    var isClose = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initLoginBgView()
        initialUI()
        self.deleteCookie {
            if  let url = URL(string:DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvd6rbe7Zj7zytkPLtLgmXQO")){
                var request = URLRequest.init(url: url)
                request.timeoutInterval = 20
                self.webView.load(request)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isClose = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        InnLoginHandler.clearWebCache()
        resetUI()
    }
}

extension InnNativeWebLoginViewController {
    
    func initLoginBgView()  {
      
        loginLoadingView.removeFromSuperview()
        loginLoadingView = UIView(frame: view.bounds)
        loginLoadingView.backgroundColor = .white
        self.view.addSubview(loginLoadingView)
        let indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicatorView.color = UIColor.gray
        loginLoadingView.addSubview(indicatorView)
        indicatorView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicatorView.center = CGPoint(x: loginLoadingView.center.x, y: loginLoadingView.center.y + 20)
  
     
        indicatorView.startAnimating()
        indicatorLoadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        indicatorLoadingLabel.font = UIFont.systemFont(ofSize: 14)
        indicatorLoadingLabel.center = CGPoint(x: self.view.bounds.size.width/2+24, y: self.view.bounds.size.width/2)
        indicatorLoadingLabel.textAlignment = .center
        indicatorLoadingLabel.text = "Loading..."
        indicatorLoadingLabel.textColor = UIColor.darkText
        loginLoadingView.addSubview(indicatorLoadingLabel)
        indicatorLoadingLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 34)
        indicatorLoadingLabel.center = CGPoint(x: loginLoadingView.center.x, y: loginLoadingView.center.y + 20)
  
        self.showLoginViewLoadingViewStatus(true)
    }
    
    func showLoginViewLoadingViewStatus(_ isShow:Bool) {
        if isShow {
            print("*-*-* showLoginViewLoadingViewStatus YES")
        } else {
            print("*-*-* showLoginViewLoadingViewStatus NO")
            
        }
        loginLoadingView.isHidden = !isShow
    }
    

    func initialUI() {
        webView = WKWebView(frame: self.view.bounds)
        webView.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = true
        self.view.addSubview(self.webView)
        topOverlayerView = UIView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.bounds.size.width, height: 40))
        topOverlayerView.backgroundColor = Device.current.isPad ? UIColor.clear : UIColor.white
        self.view.addSubview(topOverlayerView)
        topSettingOverlayerView = UIView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top+40, width: 50, height: 40))
        topSettingOverlayerView.backgroundColor = Device.current.isPad ? UIColor.clear : UIColor.white
        self.view.addSubview(topSettingOverlayerView)
        
        tipView = UIView()
        tipView.frame = CGRect(x: 0,y: self.webView.frame.maxY - 100, width: UIScreen.main.bounds.size.width, height: 100 + self.view.safeAreaInsets.bottom);
        tipView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
        self.view.addSubview(tipView)
        //
        tipLab = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 70))
        tipLab.numberOfLines = 2
        tipLab.textAlignment = .center
        tipLab.font = UIFont.systemFont(ofSize: 13)
        tipLab.textColor = UIColor(red: 23.0/255.0, green: 24.0/255.0, blue: 52.0/255.0, alpha: 1)
        tipView.addSubview(tipLab)
        if showCloseBtn {
            closeBtn = UIButton(type: .custom)
            closeBtn.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
            //log_in_close_ic  ic_c_c
            let bundle = Bundle(path: Bundle(for: Self.self).path(forResource: "InnLogin", ofType: "bundle") ?? "")
            closeBtn.setImage(UIImage(named: "log_in_close_ic", in: bundle, compatibleWith: nil), for: .normal)
            closeBtn.frame = CGRect(x: 10, y: UIApplication.topSafeAreaHeight+10, width: 30, height: 30)
            self.view.addSubview(self.closeBtn)
        }
        self.view.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)

        retryBtn = UIButton(type: .custom)
        retryBtn.addTarget(self, action: #selector(retryBtnClick(_:)) , for: .touchUpInside)
            //log_in_close_ic  ic_c_c
        retryBtn.setTitle("Retry", for: .normal)
        retryBtn.setTitleColor(UIColor.lightGray, for: .normal)
        retryBtn.layer.borderColor = UIColor.lightGray.cgColor
        retryBtn.layer.borderWidth = 1
        retryBtn.layer.cornerRadius = 6
        let width:CGFloat = 80
        let height:CGFloat = 36
        let originalX = UIScreen.main.bounds.size.width / 2 - (width / 2)
        let originalY = UIScreen.main.bounds.size.height / 2 - (height / 2)
        retryBtn.frame = CGRect(x: originalX, y: originalY, width: width, height: height)
        self.view.addSubview(retryBtn)
        retryBtn.isHidden = true
        
    }
    
    func resetUI(){
        let webFrame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.bounds.size.width, height: self.view.bounds.size.height-self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom)
        self.webView.frame = webFrame
        var appName = self.appstore_appName
        if appName?.count == 0 {
            appName = UIApplication.shared.displayName
        }
        let tip = "The App will never store or use your In\("stagr")am information."
        self.tipLab.text = tip
        topOverlayerView.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.bounds.size.width, height: 60)
        topSettingOverlayerView.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top+60, width: self.view.bounds.size.width, height: 44)
        topSettingOverlayerView.isHidden = true
        self.view.bringSubviewToFront(loginLoadingView)
    }
    
    func closeLoginPage() {
        DispatchQueue.main.async {
            self.showLoginViewLoadingViewStatus(false)
            self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let `self` = self else {return}
                self.closeLoginPageHandler?()
                
            })
        }
    }
    
}

extension InnNativeWebLoginViewController {
    
    
    func requestUserInfo(cookieDict:[String:Any]?){
        guard let cookieDict = cookieDict else { return  }
        guard let cookieDictSS = cookieDict as? [String:String] else {
            return
        }
        print("*-*-* requestUserInfoWithCookies")
        self.beginRequestUserInfo = true
        var cookieDict_M: [String:String] = [:]
        cookieDict.forEach { (key, value) in
            if value is String {
                cookieDict_M[key] = value as? String
            }
        }
  
        print("*-*-* self.loginComplete")
        self.loginComplete?(true, cookieDict_M);
        
        ZKProgressHUD.show()
        
        
        let userId = cookieDict["ds_user_id"] as? String
        
        self.beginGetUserInfoHandler?()
        let model = cookieDictSS.cookiesDictToModel()
        self.resetCurrentLoginInsCookie(cookieModel: model)
        InnRequestHelper.shared.fetchIGUserDetail(userID: userId) { [weak self](success, errorMessage, userDetailsDic) in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
            }
            
            self.fetchUserInfoComplete?(success, errorMessage, userDetailsDic)
            if (!success) {
               self.view.makeToast(errorMessage, duration: 3.0, position: nil)
            }
            self.closeLoginPage()
            
        }
    }
    
    func clearCookie() {
        let storages = HTTPCookieStorage.shared
        storages.cookies?.forEach({ (cookie) in
            storages.deleteCookie(cookie)
        })
        
        URLCache.shared.removeAllCachedResponses()
    }
    
    func resetCurrentLoginInsCookie(cookieModel: LightCookies?) {
        guard let cookieModel = cookieModel else { return  }
        self.clearCookie()
        
        do {
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "csrftoken"
            fromappDict[.value] = cookieModel.csrftoken ?? ""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        }
        
        do {
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "ds_user_id"
            fromappDict[.value] = cookieModel.dsUserId ?? ""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        }
        
        do {
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "rur"
            fromappDict[.value] = "PRN"
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        }
        do {
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "urlgen"
            fromappDict[.value] = "\"{\"104.245.13.89\": 21859}:1hOiip:z6gd0Gij256B5LWQKlerXSsj6zM\""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        
        }
        do {
            
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "ds_user"
            fromappDict[.value] = cookieModel.dsUser ?? ""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
           
        }
        do {
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "sessionid"
            fromappDict[.value] = cookieModel.sessionid ?? ""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        }
//        do {
//            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
//            fromappDict[.version]  = "0"
//            fromappDict[.path] =  "/"
//            fromappDict[.name] =  "csrftoken"
//            fromappDict[.value] = cookieModel.mid ?? ""
//            fromappDict[.domain]  = ".in\("stagr")am.com"
//            // 将可变字典转化为cookie
//            if  let cookie = HTTPCookie.init(properties: fromappDict) {
//                // 获取cookieStorage
//                let cookieStorage = HTTPCookieStorage.shared
//                // 存储cookie
//                cookieStorage.setCookie(cookie)
//            }
//        }
        do {
            
            var fromappDict:[HTTPCookiePropertyKey:Any] = [:]
            fromappDict[.version]  = "0"
            fromappDict[.path] =  "/"
            fromappDict[.name] =  "mid"
            fromappDict[.value] = cookieModel.mid ?? ""
            fromappDict[.domain]  = ".in\("stagr")am.com"
            // 将可变字典转化为cookie
            if  let cookie = HTTPCookie.init(properties: fromappDict) {
                // 获取cookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                // 存储cookie
                cookieStorage.setCookie(cookie)
            }
        }
    }
    
    func deleteCookie(completion:@escaping()->Void) {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            records.forEach { (record) in
                debugPrint("record = \(record.displayName)")
                if record.displayName.contains("in\("stag")ram") || record.displayName.contains("fa\("ce")book") {
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                        
                    }
                }
            }
            completion()
        }
    }
    
    func parseNativeCookie(compeltion:@escaping(_ isSuccess:Bool)->Void) {
        var cookieDict = [String:String]()
        let store = WKWebsiteDataStore.default()
        store.httpCookieStore.getAllCookies { (cookies) in
            cookies.forEach { (cookie) in
                cookieDict[cookie.name] = cookie.value
            }
            self.loginCookieDict = cookieDict;
            
            let userId = cookieDict["ds_user_id"]
            compeltion(userId != nil)
        }
    }
    
    func cancelAuthorization() {
        self.deleteCookie {
            self.loginCookieDict = nil
            if  let url = URL(string: DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvd6rbe7Zj7zytkPLtLgmXQO")) {
                let request = URLRequest.init(url: url)
                self.webView.load(request)
            }
        }
    }
    
    func finishAuthorization() {
        let authenKey = "hasAuthenticationInThisDevice_\(self.userId ?? "")"
        UserDefaults.standard.set(true, forKey: authenKey)
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.authCompleteHandler?()
            self.closeLoginPage()
        }
    }
    
    func queryArray(queryStrings:String?) -> [[String:String]] {
         var queryArray:[[String:String]] = []
         for queryComponent in queryStrings?.components(separatedBy: "&") ?? [] {
             
             let nsqueryComponent = queryComponent as NSString
             var queryName = ""
             var queryValue = ""
             
             let  range = nsqueryComponent.range(of: "=")
             if (range.location == NSNotFound) {
                 queryName = nsqueryComponent as String
             } else {
                 queryName = nsqueryComponent.substring(with: NSRange(location: 0, length: range.location))
                 queryValue = nsqueryComponent.substring(from: range.location + range.length)
                 queryValue = (queryValue as NSString).removingPercentEncoding ?? ""
             }
             
             queryArray.append(["name": queryName, "value": queryValue])
         }
         let arr = Array(queryArray)
         return arr
     }
    
    func handleQuery(queryName:String?,queryValue:String?) {
        if queryName == "allow" {
            if queryValue == "Authorize" {
                self.finishAuthorization()
            } else if queryValue == "Cancel" {
                cancelAuthorization()
            }
        }
    }
    
    func tt(loop:Bool,completion:@escaping(()->Void)) {

        if (self.beginRequestUserInfo || self.isClose) {
            print("*-*-* if (self.beginRequestUserInfo) {")
            return
        }
        
        if (loop) {
            print("*-*-* testWithLoop:(BOOL)loop = YES")
        } else {
            print("*-*-* testWithLoop:(BOOL)loop = NO")
        }
        
        self.parseNativeCookie { [weak self](isSuccess) in
             guard let `self` = self else {return}
            if (isSuccess) {
                if !self.beginRequestUserInfo  {
                    print("*-*-* if (!self.beginRequestUserInfo) {");
                    self.requestUserInfo(cookieDict: self.loginCookieDict)
                }
                completion()
            } else {
                if (loop){
                    print("*-*-* if (loop){")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.tt(loop: loop, completion: completion)
                    }
                }
            }
        }
    }
}
    


extension InnNativeWebLoginViewController {
    @objc func closeAction(_ sender: UIButton) {
        self.isClose = true
        self.cancelLoginPageHandler?()
        self.presentingViewController?.dismiss(animated: true) { [weak self] in
            let store = WKWebsiteDataStore.default()
            store.httpCookieStore.getAllCookies { (cookies) in
                print("*-*-* cookieDict = \(cookies)")
            }
           
        }
    }
    
    @objc func retryBtnClick(_ sender:UIButton){
        if  let url = URL(string: DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvd6rbe7Zj7zytkPLtLgmXQO")) {
            var request = URLRequest.init(url: url)
            request.timeoutInterval = 20
            self.webView.load(request)
            self.showLoginViewLoadingViewStatus(true)
        }
    }
}

extension InnNativeWebLoginViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        parseNativeCookie { [weak self](isSuccess) in
            guard let `self` = self else {return}
            if isSuccess {
                if !self.beginRequestUserInfo {
                    self.requestUserInfo(cookieDict: self.loginCookieDict)
                }
            }
           
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.contains(DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvcRdbTyTSWhnxPdQ72p1l7RvCKrEJ+nZgfmQoSK3AFCNQ==")!) ?? false {
            
            
        }
        
        if navigationAction.request.url?.scheme == "ios" {
            if navigationAction.request.url?.absoluteString == "ios://notUser" {
                decisionHandler(.cancel)
                self.cancelAuthorization()
                
            } else {
                
                var queryString = navigationAction.request.url?.query
                queryString = queryString?.replacingOccurrences(of: "+", with: "%20")
                
                let queryArrays = queryArray(queryStrings: queryString)
                if queryArrays.count == 1 {
                    let queryDictionary = queryArrays[0]
                    let queryName = queryDictionary["name"]
                    let queryValue = queryDictionary["value"]
                    self.handleQuery(queryName: queryName,queryValue: queryValue)
                    if queryValue == "Cancel" {
                        decisionHandler(.cancel);
                    } else {
                        decisionHandler(.allow);
                    }
                } else {
                    decisionHandler(.allow)
                }
            }
        } else {
            
            var  hasUserId = false
            
            if self.loginCookieDict != nil {
                print("*-*-* self.loginCookieDict")
                self.loginCookieDict?.keys.forEach({ (key) in
                    if key == "ds_user_id" {
                        hasUserId = true
                    }
                })
            }
            
            
            if navigationAction.request.url?.absoluteString == "detail.html" {
                decisionHandler(.allow)
            } else {
                
                if hasUserId {
                    if  !self.beginRequestUserInfo {
                        self.requestUserInfo(cookieDict: self.loginCookieDict)
                    }
                    decisionHandler(.cancel)
                } else {
                    print("*-*-* begin get cookie")
                    
                    if  navigationAction.request.url?.absoluteString ==   DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F5RjQLYIGepoCUTG0qDWnKk=") {
                        self.showLoginViewLoadingViewStatus(true)
                        print("*-*-* testWithLoop:YES")
                        self.tt(loop: true) {
                            print("*-*-* cookie finished")
                        }
                        
                    } else if navigationAction.request.url?.absoluteString == DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvd6rbe7Zj7zytkPLtLgmXQO") {
//                        print("*-*-* testWithLoop https://www.In\("stagr")am.com/accounts/login/ :NO")
                        self.tt(loop: false) {
                            print("*-*-* cookie finished")
                        }
                    } else if  navigationAction.request.url?.absoluteString == "https://m.fa\("ceb")ook.com/login" {
//                        print("*-*-* testWithLoop https://m.facebook.com/login :NO")
                        self.tt(loop: false) {
                            print("*-*-* cookie finished");
                        }
                    } else {
                        print("*-*-* testWithLoop other :Yes")
                        self.tt(loop: true) {
                            print("*-*-* cookie finished")
                        }
                    }
                    decisionHandler(.allow)
                }
                
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryBtn.isHidden = true
        let pagePath =  URL(fileURLWithPath:(Bundle.main.bundlePath ).appendingPathComponent("detail.html")).absoluteString
          
        if webView.url?.path == pagePath {
            if self.appstore_appId?.count ?? 0 == 0 {
                if (Bundle(path: Bundle.main.bundlePath)?.infoDictionary?["appstore_appId"] as? String)?.count ?? 0 > 0 {
                    self.appstore_appId = Bundle(path: Bundle.main.bundlePath)?.infoDictionary?["appstore_appId"] as? String
                } else {
                    self.appstore_appId = ""
                }
            }
            
            let appLink = "itms-apps://itunes.apple.com/app/id\(self.appstore_appId!)"
            
            let jsString = "fillInfo('\(self.userName ?? "")', '\(appName)', '\(appLink)')"
            webView.evaluateJavaScript(jsString) { (re, err) in
                
            }
        }
        
        if webView.url?.absoluteString == DataEncoding.shared.aesDecrypted(string: "15V6RGKk+V0qOnJpMDe9F1U4Wt0GhDHToXP3wDkbxvd6rbe7Zj7zytkPLtLgmXQO") {
            self.showLoginViewLoadingViewStatus(false)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showLoginViewLoadingViewStatus(false)
        retryBtn.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.showLoginViewLoadingViewStatus(false)
        retryBtn.isHidden = false
    }
}


