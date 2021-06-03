//
//  InnLoginViewController.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/7.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import WebKit
import Adjust
import Toast
import ZKProgressHUD

class InnLoginViewController: UIViewController {
    
    var authCompleteHandler:(() -> Void)?
    var beginLoginHandler:((_ userName:String?) -> Void)?
    var loginTapHandler:(() -> Void)?
    var beginGetUserInfoHandler:(() -> Void)?
    var fetchUserInfoComplete:((_ success:Bool, _ errorMessage:String?,_ userDetailsDic:[String:Any?]?) -> Void)?
    var loginComplete:((_ success:Bool,_ checkPoint:Bool, _ errorMessage:String?,_ loginUserDic:[String:Any?]?,_ cookie:String?) -> Void)?
    var closeLoginPageHandler:(()->Void)?
    var cancelLoginPageHandler:(()->Void)?
    var isDaoLiang:Bool = false

    var appstore_appId:String?
   
    var showCloseBtn:Bool = false {
        didSet {
            closeBtn.isHidden = !showCloseBtn
        }
    }
    let appName =  UIApplication.shared.displayName ?? ""
    
    var userName:String?
    var userId:String?
    
    var loginUserName:String?
    var loginPassword:String?


    lazy var webView: WKWebView = {
        let `webView` = WKWebView(frame: self.view.bounds)
        webView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height )
        webView.backgroundColor = UIColor.init(red: 250.0 / 255.0 , green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "InsLoginHandler")

        return webView
    }()
    
    lazy var closeBtn: UIButton = {
         let button = UIButton()
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        let bundle = Bundle(path: Bundle(for: Self.self).path(forResource: "InnLogin", ofType: "bundle") ?? "")
        
        let image = UIImage(named: "ic_a_c", in: bundle,compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 20, y: UIApplication.topSafeAreaHeight + 20, width: 40, height: 40);
        return button
    }()
    
    
    lazy var tipView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: self.webView.frame.maxY - UIApplication.bottomSafeAreaHeight - 70, width: UIScreen.width, height: 70 + UIApplication.bottomSafeAreaHeight);
        view.backgroundColor = UIColor.init(red: 23.0 / 255.0, green: 24.0 / 255.0, blue: 52.0 / 255.0, alpha: 1)
        return view
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel(frame:  CGRect(x: 20, y: 0, width: UIScreen.width - 40, height: 70))
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        let tipString = "The App will never store or use your inst\("agra")m information."
        label.text = tipString
        return label
    }()
    

    
    lazy var twoFactorLoginView: InnTwoFactorLoginView? = {
        let view = (Bundle(path: Bundle.main.bundlePath )?.loadNibNamed("InnLoginSubviews", owner: nil, options: nil)?[2] as? InnTwoFactorLoginView)
        view?.frame = self.view.bounds
        return view
    }()
    
    lazy var challengeView: InnLoginChallengeView? = {
        let view = (Bundle(path: Bundle.main.bundlePath )?.loadNibNamed("InnLoginSubviews", owner: nil, options: nil)?[0] as? InnLoginChallengeView)
        view?.frame = self.view.bounds
        return view
    }()
    
    lazy var codeView: InnLoginVerifyCodeView? = {
        let view = (Bundle(path: Bundle.main.bundlePath )?.loadNibNamed("InnLoginSubviews", owner: nil, options: nil)?[1] as? InnLoginVerifyCodeView)
        view?.frame = self.view.bounds
        return view
    }()
    
    lazy var checkPointBgView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    
    init(isDaoLiang:Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.isDaoLiang = isDaoLiang
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        initSubViews()
     
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        InnLoginHandler.clearWebCache()
    }
}

// UI
extension InnLoginViewController {
    func prepare() {
       loadRequet()
    }
    
    func initUI() {
     
    }
    
    func initSubViews() {
        view.addSubview(webView)
        view.addSubview(tipView)
        tipView.addSubview(tipLabel)
        view.addSubview(closeBtn)
    }
    
    func loadRequet() {
        showCloseBtn = true
        let url =  URL(fileURLWithPath:(Bundle.main.bundlePath).appendingPathComponent("login.html"))
        webView.load(URLRequest(url: url))
    }
    
  
}


