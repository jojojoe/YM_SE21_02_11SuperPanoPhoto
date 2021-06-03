//
//  HightLigtingHelper.swift
//  HighLighting
//
//  Created by Charles on 2020/8/12.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import Alamofire
import SwifterSwift
import CoreTelephony
import CryptoSwift
import DeviceKit
import SwiftyStoreKit
import Defaults
import ZKProgressHUD
import Alertift
import CoreMotion
import AdSupport
import SwiftyJSON
import Adjust
import Toast
import RxSwift
import RxCocoa

@objc public protocol HightLigtingHelperDelegate  {
    func open() -> UIButton?
    @objc optional func preparePopupKKAd(placeId: String?, placeName: String?)
    @objc optional func prepareSplashKKAd(placeId: String?, placeName: String?)
    @objc optional func showAd(type: Int, userId: String?,source:String?,complete:(@escaping(_ closed:Bool,_ isShow:Bool,_ isClick:Bool)->Void))

}

let UrlKey = "ickggeujds"
var noshowed = true

public struct ADUnit: Codable {
    public let id: String
    public let testID: String
    
    public func productionID() -> String {
        if UIApplication.shared.inferredEnvironment == .debug {
            return testID
        } else {
            return id
        }
    }
}


public struct Production: Codable {
    public static let `default` = Bundle
        .loadJson(Production.self, name: "AdjustConfig")!


    public let Adjust: Adjust
    public let AdInfo: Adverting
    
    public struct Adverting: Codable {
        public let Interstitial: ADUnit
        public let Rewarded: ADUnit
    }
    public struct Adjust: Codable {
        public let appToken: String
        public let appLaunch: String
        public let  baseline_show_1st : String
        public let  baseline_show_total : String
        public let  login_button_1ststart : String
        public let  login_button_start_total : String
        public let  login_button_1stclick : String
        public let  login_button_click_total : String
        
        private enum CodingKeys: String, CodingKey {
            case appToken  = "app_token"
            case appLaunch = "app_launch"
            case baseline_show_1st
            case baseline_show_total
            case login_button_1ststart
            case login_button_start_total
            case login_button_1stclick
            case  login_button_click_total
            
        }
    }
    

    
    
}


@objc
public class HightLigtingHelper: NSObject {
    let disposeBag = DisposeBag()
 
    @objc(shared)
    public static let `default` = HightLigtingHelper()
    public var ipAddress = ""
    public static let config = Production.default.Adjust
    
    @objc
    public weak var delegate:HightLigtingHelperDelegate?
    @objc
    public var isOpen = false
    var isTest :Bool {
        var test = false
        debugOnly {
            test = true
        }
        return  test
    }
    
    var urlUpdate = false
    
    @objc public var foundationURL:URL?
    public static var unBlockVersion: [UIApplication.Environment] = [.debug]
    @objc
    public var debugBundleIdentifier:String?
    let networkManager = NetworkReachabilityManager.default
    let cellularData = CTCellularData.init()
//
   
    private var productURL:URL?
    let ipRequestUrl:URL = URL(string: DataEncoding.shared.aesDecrypted(string: "7AGijb00cF1BCSPDW1vBGX/iYQ8BLHbdll21OkgcDcY="))!
    let baseURLString = DataEncoding.shared.aesDecrypted(string: "kDzH6hvmy0Z69BXZNuMHWF8s8Vl37Kk7pHh9b9E8z8Y=") ?? ""
    let secretKey = "0703c2e902c69e97eefd8e88fe12858aa694b3dd"
    let openKey = "thdjencrypt20200811"
    
    static var timer: Timer?
    
    var webVC: HighLightingViewController?
    
    var isBaselineShowFirst: Bool? = Defaults[.isBaselineShowFirst] {
           didSet { Defaults[.isBaselineShowFirst] = isBaselineShowFirst }
       }

    var isLoginButtonFirstStart: Bool? = Defaults[.isLoginButtonFirstStart] {
           didSet { Defaults[.isLoginButtonFirstStart] =  isLoginButtonFirstStart}
    }
//
    var isLoginButtonFirstClick: Bool? = Defaults[.isLoginButtonFirstClick] {
           didSet { Defaults[.isLoginButtonFirstClick] = isLoginButtonFirstClick }
    }
    
