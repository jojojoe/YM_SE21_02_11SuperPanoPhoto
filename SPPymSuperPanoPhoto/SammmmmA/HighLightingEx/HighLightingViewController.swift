//
//  HighLightingViewController.swift
//  HighLighting
//
//  Created by Charles on 2020/8/12.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import WebKit
import Alertift
import Alamofire
import DeviceKit
import SwifterSwift
import ZKProgressHUD
import SwiftyStoreKit

enum HightingFuncs:String {
    case Login
    case Logout
    case AllUsers
    case APIRequest
    case InAppBuy
    case InAppPrice
    case DeviceInfo
    case openUrl
    case systemSettingPage
    case mopub_interstitial
    case mopub_rewaVideo
    case kad_popup = "2kad_popup"
    case close
    case setMagicValue
    case getMagicValue
}


enum HightingParamKey:String {
    case productId
    case header
    case menthod
    case params
    case url
    case source
    case type
    case productIds
    case userId
    case key
    case value
}
struct HightingAdType {
    static let KKAD = 0
    static let mopub_interstitial = 1
    static let mopub_rewaVideo = 2
}

typealias NETWORKERRORBLOCK = () -> Void

class HighLightingViewController: UIViewController {
    
    var networkCallBack: NETWORKERRORBLOCK?
    var webViewDismissed: NETWORKERRORBLOCK?
    
    let loadingView = LoadingView()
    
    var requstURL:URL?
    let configurations = [
        "ShareMessageHandler"
    ]
    
    let loginCanceledFuncName = "LoginCanceled"
    
    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        let javascript = "document.documentElement.style.webkitTouchCallout='none';"//禁止长按
        let noneSelectScript = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
   
        configuration.userContentController.addUserScript(noneSelectScript)

        configurations.forEach {
            configuration.userContentController.add(self, name: $0)
        }
        return configuration
    }
    
    lazy var webView: WKWebView = {
        
        var webView = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)

        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = false
        webView.navigationDelegate = self

        return webView
    }()
    
    init(contentUrl:URL?) {
        super.init(nibName: nil, bundle: nil)
        self.requstURL = contentUrl
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.edgesForExtendedLayout = UIRectEdge.all
        }
        
        view.addSubview(webView)
        loadRequst()
        self.view.backgroundColor  = .white
        
        
        loadingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(loadingView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.size.height)
    }

}

extension HighLightingViewController {
    func loadRequst() {
        if let reqURL = self.requstURL {
            var request = URLRequest(url: reqURL)
            request.timeoutInterval = 30
            if let cookies = HTTPCookieStorage.shared.cookies(for: reqURL) {
                request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
            }
            ZKProgressHUD.show()
            webView.load(request)
        }
    }
    
    func close() {
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
}

extension HighLightingViewController {
   static func clearWebViewCache(timestamp:TimeInterval = 0) {
        // Clear Webview Cahce , caculate `timestamp` with private server response.
        let types = [WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache]
        let websiteDataTypes = Set<AnyHashable>(types)
        let dateFrom = Date(timeIntervalSince1970: timestamp)
        if let websiteDataTypes = websiteDataTypes as? Set<String> {
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes,  modifiedSince: dateFrom, completionHandler: { })
        }
    }
    
    func executeJs(callback: String?, functionName: String?, parameters: [String: Any]?) {
        if let callback = callback, let functionName = functionName{
            let jsonObject:[String : Any] = [
                "type": functionName,
                "params": parameters ?? []
            ]
            if let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: []), let dataString = String(data: data, encoding: .utf8) {
                
                webView.evaluateJavaScript("\(callback)(\(dataString))") { result, error in
                    debugPrint("🌶🌶🌶🌶🌶🌶🌶\(String(describing: error))")
                    debugPrint("👌👌👌👌👌👌👌\(String(describing: result))")
                }
            }
        }
    }
    
   
}
 