// Login Action
extension InnLoginViewController  {
    func loginInsam(userName:String?,password:String?) {
        
//        [self adjustTrack:self.api_login_start];
        if userName?.count ?? 0 > 0 {
            self.loginUserName = userName;
        } else {
            //TODO: api_login_failed
//            [self adjustTrack:self.api_login_failed];
            DispatchQueue.main.async {
//                [NSValue valueWithCGPoint:CGPointMake(TT_SCREEN_WIDTH * 0.5, TT_SCREENH_HEIGHT - TT_SafeAreaBottom - TT_Height_NavBar - 50)]
                self.view.makeToast("invalid username.", duration: 3.0, position: nil)
            }
           
            return
        }
        
        if password?.count ?? 0 > 0 {
            self.loginPassword = password
        } else {
            //TODO: api_login_failed
//            [self adjustTrack:self.api_login_failed];
            DispatchQueue.main.async {
//                [NSValue valueWithCGPoint:CGPointMake(TT_SCREEN_WIDTH * 0.5, TT_SCREENH_HEIGHT - TT_SafeAreaBottom - TT_Height_NavBar - 50)
                self.view.makeToast("invalid password." , duration: 3.0, position: nil)
            }
            return
        }
    
        DispatchQueue.main.async {
            ZKProgressHUD.show()
            self.beginLoginHandler?(userName)
        }
       
        InnRequestHelper.shared.loginToIG(username: userName, password: password, successComplete: { [weak self] (loginUserDic, cookie) in
            guard let `self` = self else { return }
             //TODO: api_login_success
            //            [strongSelf adjustTrack:strongSelf.api_login_success];
            //
            self.userId = (loginUserDic?["pk"] as? NSNumber)?.stringValue
            self.userName = loginUserDic?["username"] as? String
            let userid = (loginUserDic?["pk"] as? NSNumber)?.stringValue
            self.appSessionRequest(isLogin: true, userId: userid, userDic: loginUserDic, cookie: cookie)
            self.loginComplete?(true, false, "", loginUserDic, cookie);
        }, checkPointFailed: { [weak self](subApiUrlPath) in
             guard let `self` = self else { return }
            self.checkChallenge(apiPath: subApiUrlPath)
            self.loginComplete?(false, true, "", nil, nil)
        }, twoFactorFailed: { [weak self](twoFactorIdentifier, userName, mobile, csrftoken) in
            guard let `self` = self else { return }
            ZKProgressHUD.dismiss()
            self.showTwoFactorLoginViewWithTwoFactorCodeIdentifier(twoFactorIndetifier: twoFactorIdentifier, userName: userName, mobile: mobile, csrftoken: csrftoken)
            self.loginComplete?(false, false, "", nil, nil);
        }) { [weak self] (errorMsg) in
             ZKProgressHUD.dismiss()
            //            //TODO: api_login_failed
            //            [strongSelf adjustTrack:strongSelf.api_login_failed];
            guard let `self` = self else { return }
            ZKProgressHUD.dismiss()
            self.loginComplete?(false, false, errorMsg, nil, nil);
            if errorMsg == "checkpoint_required" {
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("Instagram want to confirm with your about your account privacy, so you need to login the actual instagram app, and then back to login again",comment: ""), duration: 3.0, position:nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.view.makeToast(errorMsg, duration: 3.0, position:nil)
                }
            }
        }
    }
    
    
    
    func appSessionRequest(isLogin:Bool,userId:String?,userDic:[String:Any?]?,cookie:String?) {
        var csrftoken = ""
        var sessionID = ""
        var midString = ""
        
        let subStrings = cookie?.components(separatedBy: ";")
        
        subStrings?.forEach({ (theSubString) in
           let nstheSubString = theSubString as NSString
           let csrRange = nstheSubString.range(of: "csrftoken=")
           let sessionRange = nstheSubString.range(of: "sessionid=")
           let midRange = nstheSubString.range(of: "mid=")
            if csrRange.length > 0{
                csrftoken = nstheSubString.substring(with: NSRange(location: NSMaxRange(csrRange), length: nstheSubString.length - NSMaxRange(csrRange))) as String
                
            }
            
            if sessionRange.length > 0{
                sessionID = nstheSubString.substring(with: NSRange(location: NSMaxRange(sessionRange), length: nstheSubString.length - NSMaxRange(sessionRange))) as String
            }
            
            if midRange.length > 0 {
                midString = nstheSubString.substring(with: NSRange(location: NSMaxRange(midRange), length: nstheSubString.length - NSMaxRange(midRange))) as String
            }

        })
     
    
        self.beginGetUserInfoHandler?()
        
        InnRequestHelper.shared.fetchIGUserDetail(userID: userId, sessionToken: csrftoken, userName: userDic?["username"] as? String , pkUderId: (userDic?["pk"] as? NSNumber)?.stringValue, sessionMid: midString, sessionId: sessionID) { [weak self](success, errorMessage, userDetailsDic) in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
            }
            self.fetchUserInfoComplete?(success,errorMessage,userDetailsDic)
            if (success) {
                if  self.firstAuthenticationUser(userId: userId) {
                    self.showAuthenticationPage()
                } else {
                    self.closeLoginPage()
                }
            } else {
                DispatchQueue.main.async {
                    self.view.makeToast(errorMessage, duration: 3.0, position: nil)
                }
            }
            
        }
        
    }
    
    func cancelAuthorization() {
        loadRequet()
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
    
    func firstAuthenticationUser(userId:String?) -> Bool {
        guard let userId = userId else { return false }
        let authenKey = "hasAuthenticationInThisDevice_\(userId)"
        return !UserDefaults.standard.dictionaryRepresentation().keys.contains(authenKey)
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
    
    func displayEmptyUserNameWarning() {
        let jsString = "UsernameWarning()"
        self.webView.evaluateJavaScript(jsString) { (result, error) in
            
        }
    }
    
    func displayEmptyPasswordWarning() {
        let jsString = "PasswordWarning()"
        self.webView.evaluateJavaScript(jsString) { (result, error) in
            
        }
    }

    func showAuthenticationPage() {
        showCloseBtn = false
        let url =  URL(fileURLWithPath:(Bundle.main.bundlePath ).appendingPathComponent("detail.html"))
        webView.load(URLRequest(url: url))
    }
    
    func handleQuery(queryName:String?,queryValue:String?) {
        if queryName == "allow" {
            if queryValue == "Authorize" {
                self.finishAuthorization()
            }
            else if queryValue == "Cancel" {
                self.cancelAuthorization()
            }
        }
    }
    
    func closeLoginPage() {
        self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else {return}
            self.closeLoginPageHandler?()
        })
    }
    
    func fetchVerifyCode(apiPath:String?,verifyType:String?,completion:@escaping(_ success:Bool) -> Void) {
        InnRequestHelper.shared.fetchIGChallengeVerifyCode(choice: verifyType, subApi: apiPath) { (success, errorMessage, verifyDict,subApi) in
            completion(success)
            if !success {
                DispatchQueue.main.async {
                    self.view.makeToast(errorMessage, duration: 3.0, position: nil)
                }
            }
        }
    }

}