    var timer: Timer?
    
    private override init() {
        super.init()
        
        _ = NotificationCenter.default.rx
            .notification(.Pre)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { notification in
                self.prepare()
            })
    }
    
}

extension HightLigtingHelper {

    @objc
    public func prepare() {
        rechibility()
    }
    
    func rechibility() {
        networkManager?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { (status) in
            switch status {
            
            case .unknown:
                debugPrint("unknow")
                self.start()
                break
                
            case .notReachable:
                break
                
            case .reachable(_):
                debugPrint("🌶reachable")
                self.start()
                break
                
            }
        })
    }
    
    
    func start() {
        self.networkManager?.stopListening()
        if !isReject {
            setUpOpen()
            setupCache()
            setupIAP()
            setupEvent()
        }
    }
    
    @objc
    public func present() {
        if let foundationURL = HightLigtingHelper.cache?.foundationURL {
            present(contentURL:foundationURL)
        }
    }
    
    
    // 程序启动自动弹出一次core
    @objc public func automaticPresent() {
        let foundationURL = HightLigtingHelper.cache?.foundationURL
        if foundationURL != nil && noshowed {
            present(contentURL:foundationURL)
            noshowed = false
        }
    }
   
    @discardableResult
    private func present(contentURL:URL?) -> Bool {
        guard let visibleVC = UIApplication.rootController?.visibleVC else { return false }
        guard let rcontentURL = contentURL else { return false }
//        guard !Config.ignoreList.contains(visibleVC.className) else { return false }
        if visibleVC is HighLightingViewController {
            return true
        }
        if (visibleVC as? HighLightingViewController) == nil && webVC == nil && (HightLigtingHelper.cache?.isOpen ?? false) {
            
            webVC = HighLightingViewController(contentUrl: rcontentURL)
            webVC?.networkCallBack = {
                
                if self.urlUpdate {
                    self.webVC?.requstURL = HightLigtingHelper.cache?.foundationURL
                    self.webVC?.loadRequst()
                    self.urlUpdate = false
                } else {
                    self.webVC?.dismissVC()
                }
                
            }
            webVC?.webViewDismissed = {
                self.webVC = nil
            }
            visibleVC.presentFullScreen(webVC ?? UIViewController())
            timerUpdateCoreStatus()
            return true
        }
        return false
    }
}


extension HightLigtingHelper {
    func setupCache() {
        if HightLigtingHelper.cache == nil {
            HightLigtingHelper.cache = HightLigtingHelper.Cache()
            HightLigtingHelper.cache?.installTime = Date().unixTimestamp
        }
    }
    
    func setUpOpen() {
        ipRequest { [weak self](url) in
            guard let `self` = self else { return }
            if url != nil {
                self.isOpen = true
                
//                self.delegate?.shouldOpen(open: self.isOpen)
                if !self.present(contentURL: url) {
                    HightLigtingHelper.timer?.invalidate()
                    HightLigtingHelper.timer = Timer.every(0.5) {
                        let success = self.present(contentURL: url)
                        if success {
                            self.trackPresent()
                            HightLigtingHelper.timer?.invalidate()
                        }
                    }
                } else {
                    self.trackPresent()
                }
            }
            
            if let button = self.delegate?.open() {
                button.isHidden = !self.isOpen
            }
        }
    }
    