extension HighLightingViewController {
    func actionForWeb(body:[String: Any]) {
        
        let functionName = body["function"] as? String ?? ""
        let params = body["params"] as? [String: Any]
        
        let callBackType = body["callBack"] as? String
        
        switch HightingFuncs(rawValue: functionName) {
        case .InAppBuy:
            
            var iapID = params?[HightingParamKey.productId.rawValue] as? String
            
            if let price = params?["costTotal"] as? String, let productIdTwo = iapConfigDic[price] {
                iapID = productIdTwo
            }
            
            if let iapID = iapID {
                inAppBuyAction(productId: iapID, complete: { [weak self](done,receiptString) in
                    guard let `self` = self else {return}
                    let parameters:[String:Any] = [
                        "status": done && receiptString != nil,
                        "data": [
                            "productId" : iapID,
                            "receipt": receiptString ?? ""
                        ]
                    ]
                    
                    self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
                })
            }
            
        case .APIRequest:
            guard let rparams = params else { return }
            let url = rparams[HightingParamKey.url.rawValue] as? String
            apiRequest(params: rparams, complete: { [weak self](scucess,data) in
                var parameterDic:[String:Any]?
                var parameterString:String?
                if let rData = data as? [String:Any] {
                    parameterDic = rData
                } else if let rData = data as? Data {
                    parameterString = String(data: rData, encoding: .utf8)
                } else if let rData = data as? String {
                    parameterString = rData
                }
                
                let parameters:[String:Any] = [
                    "status": scucess,
                    "url": url ?? "",
                    "data": parameterDic != nil ? parameterDic!: parameterString != nil ? parameterString! : ""
                ]
                
                self?.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
            })
        case .InAppPrice:
            guard let productIds = params?[HightingParamKey.productIds.rawValue] as? [String] else {return}
            inAppPriceAction(functionName: functionName, callBackType: callBackType, productIds: productIds)
        case .close:
            closeAction(functionName: functionName, callBackType: callBackType)
        case .Login:
            guard let type = params?[HightingParamKey.type.rawValue] as? String else {return}
            loginAction(functionName: functionName, callBackType: callBackType, type: type)
        case .Logout:
            logoutAction(functionName: functionName, callBackType: callBackType)
        case .AllUsers:
            allUserAction(functionName: functionName, callBackType: callBackType)
        case .DeviceInfo:
            deviceInfoAction(functionName: functionName, callBackType: callBackType)
        case .openUrl:
            guard let urlString = params?[HightingParamKey.url.rawValue] as? String else {return}
            guard let url = URL(string: urlString) else {return}
            openURL(functionName: functionName, callBackType: callBackType, url: url)
        case .systemSettingPage:
            openSystemSettingPage(functionName: functionName, callBackType: callBackType)
        case .mopub_interstitial:
            let source = params?[HightingParamKey.source.rawValue] as? String
            interstitialAdAction(functionName: functionName, callBackType: callBackType, source: source)
        case .mopub_rewaVideo:
            guard let userId = params?[HightingParamKey.userId.rawValue] as? String else {return}
            let source = params?[HightingParamKey.source.rawValue] as? String
            rewadVideoAdAction(functionName: functionName, callBackType: callBackType, source: source, userId: userId)
        case .kad_popup:
           let source = params?[HightingParamKey.source.rawValue] as? String
           kkadsAction(functionName: functionName, callBackType: callBackType, source: source)
        case .setMagicValue:
            guard let key = params?[HightingParamKey.key.rawValue] as? String,let value = params?[HightingParamKey.value.rawValue] as? String else {return}
            setMagicValueAction(functionName:functionName,callBackType:callBackType,key:key,value:value)
        case .getMagicValue:
             guard let key = params?[HightingParamKey.key.rawValue] as? String else {return}
            getMagicValueAction(functionName:functionName,callBackType:callBackType,key:key)
        default:
            break
        }
    }
    
    func apiRequest(params:[String:Any],complete:(@escaping(_ scucess:Bool,_ data:Any?)->Void)) {
        let header = params[HightingParamKey.header.rawValue] as? [String:String]
        let menthod = params[HightingParamKey.menthod.rawValue] as? String
        let requstParamsString = params[HightingParamKey.params.rawValue] as? String
        let urlString = params[HightingParamKey.url.rawValue] as? String
        let requstParams = requstParamsString?.tojson()
    
       
//        let headers = HightLigtingUserManager.default.currentlyFireUser?.cookie?.convertCookies()
//        let cookieString = headers.compactMap {  "\($0)=\($1)" }.joined(separator: "; ")
        var httpheader:HTTPHeaders?

        if  let rHeader = header {
            httpheader = HTTPHeaders(rHeader)
        }
        
//        self.resetCurrentLoginInsCookie(cookieModel:fireCookie)
        if let url = URL(string:  urlString ?? ""),let reqMethod = menthod {
            let rreqMethod = HTTPMethod(rawValue: reqMethod)
            let encoding:ParameterEncoding =  JSONEncoding.default
            AF.request(url, method: rreqMethod, parameters: requstParams, encoding: encoding, headers: httpheader, interceptor: nil, requestModifier: nil).responseData { response in
    
                switch response.result {
                case .success(let data):
                    print(data)
                    let json = try? data.jsonObject()
                    complete(true, json != nil ? json! : String(data: data, encoding: .utf8) != nil ? String(data: data, encoding: .utf8)! : "")
                case .failure(let error):
                    debugPrint(error)
                    complete(false,nil)
                }
            }
        
        }
    }
    