extension InnLoginViewController {
    func checkChallenge(apiPath:String?) {
        InnRequestHelper.shared.fetchIGChallengeRequiredData(subApi: apiPath) { [weak self](success, errorMessage, challengeDict, subApi) in
            guard let `self` = self else {return}
            if success {
                if (challengeDict?["step_name"] as? String) == "verify_code" {
                    let stepData = challengeDict?["step_data"] as? [String:Any]
                    let type = "0"
                    let tip = "Enter the 6-digit code we sent to the phone \(stepData?["phone_number_formatted"] as? String ?? "")"
                    self.showInputVerifyCodeView(tipMsg: tip, apiPath: apiPath, verifyType: type)
                } else if challengeDict?["step_name"] as? String  == "verify_email" {
                    let stepData = challengeDict?["step_data"] as? [String:Any]
                    let type = "1"
                    let tip = "Enter the 6-digit code we sent to the email address \(stepData?["contact_point"] as? String ?? "")"
                    self.showInputVerifyCodeView(tipMsg: tip, apiPath: apiPath, verifyType: type)
                } else if challengeDict?["step_name"] as? String == "submit_phone" {
                    //TODO: api_login_failed
                    //    [strongSelf adjustTrack:strongSelf.api_login_failed];
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        self.view.makeToast("Please go to In\("stag")ram and submit your phone.", duration: 3.0, position: nil)
                    }
                    
                }  else {
                    if challengeDict?.keys.contains("step_data") ?? false {
                        var email:String?
                        var mobile:String?
                        let stepData = challengeDict?["step_data"] as? [String:Any?]
                        if stepData?.keys.contains("email") ?? false {
                            email = stepData?["email"] as? String
                        }
                        if stepData?.keys.contains("phone_number") ?? false {
                            mobile = stepData?["phone_number"] as? String
                        }
                        self.showChallengeView(apiPath: apiPath, email: email, mobile: mobile)
                    } else {
                        //                                 TODO: api_login_failed
                        //                                                    [strongSelf adjustTrack:strongSelf.api_login_failed];
                        DispatchQueue.main.async {
                            self.view.makeToast("Unexpected login error happened, please try again later.", duration: 3.0, position: nil)
                        }
                        
                    }
                }
            } else {
                //                //TODO: api_login_failed
                //                [strongSelf adjustTrack:strongSelf.api_login_failed];
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss()
                    self.view.makeToast(errorMessage, duration: 3.0, position: nil)
                }
            }
            
        }
    }
    
    func showInputVerifyCodeView(tipMsg:String?, apiPath:String?, verifyType:String?) {
        DispatchQueue.main.async {
            ZKProgressHUD.dismiss()
        }
        self.codeView?.tipLab.text = tipMsg
        self.codeView?.tv.clearCode()
        self.codeView?.okActionHandler = { [weak self] (code) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.codeView?.removeFromSuperview()
                self.checkPointBgView.removeFromSuperview()
            }
            self.verifyCode(code: code, subApi: apiPath)
        }
        self.codeView?.closeClick = { [weak self] in
            DispatchQueue.main.async {
                //TODO: api_login_api_login_failed
//                [strongSelf adjustTrack:strongSelf.api_login_failed];
                self?.codeView?.removeFromSuperview()
                self?.checkPointBgView.removeFromSuperview()
            }
        }
   
        DispatchQueue.main.async {
            if let codeView = self.codeView {
                self.view.addSubview(codeView)
            }
        }
    }

    func verifyCode(code:String?,subApi:String?) {
        ZKProgressHUD.show()
        InnRequestHelper.shared.verifyIGChallenteCode(code: code, subApi: subApi) { [weak self](success, errorMessage, loginUserDic, cookie) in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
            }
            
            self.loginComplete?(success, false, errorMessage, loginUserDic, cookie)
            if (success) {
                if loginUserDic != nil {
                    //TODO: api_login_success
//                    [strongSelf adjustTrack:strongSelf.api_login_success];
                    self.userId = (loginUserDic?["pk"] as? NSNumber)?.stringValue
                    self.userName = loginUserDic?["username"] as? String
                    self.appSessionRequest(isLogin: true, userId: (loginUserDic?["pk"] as? NSNumber)?.stringValue, userDic: loginUserDic, cookie: cookie)
                } else {
                    //TODO: api_login_api_login_failed
//                    [strongSelf adjustTrack:strongSelf.api_login_failed];
                    let alertController = UIAlertController(title: nil, message: NSLocalizedString("Verification succeeded. Please enter your user name and log in again.", comment: ""), preferredStyle: .alert)
            
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                //TODO: api_login_api_login_failed
//                [strongSelf adjustTrack:strongSelf.api_login_failed];
                let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showChallengeView(apiPath:String?,email:String?,mobile:String?) {
        DispatchQueue.main.async {
            ZKProgressHUD.dismiss()
        }
    
        if email?.count ?? 0 > 0 {
            
            self.challengeView?.emailBtn.setTitle( "\(NSLocalizedString("Email", comment: "")):\(email ?? "")", for: .normal)

            self.challengeView?.emailHeight.constant = 30
            self.challengeView?.mobileTop.constant = 5
            self.challengeView?.emailBtn.isHidden = false
            self.challengeView?.emailBtn.isSelected = true
            self.challengeView?.mobileBtn.isSelected = false

        } else {
            self.challengeView?.emailHeight.constant = 0
            self.challengeView?.mobileTop.constant = 0
            self.challengeView?.emailBtn.isHidden = true
            self.challengeView?.emailBtn.isSelected = false
            self.challengeView?.mobileBtn.isSelected = true

        }
        if mobile?.count ?? 0 > 0 {

            self.challengeView?.emailBtn.setTitle( "\(NSLocalizedString("Phone", comment: "")):\(mobile ?? "")", for: .normal)
            
            self.challengeView?.mobileHeight.constant = 30
            self.challengeView?.mobileBtn.isHidden = false
        } else {
            self.challengeView?.mobileHeight.constant = 0
            self.challengeView?.mobileTop.constant = 0
            self.challengeView?.mobileBtn.isHidden = true
        }
        self.view.addSubview(self.checkPointBgView)

        self.challengeView?.sendActionClick = { [weak self] type in
            guard let `self` = self else {return}
            self.fetchVerifyCode(apiPath: apiPath, verifyType: type) { (success) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var tip = ""
                if type?.int  == 0 {
                    tip = "Enter the 6-digit code we sent to the phone \(mobile ?? "")"
                } else {
                    tip = "Enter the 6-digit code we sent to the email address \(email ?? "" )"
                }
                
                DispatchQueue.main.async {
                    self.challengeView?.removeFromSuperview()
                }
                self.showInputVerifyCodeView(tipMsg: tip, apiPath: apiPath, verifyType: type)
            }
        }
        
        self.challengeView?.closeClick = {  [weak self] in
            guard let `self` = self else {return}
            //TODO: api_login_api_login_failed
//            [strongSelf adjustTrack:strongSelf.api_login_failed];
            DispatchQueue.main.async {
                self.challengeView?.removeFromSuperview()
                self.checkPointBgView.removeFromSuperview()
            }
        }
           DispatchQueue.main.async {
            self.view.addSubview(self.challengeView!)
        }
    }
    
    func showTwoFactorLoginViewWithTwoFactorCodeIdentifier(twoFactorIndetifier:String?,
                                                           userName:String?,
                                                           mobile:String?,
                                                           csrftoken:String?) {
        //TODO: api_login_2auth
//               [self adjustTrack:self.api_login_2auth];
        self.view.addSubview(self.checkPointBgView)
        self.twoFactorLoginView?.codeTF.text = ""
        
        self.twoFactorLoginView?.okActionHandler = { [weak self] code in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.twoFactorLoginView?.removeFromSuperview()
                self.checkPointBgView.removeFromSuperview()
            }
            
            self.verify(twoFactorCode: code, twoFactorCodeIdentifier: twoFactorIndetifier, userName: userName, csrftoken: csrftoken)
            
        }
        
        self.twoFactorLoginView?.closeClick = {  [weak self] in
            guard let `self` = self else {return}
            //TODO: api_login_api_login_failed
            //            [strongSelf adjustTrack:strongSelf.api_login_failed];
            DispatchQueue.main.async {
                self.twoFactorLoginView?.removeFromSuperview()
                self.checkPointBgView.removeFromSuperview()
            }
        }
        DispatchQueue.main.async {
            self.view.addSubview(self.twoFactorLoginView!)
        }
    }

    func verify(twoFactorCode:String?,twoFactorCodeIdentifier:String?,userName:String?,csrftoken:String?) {
        ZKProgressHUD.show()
        InnRequestHelper.shared.verifyIGTwoFactorCode(code: twoFactorCode, twoFactorIdentifier: twoFactorCodeIdentifier, username: userName, csrftoken: csrftoken) { [weak self](success, errorMessage, loginUserDic, cookie) in
            guard let `self` = self else {return}
            ZKProgressHUD.dismiss()
            self.loginComplete?(success, false, errorMessage, loginUserDic, cookie)
            if (success) {
                if loginUserDic != nil {
                    //TODO: api_login_success
                    //                    [strongSelf adjustTrack:strongSelf.api_login_success];
                    self.userId = (loginUserDic?["pk"] as? NSNumber)?.stringValue
                    self.userName = loginUserDic?["username"] as? String
                    self.appSessionRequest(isLogin: true, userId: (loginUserDic?["pk"] as? NSNumber)?.stringValue, userDic: loginUserDic, cookie: cookie)
                } else {
                    //TODO: api_login_api_login_failed
                    //                    [strongSelf adjustTrack:strongSelf.api_login_failed];
                    let alertController = UIAlertController(title: nil, message: NSLocalizedString("Verification succeeded. Please enter your user name and log in again.", comment: ""), preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                //TODO: api_login_api_login_failed
                //                [strongSelf adjustTrack:strongSelf.api_login_failed];
                let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}


extension InnLoginViewController {
    @objc func closeAction(_ sender:UIButton) {
        self.cancelLoginPageHandler?()
        self.presentingViewController?.dismiss(animated: true) {  
            
        }
    }
}

//WKWebViewDelegate
extension InnLoginViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == "ios" {
            if navigationAction.request.url?.absoluteString == "ios://notUser" {
                self.cancelAuthorization()
                decisionHandler(.cancel);
            }else {
                let queryString = navigationAction.request.url?.query
                
                let newQueryString = queryString?.replacingOccurrences(of: "+", with: "%20")
                
                let queryArray = self.queryArray(queryStrings: newQueryString)
                
                if queryArray.count == 2 {
                    let firstQuery = queryArray[0]
                    let secondQuery = queryArray[1]
                    if firstQuery["name"]  == "username" && secondQuery["name"] == "password" {
                        let userName = firstQuery["value"]
                        let password = secondQuery["value"]
                        if userName == nil || userName == "" || userName?.count == 0 {
                            self.displayEmptyUserNameWarning()
                            decisionHandler(.cancel)
                        } else if (userName == nil || password == "" || password?.count == 0) {
                            self.displayEmptyPasswordWarning()
                            decisionHandler(.cancel)
                        } else {
                            self.loginInsam(userName: userName, password: password)
                            self.showAuthenticationPage()
                        }
                    }
                } else if queryArray.count == 1 {
                    let queryDictionary = queryArray[0]
                    let queryName = queryDictionary["name"]
                    let queryValue = queryDictionary["value"]
                    self.handleQuery(queryName: queryName, queryValue: queryValue)
                    decisionHandler(.cancel)
                }  else {
                    decisionHandler(.allow)
                }
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let pagePath = Bundle.main.bundlePath.appendingPathComponent("detail.html")
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
        } else {
            let userName = NSLocalizedString("Username", comment:"Username")
            let password = NSLocalizedString("Password", comment:"Password")
            let forgotPassword = NSLocalizedString("Forgot your password", comment:"Forgot your password")
            let login = NSLocalizedString("Log in", comment:"Log in");
            let loginFB = NSLocalizedString("Log in With Fac\("ebook")", comment:"Log in With Fac\("ebook")")
            let jsString = "setPlaceholderUsername('\(userName)'); setPlaceholderPassword('\(password)'); setPlaceholderForgotPassword('\(forgotPassword)'); setPlaceholderLogin('\(login)'); setLoginByFacebook('\(loginFB)')"
            
            webView.evaluateJavaScript(jsString) { (re, err) in
                
            }
        }
    }
    
}


extension InnLoginViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if let dic = message.body as? [String:Any] {
            debugPrint("😃😃😃😃😃😃Login Start")
            let methodName = dic["methodName"] as? String
            let params = dic["params"] as? [String:Any]
            if message.name == "InsLoginHandler" {
                if  methodName == "invokeForgetPasswordFunction" {
                    DispatchQueue.main.async {
                        if let url = URL(string: "https://instagram.com/accounts/password/reset/") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                } else if methodName  == "invokeLoginWithFBFunction" {
                    DispatchQueue.main.async {
//                        [self showLoginFbPage];
                    }
                } else if methodName == "invokeLoginFunction" {
                    self.loginTapHandler?()
                    self.userName = params?["name"] as? String
    
                    self.loginInsam(userName: params?["name"] as? String, password: params?["password"] as? String)
                }
            }
        }
    }
}