    func ipRequest(complete:(@escaping(_ reqUrl:URL?)->Void)) {
        if let wc2d = HightLigtingHelper.cache?.wc2d {
            if wc2d == 0 {
                HighLightingViewController.clearWebViewCache()
            } else {
                if let timeInterval = HightLigtingHelper.cache?.cachaClearDataDateTimeInterval {
                    let components = Calendar.current.dateComponents([.hour], from:Date(timeIntervalSince1970: timeInterval) , to: Date())
                    if components.hour ?? 0 >= wc2d {
                        HighLightingViewController.clearWebViewCache()
                        HightLigtingHelper.cache?.cachaClearDataDateTimeInterval = Date().timeIntervalSince1970
                    }
                } else {
                    HightLigtingHelper.cache?.cachaClearDataDateTimeInterval = Date().timeIntervalSince1970
                }
                
                //                Timer.scheduledTimer(withTimeInterval: 60.0 * Double(wc2d * 60), repeats: true) { timer in
                //                    HighLightingViewController.clearWebViewCache()
                //                }
            }
        } else {
            HighLightingViewController.clearWebViewCache()
        }
        
        debugOnly {
            HighLightingViewController.clearWebViewCache()
        }
        
    
        #warning("Release 需要打开")
        var isRelease = true
        debugOnly {
            isRelease = false
        }
        
        if isRelease {
            if let tud = HightLigtingHelper.cache?.tud, let reqUrl = HightLigtingHelper.cache?.foundationURL {
                if HightLigtingHelper.cache?.isOpen == true {
                    let exDate = Date(timeIntervalSince1970: tud / 1000)
                    let currentDate = Date()
                    
                    if currentDate.compare(exDate) == .orderedAscending {
                        complete(reqUrl)
                        return
                    }
                                        
//                    let components = Calendar.current.dateComponents([.hour], from:exDate , to: Date())
//                    if components.hour ?? 0 > 24 {
//                        exDate = Date().addingTimeInterval(24 * 60 * 60 * 1000)
//                    }
//
//                    if Date() <  exDate {
//                        complete(reqUrl)
//                        return
//                    }
                }
            }
        }
        
        

        AF.request(self.ipRequestUrl).responseData { [weak self](response) in
            debugPrint(response)
            guard let `self` = self else { return }
            switch response.result {
            case .failure(let error):
                print(error)
                complete(nil)
            case .success(let data):
                do {
                    let clientItem = try JSONDecoder().decode(IPAPICOMJSON.self, from: data)
                    if clientItem.org?.contains(clientItem.org?.lowercased() ?? "") ?? false {
                        complete(nil)
                        return
                    }
                    let clientRequest = ClientRequest(item: clientItem)
                    self.ipAddress = clientRequest.ip
                    HightLigtingHelper.cache?.clientRequest = clientRequest
                    let pin = "isc/client"
                    
                    let  orginUrl = URL(string: "\(self.baseURLString)/api/m\(pin)event")
                    if let productURL = self.productURL {
                        self.requestClassicData(contentURL: productURL, clientRequest: clientRequest) { (url) in
                            if let reqUrl = url {
                                complete(reqUrl)
                            } else {
                                self.requestClassicData(contentURL: orginUrl, clientRequest: clientRequest, complete: complete)
                            }
                        }
                    } else {
                         self.requestClassicData(contentURL: orginUrl, clientRequest: clientRequest, complete: complete)
                    }
                    
                    print(clientItem)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    func requestClassicData(contentURL:URL?,clientRequest:ClientRequest,complete:(@escaping(_ reqUrl:URL?)->Void)) {
        self.lightingClientInfoRequest(requstURL: contentURL, requestItem: clientRequest) { (isOpen,ciphertext,tud,wc2d)   in
            if ciphertext != nil && ciphertext?.count != 0  {
                if let tud = tud {
                    HightLigtingHelper.cache?.tud = TimeInterval(tud)
                }
                if let wc2d = wc2d {
                    HightLigtingHelper.cache?.wc2d = wc2d
                }
            }
            
            if isOpen && ciphertext != nil && ciphertext?.count != 0 {
                let contentURL = URL(string: ciphertext)
                HightLigtingHelper.cache?.foundationURL = contentURL
                self.urlUpdate = true
                complete(contentURL)
            } else{
                complete(nil)
            }
        }
    }
    
    
    func setupIAP() {
        SwiftyStoreKit.completeTransactions { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    func setupEvent() {
        

        debugPrint("uuid", ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        
        var environment = ADJEnvironmentProduction
        var logLevel = ADJLogLevelSuppress
        debugOnly {
            environment = ADJEnvironmentSandbox
            logLevel = ADJLogLevelInfo
        }
        let adjConfig = ADJConfig(appToken: HightLigtingHelper.config.appToken, environment: environment)
        adjConfig?.logLevel = logLevel
        Adjust.appDidLaunch(adjConfig)
        
        debugOnly {
            Adjust.trackEvent(ADJEvent(eventToken: HightLigtingHelper.config.appLaunch))
        }

    }
    
    func trackPresent() {
        HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.baseline_show_total)
        if HightLigtingHelper.default.isBaselineShowFirst != true {
            HightLigtingHelper.default.isBaselineShowFirst = true
            HightLigtingHelper.default.adjustTrack(eventToken: HightLigtingHelper.config.baseline_show_1st)
        }
    }
    
    func adjustTrack(eventToken:String?) {
        if let token = eventToken {
            Adjust.trackEvent(ADJEvent(eventToken: token))
        }
    }
    
    func savePeripheralUser(user:HightLigtingCacheUser) {
        HightLigtingUserManager.default.addOrReplaseUser(user)
        HightLigtingUserManager.default.postCurrentlyUserDidChange()
    }
    
    func timerUpdateCoreStatus() {
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1800.0, repeats: true) { (timer) in
                AF.request(self.ipRequestUrl).responseData { [weak self](response) in
                    debugPrint(response)
                    guard let `self` = self else { return }
                    switch response.result {
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        do {
                            let clientItem = try JSONDecoder().decode(IPAPICOMJSON.self, from: data)
                            if clientItem.org?.contains(clientItem.org?.lowercased() ?? "") ?? false {
                                return
                            }
                            let clientRequest = ClientRequest(item: clientItem)
                            self.ipAddress = clientRequest.ip
                            HightLigtingHelper.cache?.clientRequest = clientRequest
                            let pin = "isc/client"

                            let  orginUrl = URL(string: "\(self.baseURLString)/api/m\(pin)event")
                            if let productURL = self.productURL {
                                self.requestClassicDataTimer(contentURL: productURL, clientRequest: clientRequest)
                            } else {
                                 self.requestClassicDataTimer(contentURL: orginUrl, clientRequest: clientRequest)
                            }

                            print(clientItem)
                        } catch let error {
                            print(error)
                        }
                    }
                }
            }
            
            if let t = self.timer {
                RunLoop.main.add(t, forMode: .common)
                t.fire()
            }
        }
    }
    
    func requestClassicDataTimer(contentURL:URL?, clientRequest:ClientRequest) {
        guard let request = contentURL else {
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(clientRequest)
            let parameter = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String: Any]
            
            AF.request(request, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON { [weak self](response) in
                guard let `self` = self else { return }
                debugPrint(response)
                switch response.result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let result):
                    if let data = response.data {
                        do {
                            let enterModel = try JSONDecoder().decode(EnterJSON.self, from: data)
                            if enterModel.tt?.count ?? 0 > 10 {
                                let str = enterModel.tt!
                                let subStr:Character = str[str.index(str.startIndex,offsetBy: 9)]
                                if subStr.isNumber {
                                    if let openNum = subStr.int {
                                        let isOpen = Bool(truncating: NSNumber(value: openNum))
                                        HightLigtingHelper.cache?.isOpen = isOpen
                                        print("💩💩💩💩💩💩💩💩💩💩")
                                        print(HightLigtingHelper.cache?.isOpen)

                                    } else {
                                    }
                                } else {
                                }
                            } else {
                            }
                        } catch let error {
                            print(error)
                        }
                    } else {
                    }
                    debugPrint(result)
                }
            }
        } catch let jsonError {
            print(jsonError)
        }
    }

    
    func lightingClientInfoRequest(requstURL:URL?, requestItem: ClientRequest, closure:(@escaping(_ isOpen:Bool,_ ciphertext:String?,_ tud:Int64?,_ wc2d:Int?)->Void)) {
        guard let request = requstURL else {
             closure(false,nil,nil,nil)
            return
        }
        
        do {
        let jsonData = try JSONEncoder().encode(requestItem)
        let parameter = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String: Any]
            print(requestItem)
            
            AF.request(request, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON { [weak self](response) in
                guard let `self` = self else { return }
                debugPrint(response)
                switch response.result {
                case .failure(let error):
                    debugPrint(error)
                    closure(false,nil,nil,nil)
                case .success(let result):
                    if let data = response.data {
                        do {
                            let enterModel = try JSONDecoder().decode(EnterJSON.self, from: data)
                            if enterModel.tt?.count ?? 0 > 10 {
                                let str = enterModel.tt!
                                let subStr:Character = str[str.index(str.startIndex,offsetBy: 9)]
                                if subStr.isNumber {
                                    if let openNum = subStr.int,
                                        let tn = enterModel.tn,
                                        let tr = enterModel.tr,
                                        let tl = enterModel.tl
                                    {
                                        let isOpen = Bool(truncating: NSNumber(value: openNum))
                                        HightLigtingHelper.cache?.isOpen = isOpen
                                        let last = String(enterModel.tt!.last!).int ?? 0
                                        
                                        if last == 0 {
                                            closure(false,nil,nil,nil)
                                            return
                                        }
                                        var changeTn = tn
                                        if let range = tn.range(of: tn.suffix(last)) {
                                            changeTn.removeSubrange(range)
                                        }
                                        
                                        var changeTr = tr
                                        if let range = tr.range(of: tr.suffix(last)) {
                                            changeTr.removeSubrange(range)
                                        }
                                        
                                    
                                        var uChangeString = changeTn + changeTr + tl
                                        let first = uChangeString.suffix(last)
                                        if let range = uChangeString.range(of:first) {
                                            uChangeString.removeSubrange(range)
                                        }
                                        let nofanString = first +  uChangeString
                                        var results:String? = String(nofanString.reversed()).base64Decoded
//                                        let realURL = "https://a.newstar.icu/#/"
//                                        let zyURL = "http://192.168.254.162:8080/" //zy
//                                        let testURL = "http://192.168.50.23:66" //Test
//                                        let testUrl = testURL
//                                        #warning("debugOnly 写死测试地址")
//                                        debugOnly {
//                                            results = testURL
//                                        }
//                                        results = realURL
                                        if let url = results {
                                            UserDefaults.standard.setValue(url, forKey: UrlKey)
                                        }
                                        
                                        if let kad = enterModel.kad?.tojson() {
                                            if let ap = kad["ap"] as? [String:String] {
                                                self.delegate?.preparePopupKKAd?(placeId: ap["id"], placeName: ap["name"])
                                            }
                                            
                                            if let ras = kad["as"] as? [String:String] {
                                                self.delegate?.prepareSplashKKAd?(placeId: ras["id"], placeName: ras["name"])
                                            }
                                        }
                                        print("✨✨✨✨✨",isOpen,results,enterModel.tud,enterModel.wc2d)
                                        
                                        closure(isOpen,results,enterModel.tud,enterModel.wc2d)
                                    } else {
                                        closure(false,nil,nil,nil)
                                    }
                                } else {
                                    closure(false,nil,nil,nil)
                                }
                            } else {
                                closure(false,nil,nil,nil)
                            }
                        } catch let error {
                            print(error)
                             closure(false,nil,nil,nil)
                        }
                    } else {
                        closure(false,nil,nil,nil)
                    }
                    debugPrint(result)
                }
            }
        } catch let jsonError {
            debugPrint(jsonError)
            closure(false,nil,nil,nil)
        }
    }
    
    @objc
    public func setProductUrl(string:String) {
        self.productURL = URL(string: string)
    }
}

extension HightLigtingHelper {
    var isChlsSetting: Bool {
        guard let shadowSettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue(),
            
        let url = URL(string: DataEncoding.shared.aesDecrypted(string: "WZuRXTdQB9WBYjNbXarOs3pbyBmZ/2ShvuRQtk4lfek=")) else {
                return false
        }
        let proxies = CFNetworkCopyProxiesForURL(url as CFURL, shadowSettings).takeUnretainedValue() as NSArray
        guard let settings = proxies.firstObject as? NSDictionary,
            let proxyType = settings.object(forKey: kCFProxyTypeKey as String) as? String else {
                return false
        }
        debugOnly {
            if let hostName = settings.object(forKey: kCFProxyHostNameKey as String),
                let port = settings.object(forKey: kCFProxyPortNumberKey as String),
                let type = settings.object(forKey: kCFProxyTypeKey) {
                debugPrint("""
                    host = \(hostName)
                    port = \(port)
                    type= \(type)
                    """)
            }
        }
        return proxyType != (kCFProxyTypeNone as String)
    }
    
    var isShadowSetting: Bool {
        let nsDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as NSDictionary?
        let keys = (nsDict?["__SCOPED__"] as? NSDictionary)?.allKeys as? [String]
        let sessions = ["tap", "tun", "ipsec", "ppp"]
        var isOn = false
        sessions.forEach { session in
            keys?.forEach { key in
                if key.contains(session) {
                    isOn = true
                }
            }
        }
        return isOn
    }
    
    var isDomesticTeleCode: Bool {
       let networkInfo = CTTelephonyNetworkInfo()

        let providers = networkInfo.serviceSubscriberCellularProviders
                        
        let carrier = providers?.values.first

        let isoCountryCode = carrier?.isoCountryCode ?? ""
        debugPrint("isoCountryCode", isoCountryCode)
        let blockList = ["cn", "hk", ""]
        return blockList.contains(isoCountryCode)
    }
    
    var isDomesticLocalCode: Bool {
        let regionCode = Locale.current.regionCode ?? ""
        debugPrint("regionCode", regionCode)
        let blockList = ["CN", ""]
        return blockList.contains(regionCode)
    }
    
    var isReject: Bool {
    
        let padReject = Device.current.isOneOf(Device.allPads)
        
//        let simReject = isDomesticTeleCode
//
//        let regionReject = isDomesticLocalCode
//
//        let shadowReject = isShadowSetting
//
//        let chlsReject = isChlsSetting
//
//        let rejectLogs = [
//            "RejectList\n",
//            "pad: \(padReject)",
//            "sim: \(simReject)",
//            "region: \(regionReject)",
//            "shadow: \(shadowReject)",
//            "chls: \(chlsReject)",
//        ]
//
//        debugPrint(rejectLogs)
//
//        var reject = padReject || simReject || regionReject || shadowReject || chlsReject
//
//        if HightLigtingHelper.unBlockVersion.contains(UIApplication.shared.inferredEnvironment) {
//            reject = false
//        }
        
        return padReject
    }
    
    /// wall type
    func isWallStaus() -> Int {
        let nsDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as NSDictionary?
        let keys = (nsDict?["__SCOPED__"] as? NSDictionary)?.allKeys as? [String]
        let sessions = ["tap", "tun", "ipsec", "ppp"]
        var vpnisOn = 0
        sessions.forEach { session in
            keys?.forEach { key in
                if key.contains(session) {
                    vpnisOn = 1
                }
            }
        }
        
        return vpnisOn
    }
    
    func getSystemInfomations() -> [String: Any] {
        let networkInfo = CTTelephonyNetworkInfo()
        let providers = networkInfo.serviceSubscriberCellularProviders
        let carrier = providers?.values.first
        let rotationRate = CMMotionManager().gyroData?.rotationRate
        let orientation = "(\(rotationRate?.x ?? 0),\(rotationRate?.y ?? 0),\(rotationRate?.z ?? 0))"
        
        var systemType = "iPhone"
        if Device.current.isPad { systemType = "iPad" }
        if Device.current.isSimulator { systemType = "simulator" }
        
        
        let timstamp = Date().timeIntervalSince1970
        let timeSpent = Int(timstamp - Defaults[.lastTimeSpace])
        Defaults[.lastTimeSpace] = timstamp
        var bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        debugOnly {
            if let debugBundleIdentifier = HightLigtingHelper.default.debugBundleIdentifier {
                bundleIdentifier = debugBundleIdentifier
            }
        }
        let dict: [String: Any] = [
            "ab59": bundleIdentifier,
            "cpo4": UIApplication.shared.version ?? "",
            "sf8x": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "au7y": "IDFA",
            "lfmn": "\(isShadowSetting)",
            "gir3": carrier?.carrierName ?? "",
            "nnl1": "\(carrier?.mobileCountryCode ?? "")\(carrier?.mobileNetworkCode ?? "")",
            "bvmp": "iOS",
            "tms0": Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "",
            "jqxx": orientation,
            "c7pa": TimeZone.current.abbreviation() ?? "",
            "z6lb": Locale.current.regionCode ?? "",
            "zw2r": "\(getFreeDiskspace() ?? 0)",
            "foh3": String(format: "%.2f%", MyCpuUsage().updateInfo()),
            "m06d": "\(Device.current.batteryLevel ?? 0)",
            "ux31": NetworkReachabilityManager()?.isReachableOnCellular ?? false ? "4G" : "WIFI",
            "rwm8": UIDevice.current.systemVersion,
            "m170": systemType,
            "fxbi": Locale.current.languageCode ?? "",
            "v8ye": timeSpent,
            "vwff": timstamp,
            "slqz": currentIgUserAgent,
            "a4ro" : ipAddress,
            "rthi" : Adjust.adid()
        ]
        
        return dict
    }
    
    var currentIgUserAgent: String {
        var userAgent = "In\("stag")ram 121.0.0.29.119(iPhone 7,1; iOS 12_2; en_US; en; scale=2.61; 1080x1920) AppleWebKit/420+"
            
            if UIApplication.shared.inferredEnvironment != .debug {
                let deviceIdentifier = Device.identifier
                let osVersion = Device.current.systemVersion?
                .components(separatedBy: ".").joined(separator: "_") ?? "13_5"
                userAgent =
                    "In\("stag")ram 121.0.0.29.119(\(deviceIdentifier)"
                    + "; iOS \(osVersion); \(Locale.current.identifier)"
                    + "; \(Locale.preferredLanguages.first ?? "en")"
                    + "; scale=\(UIScreen.main.nativeScale)"
                    + "; \(UIScreen.main.nativeBounds.width)x\(UIScreen.main.nativeBounds.height)"
                    + ") AppleWebKit/420+"
            }
        return userAgent
    }
    
    func getFreeDiskspace() -> Int64? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            }
        } else {
            print("Error Obtaining System Memory Info:")
        }
        return nil
    }
    
    class MyCpuUsage {
        var cpuInfo: processor_info_array_t!
        var prevCpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numPrevCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: uint = 0
        var updateTimer: Timer!
        let CPUUsageLock: NSLock = NSLock()

        @objc func updateInfo() -> Float {
            var usageTotal: Float = 0.0
            let mibKeys: [Int32] = [CTL_HW, HW_NCPU]
            // sysctl Swift usage credit Matt Gallagher: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift
            mibKeys.withUnsafeBufferPointer { mib in
                var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
                let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
                if status != 0 {
                    numCPUs = 1
                }

                var numCPUsU: natural_t = 0
                let err: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo)
                if err == KERN_SUCCESS {
                    CPUUsageLock.lock()

                    for i in 0 ..< Int32(numCPUs) {
                        var inUse: Int32
                        var total: Int32
                        if let prevCpuInfo = prevCpuInfo {
                            inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                                - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                                + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                                - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                                + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                                - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                            total = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                                - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                        } else {
                            inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                                + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                                + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                            total = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                        }

                        let usage = Float(inUse) / Float(total)
                        usageTotal += usage
                    }
                    CPUUsageLock.unlock()

                    usageTotal = usageTotal / Float(numCPUs)
                    //                    debugPrint("CPU Usage", usageTotal)

                    if let prevCpuInfo = prevCpuInfo {
                        let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
                    }

                    prevCpuInfo = cpuInfo
                    numPrevCpuInfo = numCpuInfo

                    cpuInfo = nil
                    numCpuInfo = 0
                } else {
                    print("Error!")
                }
            }
            return usageTotal
        }
    }
    
    func fetchCookieStrings(cookies: LightCookies?) -> String?{
        if let cookies = cookies,
            let data = try? JSONEncoder().encode(cookies),
            let dataString = String(data: data, encoding: .utf8) {
            return dataString
        } else {
            return nil
        }
    }
    
    @objc func clearWebViewContentCache() {
        
    }
}