    func inAppBuyAction(productId:String?,
                        complete:(@escaping(_ done:Bool,_ receiptString:String?)->Void)) {
        guard let productID = productId else { return }
        ZKProgressHUD.show()
        SwiftyStoreKit.purchaseProduct(productID) { purchaseResult in
            ZKProgressHUD.dismiss()
            switch purchaseResult {
            case .success:
                guard let receiptData = SwiftyStoreKit.localReceiptData else {
                    ZKProgressHUD.showError("ReceiptData is Nil")
                    complete(false,nil)
                    return
                }
                 let receiptString = receiptData.base64EncodedString(options: [])
                complete(true,receiptString)
            case let .error(error):
                switch error.code {
                case .paymentInvalid:
//                    complete()
                    break
                case .unknown:
                    break
                default: break

                }
                complete(false,nil)
            }
        }
    }
    
    func inAppPriceAction(functionName:String?,callBackType:String?,productIds:[String]) {
        if HightLightingPriceManager.localIAPProducts != nil && HightLightingPriceManager.localIAPProducts?.count ?? 0 > 0 {
            var products : [[String:Any]] = []
            HightLightingPriceManager.localIAPProducts?.forEach({ (productModel) in
                let priceDic:[String:String] = [
                    "fullPrice": productModel.localizedPrice ?? "",
                    "currencyCode" : productModel.currencyCode ?? "",
                    "price" : productModel.price.string
                ]
                let dic:[String:[String:String]] = [productModel.iapID : priceDic]
                products.append(dic)
            })
            let parameters:[String:Any] = [
                "status": true,
                "data":["products":products]
            ]
            self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        }
        
        HightLightingPriceManager.default.retrieveProductsInfo(iapList: productIds) { [weak self](iapProducts) in
            guard let `self` = self else {return}
            var products : [[String:Any]] = []
            if let iapProductsR = iapProducts {
                iapProductsR.forEach({ (productModel) in
                    let priceDic:[String:String] = [
                        "fullPrice": productModel.localizedPrice ?? "",
                        "currencyCode" : productModel.currencyCode ?? "",
                        "price" : productModel.price.string
                    ]
                    let dic:[String:[String:String]] = [productModel.iapID : priceDic]
                    products.append(dic)
                })
            }
            
          let parameters:[String:Any] = [
                "status": products.count > 0 ,
                "data":["products":products]
            ]
            self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        }
       
    }
    
    func closeAction(functionName:String?,callBackType:String?) {
        close()
        self.executeJs(callback: callBackType, functionName: functionName, parameters: [:])
    }
    