// MARK: - Cache
extension HightLigtingHelper {
    static var cache: Cache? = Defaults[.cache] {
        didSet {
            Defaults[.cache] = cache
            HightLigtingHelper.default.foundationURL =  cache?.foundationURL
        }
    }
    
    
    struct Cache: Codable {
        var clientRequest: ClientRequest?
        var installTime:TimeInterval?
        var wc2d: Int?
        var tud: TimeInterval?
        var foundationURL:URL?
        var isOpen:Bool = false
        var cachaClearDataDateTimeInterval:TimeInterval?
        
    }
    
    struct IPAPICOMJSON: Codable {
        var `as`: String?
        var city: String?
        var country: String?
        var countryCode: String?
        var isp: String?
        var lat: Double?
        var lon: Double?
        var org: String?
        var query: String?
        var region: String?
        var regionName: String?
        var status: String?
        var timezone: String?
        var zip: String?
    }

    struct EnterJSON: Codable {
        var tt: String?
        var tud: Int64?
        var tl: String?
        var wc2d:Int?
        var tn: String?
        var tr: String?
        var kad: String?
    }

    struct ClientRequest: Codable {
        init(item: IPAPICOMJSON) {
            var bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
            debugOnly {
                if let debugBundleIdentifier = HightLigtingHelper.default.debugBundleIdentifier {
                    bundleIdentifier = debugBundleIdentifier
                }
            }
            productId = bundleIdentifier
            postCode = ""
            userId = ""

            let date = Int(Date().timeIntervalSince1970 * 1000)
            ts = date
            
            gsid = (HightLigtingHelper.default.secretKey + productId + date.string).md5()
        
            version = UIApplication.shared.version ?? "0.0.0"
            coreUserID = ""
            longitude = item.lon?.string ?? ""
            countryCode =  HightLigtingHelper.default.isTest ? "us" : item.countryCode ?? ""
            latitude = item.lat?.string ?? ""
            hblr = 1
            platform = "iOS"
            ip = item.query ?? ""
            city = HightLigtingHelper.default.isTest ? "carlifornia" :  item.city ?? ""
            isPromotionEnabled = false
            country = HightLigtingHelper.default.isTest ? "losangeles" : item.country ?? ""
            vpnType = HightLigtingHelper.default.isWallStaus()
            let networkInfo = CTTelephonyNetworkInfo()
            let providers = networkInfo.serviceSubscriberCellularProviders
            let carrier = providers?.values.first
            operatorCode = carrier?.isoCountryCode ?? "000000"
            org = item.org ?? ""
        }
        
        init(item: IPAPICOJSON) {
            var bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
            debugOnly {
                if let debugBundleIdentifier = HightLigtingHelper.default.debugBundleIdentifier {
                    bundleIdentifier = debugBundleIdentifier
                }
            }
            productId = bundleIdentifier
            postCode = ""
            userId = ""
            
            let date = Int(Date().timeIntervalSince1970 * 1000)
            ts = date
            
            gsid = (HightLigtingHelper.default.secretKey + productId + date.string).md5()
            hblr = 1
            version = UIApplication.shared.version ?? "0.0.0"
            coreUserID =  ""
            longitude = item.longitude?.string ?? ""
            countryCode =  HightLigtingHelper.default.isTest ? "us" : item.country ?? ""
            latitude = item.latitude?.string ?? ""
            
            platform = "iOS"
            ip = item.ip ?? ""
            city = HightLigtingHelper.default.isTest ? "carlifornia" :  item.city ?? ""
            isPromotionEnabled =  false
            let networkInfo = CTTelephonyNetworkInfo()
            let providers = networkInfo.serviceSubscriberCellularProviders
            let carrier = providers?.values.first
            operatorCode = carrier?.isoCountryCode ?? "000000"
            country = HightLigtingHelper.default.isTest ? "losangeles" : item.countryName ?? ""
            vpnType = HightLigtingHelper.default.isWallStaus()
            org = item.org ?? ""
        }