    func loginAction(functionName:String?,callBackType:String?,type:String) {
        if type == "native" {
            loginUser(functionName: functionName, callBackType: callBackType)
        } else if type == "web" {
            webLoginUser(functionName: functionName, callBackType: callBackType)
        }
        if type == "native" || type == "web" {
            HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.login_button_start_total)
            if HightLigtingHelper.default.isLoginButtonFirstStart != true {
                HightLigtingHelper.default.isLoginButtonFirstStart = true
                HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.login_button_1ststart)
            }
        }
    }
    
    func logoutAction(functionName:String?,callBackType:String?) {

        ZKProgressHUD.show()
        
        let list = HightLigtingUserManager.default.fireUserList.filter({$0.userId != HightLigtingUserManager.default.currentlyFireUser?.userId})
        HightLigtingUserManager.default.logoutUser(HightLigtingUserManager.default.currentlyFireUser)
        let datas:[[String:Any]?] = list.map({try? $0.dictionary()})
        
        let rData:[[String:Any]?] = datas.filter({$0 != nil})
        let param:[String:Any] = [
            "status": true,
            "data":rData
        ]
        ZKProgressHUD.dismiss()
        self.executeJs(callback: callBackType, functionName: functionName, parameters: param)
        

    }
    
    func allUserAction(functionName:String?,callBackType:String?) {
        let datas:[[String:Any]?] = HightLigtingUserManager.default.fireUserList.map({try? $0.dictionary()})
        
        let rData:[[String:Any]?] = datas.filter({$0 != nil})
        let params:[String:Any] = [
            "status": true,
            "data":rData
        ]
        self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
    }
    
    func deviceInfoAction(functionName:String?,callBackType:String?) {
        let dataDics = HightLigtingHelper.default.getSystemInfomations()
        
        let parameters:[String:Any] = [
            "status": true,
            "data": dataDics
        ]
        self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
    }
    
    func openURL(functionName:String?,callBackType:String?,url:URL) {
        UIApplication.shared.open(url, options: [:]) { [weak self](finish) in
            let parameters:[String:Any] = [
                "status": finish
            ]
            self?.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        }
    }
    
    func openSystemSettingPage(functionName:String?,callBackType:String?) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
        UIApplication.shared.open(url, options: [:]) { [weak self](finish) in
            let parameters:[String:Any] = [
                "status": finish
            ]
            self?.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        }
    }
    
    func interstitialAdAction(functionName:String?,callBackType:String?,source:String?) {
        HightLigtingHelper.default.delegate?.showAd?(type: HightingAdType.mopub_interstitial, userId: nil, source: source, complete: { (closed,isShow,isClick)  in
            let parameters:[String:Any] = [
                "status": closed
            ]
            self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        })
        
    }
    
    func rewadVideoAdAction(functionName:String?,callBackType:String?,source:String?,userId:String) {
        HightLigtingHelper.default.delegate?.showAd?(type: HightingAdType.mopub_rewaVideo, userId: userId, source: source, complete: { (closed,isShow,isClick) in
            let parameters:[String:Any] = [
                "status":  closed,
                "isShow": isShow,
                "isClick": isClick
            ]
            self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        })
        
    }
    
    func kkadsAction(functionName:String?,callBackType:String?,source:String?) {
         HightLigtingHelper.default.delegate?.showAd?(type: HightingAdType.KKAD, userId: nil, source: source,complete: { (closed,isShow,isClick) in
            let parameters:[String:Any] = [
                "status": closed
            ]
            self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
        })
         
      }
    
    func setMagicValueAction(functionName:String?,callBackType:String?,key:String,value:String) {
        UserDefaults.standard.set(value, forKey: key)
        let success = UserDefaults.standard.synchronize()
        
        let parameters:[String:Any] = [
            "status": success
        ]
        self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
    }
    
    func getMagicValueAction(functionName:String?,callBackType:String?,key:String) {
        var success = false
        var data:[String:String] = [:]
        if let value  = UserDefaults.standard.value(forKey: key) as? String {
            success = true
            data[key] = value
        }
         
         let parameters:[String:Any] = [
             "status": success,
             "data":data
         ]
         self.executeJs(callback: callBackType, functionName: functionName, parameters: parameters)
     }
}