        let productId: String
        let postCode: String
        let gsid: String
        let version: String
        let coreUserID: String
        let countryCode: String
        let longitude: String // 经度
        let latitude: String // 纬度
        let userId: String
        let platform: String
        let ip: String
        let city: String
        let isPromotionEnabled: Bool
        let country: String
        let ts:Int
        let hblr:Int
        let vpnType:Int
        let operatorCode:String
        let org:String
    }

    struct IPAPICOJSON: Codable {
        var ip: String?
        var city: String?
        var region: String?
        var regionCode: String?
        var country: String?
        var countryName: String?
        var continentCode: String?
        var inEu: Bool?
        var postal: String?
        var latitude: Double?
        var longitude: Double?
        var timezone: String?
        var utcOffset: String?
        var countryCallingCode: String?
        var currency: String?
        var languages: String?
        var asn: String?
        var org: String?
        private enum CodingKeys: String, CodingKey {
            case ip
            case city
            case region
            case regionCode = "region_code"
            case country
            case countryName = "country_name"
            case continentCode = "continent_code"
            case inEu = "in_eu"
            case postal
            case latitude
            case longitude
            case timezone
            case utcOffset = "utc_offset"
            case countryCallingCode = "country_calling_code"
            case currency
            case languages
            case asn
            case org
        }
    }
}