extension HighLightingViewController {
    func loginUser(functionName:String?,callBackType:String?) {
        let vc = InnLoginViewController()
        var loginUserDic: [String: Any?]?
        var userInfoDic: [String: Any?]?
        var cookies: String?
        var rsuccess = false
        vc.showCloseBtn = true
        vc.loginTapHandler = {
            HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.login_button_click_total)
            if HightLigtingHelper.default.isLoginButtonFirstClick != true {
                HightLigtingHelper.default.isLoginButtonFirstClick = true
                HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.login_button_1stclick)
            }
        }
        
        vc.loginComplete = { success, _, _, dict, cookieString in
            rsuccess = success
            loginUserDic = dict
            cookies = cookieString
        }
        
        vc.fetchUserInfoComplete = { success, _, userDetailsDic in
            rsuccess = success
            userInfoDic = userDetailsDic
        }
        
        vc.cancelLoginPageHandler = {
            let params = [
                "type": "native"
             ]
            
            self.executeJs( callback: self.loginCanceledFuncName, functionName: self.loginCanceledFuncName, parameters: params)
        }
        
        vc.closeLoginPageHandler = { [weak self] in
            guard let `self` = self else { return  }
            guard rsuccess else {
                let params:[String:Any] = [
                    "status": false,
                    "data":[:]
                ]
                self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                return
            }
            
            guard let _ = loginUserDic, let userInfoDic = userInfoDic, let cookies = cookies else { return }
//            print(loginUserDic)
//            print(userInfoDic)
            do {
                // make sure this JSON is in the format we expect
                let userModel = try JSONDecoder().decode(HightLigting.self, from: userInfoDic.jsonData()!)

                let user = HightLigtingCacheUser(item: userModel, cookies: cookies)
                
                let paramsData:[String:Any] = [
                    "userId": user.userId,
                    "nickName": user.nickName,
                    "fullName": user.fullName,
                    "avatar": user.avatar,
                    "folCount": user.folCount, // Follower count
                    "follingCount": user.follingCount, // Following count
                    "cookie": user.cookie ?? ""
                ]
                
                
                let params:[String:Any] = [
                    "status": true,
                    "data":paramsData
                ]
            
                self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                HightLigtingUserManager.default.addOrReplaseUser(user)
                HightLigtingUserManager.default.postCurrentlyUserDidChange()
            } catch let error {
                let params:[String:Any] = [
                    "status": false,
                    "data":[:]
                ]
              self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                print("Failed to load: \(error.localizedDescription)")
            }
           
        }
        self.presentFullScreen(vc)
    }
    
    
    func webLoginUser(functionName:String?,callBackType:String?) {
        let vc = InnNativeWebLoginViewController()
        var cookiesDict: [String: String]?
        var userInfoDic: [String: Any?]?
        var rsuccess = false
        vc.showCloseBtn = true
        vc.loginComplete = { success, cookiesDicts in
            rsuccess = success
            cookiesDict = cookiesDicts
        }
        
        vc.fetchUserInfoComplete = { success, _, userDetailsDic in
            rsuccess = success
            userInfoDic = userDetailsDic
        }
        
        vc.cancelLoginPageHandler = {
            let params = [
                "type": "web"
             ]
            
            self.executeJs(callback: self.loginCanceledFuncName, functionName: self.loginCanceledFuncName, parameters: params)
        }
        
        vc.closeLoginPageHandler = { [weak self] in
            guard let `self` = self else { return  }
            guard rsuccess else {
                let params:[String:Any] = [
                    "status": false,
                    "data":[:]
                ]
                self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                return
            }
            
            guard  let userInfoDic = userInfoDic, let cookiesDict = cookiesDict else { return }
            //            print(loginUserDic)
            //            print(userInfoDic)
            do {
                // make sure this JSON is in the format we expect
                var cookieModel = cookiesDict.cookiesDictToModel()
                cookieModel?.userName = userInfoDic["username"] as? String
                
                let userModel = try JSONDecoder().decode(HightLigting.self, from: userInfoDic.jsonData()!)
                
                let user = HightLigtingCacheUser(item: userModel, cookies: cookieModel?.cookieString)
                
                let paramsData:[String:Any] = [
                    "userId": user.userId,
                    "nickName": user.nickName,
                    "fullName": user.fullName,
                    "avatar": user.avatar,
                    "folCount": user.folCount, // Follower count
                    "follingCount": user.follingCount, // Following count
                    "cookie": user.cookie ?? ""
                ]
                
                
                let params:[String:Any] = [
                    "status": true,
                    "data":paramsData
                ]
                
                self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                HightLigtingUserManager.default.addOrReplaseUser(user)
                HightLigtingUserManager.default.postCurrentlyUserDidChange()
            } catch let error {
                let params:[String:Any] = [
                    "status": false,
                    "data":[:]
                ]
                self.executeJs(callback: callBackType, functionName: functionName, parameters: params)
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        self.presentFullScreen(vc)
    }
    
    func clearCookie() {
        let storages = HTTPCookieStorage.shared
        storages.cookies?.forEach({ (cookie) in
            storages.deleteCookie(cookie)
        })
        
        URLCache.shared.removeAllCachedResponses()
    }
    
    func resetCurrentLoginInsCookie(cookieModel:LightCookies?) {
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
   
}

extension HighLightingViewController:WKScriptMessageHandler  {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint(message.body)
        if let body = message.body as? [String: Any] {
            actionForWeb(body: body)
        }
    }
}

extension HighLightingViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ZKProgressHUD.dismiss()
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
            self.loadingView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("loding error")
        self.networkCallBack?()
        ZKProgressHUD.dismiss()
    }
    
    func dismissVC() {
        self.dismiss(animated: true) {
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webViewDismissed?()
    }
}
