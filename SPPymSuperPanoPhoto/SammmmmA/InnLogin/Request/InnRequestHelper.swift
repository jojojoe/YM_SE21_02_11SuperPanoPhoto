//
//  InnRequestHelper.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/10.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import Alamofire
import AdSupport
import DeviceKit


class InnRequestHelper: NSObject {
    static let shared = InnRequestHelper()
    private override init() { }
    let defaultHotHTTPHeaderField = DataEncoding.shared.aesDecrypted(string: "AlK+4K1Vi4TSPz/Yk9MEZw==") ?? ""
    let baseUrl = DataEncoding.shared.aesDecrypted(string: "xCD+0O9v/CEG4B3qZSnIb7WK1nFWPzqk1a+sBU/AG0Q=") ?? ""
    let reqTimeOutInterval:TimeInterval =  60 * 1
    let reqUserAgent = DataEncoding.shared.aesDecrypted(string: "4lQjqWJ4+KPrd1RgoOubGdnZDjKDRuTLx27JWhiifX8=") ?? ""
    var definedInstaKey = "31daaa1bd12d53b039e0e21fe4214e6bb74ab2cd93854b48005bb4d1281ed405"
    
    var signKeyVersion:Int {
        let userAgent = userAgentString()
        var signKeyVersion:Int = 5
        let character = "An\("dro")id"
        if userAgent.contains(character) {
            signKeyVersion = 4
        }
        return signKeyVersion
    }

    
    func loginToIG(username:String?,
                   password:String?,
                   successComplete:(@escaping(_ loginUserDic:[String:Any]?,_ cookie:String?) -> Void),
                   checkPointFailed:(@escaping(_ subApiUrlPath:String?) -> Void),
                   twoFactorFailed:(@escaping(_ twoFactorIdentifier:String?,_ userName:String?, _ mobile:String?,_ csrftoken:String?) -> Void),
                   errorClosure:(@escaping(_ errorMsg:String?) -> Void)) {
        
        guard let requestURL = URL(string: "\(baseUrl)/api/v1/accounts/login/") else {
            errorClosure("Invalid url")
            return
        }
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        request.httpMethod = "POST"
      
        let deviceUDID = NSUUID().uuidString
        
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("3brTPw==", forHTTPHeaderField: "X-IG-Capabilities")
        request.setValue("WIFI", forHTTPHeaderField: "X-IG-Connection-Type")
        request.setValue("Liger", forHTTPHeaderField: "X-FB-HTTP-Engine")
        request.setValue(defaultHotHTTPHeaderField, forHTTPHeaderField: "Host")
        request.setValue("0", forHTTPHeaderField: "X-FB-ABSURL-DEBUG")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        let content = String(format: "{\"username\":\"%@\",\"password\":\"%@\",\"guid\":\"%@\",\"device_id\":\"%@\",\"login_attempt_count\":0,\"phone_id\":\"%@\",\"adid\":\"%@\", \"csrftoken\":\"missing\"}", username ?? "", password ?? "", deviceUDID, UIDevice.current.identifierForVendor?.uuidString ?? "", UIDevice.current.identifierForVendor?.uuidString ?? "", ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        
        let secretKey = content.hmac(algorithm: .SHA1, key: definedInstaKey)
        let signedBody = "\(secretKey).\(content)"

        var parameters = [String:String]()
        parameters["ig_sig_key_version"] = NSNumber(value: signKeyVersion).stringValue
        parameters["signed_body"] = signedBody
        let sereParmeterString = parameters.formEncodedComponents()
        request.httpBody  = sereParmeterString.data(using: .utf8)
      
      
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            let res = jsonResponse.response
                            let allHeaders = res?.allHeaderFields
                            let cookieDic = allHeaders?["Set-Cookie"] as? String
                            let userInfo = resp["logged_in_user"] as? [String:Any]
                            
                            successComplete(userInfo, cookieDic)
                        } else {
                            if let data = jsonResponse.data {
                                do {
                                    let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                    let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                    
                                    print("login error: \(String(describing: resposeDic))")
                                    let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                    if resposeDic?["error_type"] as? String == "checkpoint_challenge_required" {
                                        if resposeDic?.keys.contains("checkpoint_url") ?? false {
                                            if let arr = (resposeDic?["checkpoint_url"] as? String)?.components(separatedBy: "/challenge/") {
                                                if arr.count >= 1 {
                                                    let api = arr[1]
                                                    let rApi = "/challenge/\(api)"
                                                    checkPointFailed(rApi)
                                                } else {
                                                    errorClosure(errorMessage)
                                                }
                                            }
                                        } else if resposeDic?.keys.contains("challenge") ?? false {
                                            if let apiPath = resposeDic?["challenge"] as? Dictionary<String,String> {
                                                checkPointFailed( apiPath["api_path"])
                                            } else {
                                                errorClosure(errorMessage)
                                            }
                                        } else {
                                            errorClosure(errorMessage)
                                        }
                                    } else {
                                        if let isTwoFactor = resp["two_factor_required"] as? Bool {
                                            if isTwoFactor {
                                                let userInfo = resp["two_factor_info"] as? Dictionary<String,Any>
                                                let res = jsonResponse.response
                                                let allHeaders = res?.allHeaderFields
                                                let cookieDic = allHeaders?["Set-Cookie"] as? String
                                                var csrftoken = ""
                                                let subStrings = cookieDic?.components(separatedBy: ";")
                                                subStrings?.forEach({ (theSubString) in
                                                    let nstheSubString = theSubString as NSString
                                                    let csrRange = nstheSubString.range(of: "csrftoken=")
                                                    if csrRange.length > 0{
                                                        csrftoken = nstheSubString.substring(with: NSRange(location: NSMaxRange(csrRange), length: nstheSubString.length - NSMaxRange(csrRange))) as String
                                                        
                                                    }
                                                })
                                               
                                                twoFactorFailed(userInfo?["two_factor_identifier"] as? String, userInfo?["username"] as? String, userInfo?["obfuscated_phone_number"] as? String, csrftoken)
                                            } else {
                                                
                                                if errorMessage == "challenge_required" {
                                                    let errorMessage = "It looks like you shared your password with a service to help you get more likes or followers, which goes against In\("stagr")am Community Guidelines.Change your password to continue using In\("stagr")am. If you share your new password with one of these services, you may get blocked from following, liking or commenting."
                                                    errorClosure(errorMessage)
                                                    
                                                } else {
                                                    errorClosure(errorMessage)
                                                }
                                            }
                                        } else {
                                            errorClosure(errorMessage)
                                        }
                                    }
                                    
                                } catch let jsonError {
                                    debugPrint(jsonError)
                                    errorClosure(jsonError.localizedDescription)
                                    
                                }
                            } else {
                                errorClosure("No error Data")
                            }
                        }
                    }
                } else {
                    errorClosure("No data")
                }
            case .failure(let error):
                debugPrint(error)
                errorClosure(error.localizedDescription)
            }
        }
    }
    
    func fetchIGUserDetail(userID:String?,
                           complete:(@escaping(_ success:Bool,_ errorMessage:String?,_ userDetailsDic:[String:Any?]?)->Void)) {
        guard let requestURL = URL(string: "\(baseUrl)/api/v1/users/\(userID == nil ? "" : userID!)/info/") else {
            complete(false,"Invalid url",nil)
            return
        }
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        request.httpMethod = "GET"
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        AF.request(request).responseJSON { (jsonResponse) in
           switch jsonResponse.result {
               
           case .success(let value):
               if let resp = value as? Dictionary<String,Any> {
                   if let metaCode =  resp["status"] as? String  {
                       if metaCode == "ok" {
                           let userInfo = resp["user"] as? [String:Any?]
                           complete(true, nil, userInfo)
                       }
                   } else {
                       if let data = jsonResponse.data {
                           do {
                               let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                               let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                               
                               print("login error: \(String(describing: resposeDic))")
                               let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                               if  errorMessage == "consent_required" {
                                   if resposeDic?.keys.contains("consent_data") ?? false {
                                       let dict = resposeDic?["consent_data"] as? [String:Any]
                                       let content = dict?["content"] as? String
                                       complete(false, content,nil)
                                   } else {
                                       complete(false, errorMessage,nil)
                                   }
                               } else {
                                   complete(false, errorMessage,nil)
                               }
                               
                           }  catch let jsonError {
                               debugPrint(jsonError)
                               complete(false, jsonError.localizedDescription, nil)
                           }
                       } else {
                            complete(false, "No error data", nil)
                       }
                   }
               } else {
                  complete(false, "No data", nil)
               }
           case .failure(let error):
               debugPrint(error)
               complete(false, error.localizedDescription, nil)
           }
       }
    }

    
    func fetchIGUserDetail(userID:String?,
                           sessionToken:String?,
                           userName:String?,
                           pkUderId:String?,
                           sessionMid:String?,
                           sessionId:String?,
                           complete:(@escaping(_ success:Bool,_ errorMessage:String?,_ userDetailsDic:[String:Any?]?)->Void)){
        guard let requestURL = URL(string: "\(baseUrl)/api/v1/users/\(userID == nil ? "" : userID!)/info/") else {
            complete(false,"Invalid url",nil)
            return
        }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        request.httpMethod = "GET"
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        var cookieDic = [HTTPCookiePropertyKey:Any]()
        let countryCode = Locale.current.regionCode
        if countryCode != nil {
            cookieDic[HTTPCookiePropertyKey(rawValue: "ccode")] = countryCode!
        }
        
        cookieDic[HTTPCookiePropertyKey(rawValue: "csrftoken")] = sessionToken == nil || sessionToken?.count ?? 0 == 0 ? "missing" : sessionToken!
        cookieDic[HTTPCookiePropertyKey(rawValue: "ds_user")] = userName == nil ? "" : userName!
        cookieDic[HTTPCookiePropertyKey(rawValue: "ds_user_id")] = pkUderId == nil ? "" : pkUderId!
      
     
        if let mid = sessionMid {
            cookieDic[HTTPCookiePropertyKey(rawValue: "mid")] = mid
        }
        cookieDic[HTTPCookiePropertyKey(rawValue: "sessionid")] = sessionId == nil ? "" : sessionId!
        if  let cookie = HTTPCookie(properties: cookieDic) {
            let cookieArray:[HTTPCookie] = [cookie]
            let headers = HTTPCookie.requestHeaderFields(with: cookieArray)
            request.allHTTPHeaderFields = headers
            request.httpShouldHandleCookies = true
        }
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
                
            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            let userInfo = resp["user"] as? [String:Any?]
                            complete(true, nil, userInfo)
                        }
                    } else {
                        if let data = jsonResponse.data {
                            do {
                                let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                
                                print("login error: \(String(describing: resposeDic))")
                                let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                if  errorMessage == "consent_required" {
                                    if resposeDic?.keys.contains("consent_data") ?? false {
                                        let dict = resposeDic?["consent_data"] as? [String:Any]
                                        let content = dict?["content"] as? String
                                        complete(false, content,nil)
                                    } else {
                                        complete(false, errorMessage,nil)
                                    }
                                } else {
                                    complete(false, errorMessage,nil)
                                }
                                
                            }  catch let jsonError {
                                debugPrint(jsonError)
                                complete(false, jsonError.localizedDescription, nil)
                            }
                        } else {
                             complete(false, "No error data", nil)
                        }
                    }
                } else {
                   complete(false, "No data", nil)
                }
            case .failure(let error):
                debugPrint(error)
                complete(false, error.localizedDescription, nil)
            }
        }
    }
    
    func fetchIGChallengeRequiredData(subApi:String?,
                                      complete:(@escaping(_ success:Bool,_ errorMessage:String?,_ challengeDict:[String:Any?]?,_ subApi:String?) -> Void)) {
        let deviceUDID = NSUUID().uuidString
        guard let requestURL = URL(string: "\(baseUrl)/api/v1\(subApi == nil ? "" : subApi! )?device_id=\(deviceUDID)") else {
            complete(false,"Invalid url", nil, subApi)
            return
        }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        request.httpMethod = "GET"
        
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("3brTPw==", forHTTPHeaderField: "X-IG-Capabilities")
        request.setValue("WIFI", forHTTPHeaderField: "X-IG-Connection-Type")
        request.setValue("Liger", forHTTPHeaderField: "X-FB-HTTP-Engine")
        request.setValue(defaultHotHTTPHeaderField, forHTTPHeaderField: "Host")
        request.setValue("0", forHTTPHeaderField: "X-FB-ABSURL-DEBUG")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {

            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            complete(true, nil, resp,subApi)
                        }
                    } else {
                        if let data = jsonResponse.data {
                            do {
                                let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                
                                print("login error: \(String(describing: resposeDic))")
                                let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                complete(false, errorMessage,nil, subApi)
                    
                            }  catch let jsonError {
                                debugPrint(jsonError)
                                complete(false, jsonError.localizedDescription, nil, subApi)
                            }
                        } else {
                            complete(false, "No error data", nil, subApi)
                        }
                    }
                } else {
                     complete(false, "No data", nil,subApi)
                }
            case .failure(let error):
                debugPrint(error)
                complete(false, error.localizedDescription, nil, subApi)
            }
        }
    }
    
    func verifyIGChallenteCode(code:String?,
                               subApi:String?,
                               complete:@escaping(_ success:Bool, _ errorMessage:String?,_ loginUserDic:[String:Any?]?,_ cookie:String?) -> Void) {
        
        let deviceUDID = NSUUID().uuidString
        guard let requestURL = URL(string: "\(baseUrl)/api/v1\(subApi == nil ? "" : subApi! )?device_id=\(deviceUDID)") else {
            complete(false,"Invalid url", nil, nil)
            return
        }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        
        var cookieDic = [HTTPCookiePropertyKey:Any]()
        let countryCode = Locale.current.regionCode
        if countryCode != nil {
            cookieDic[HTTPCookiePropertyKey(rawValue: "ccode")] = countryCode!
        }
        
        cookieDic[HTTPCookiePropertyKey(rawValue: "Connection")] = "keep-alive"
        cookieDic[HTTPCookiePropertyKey(rawValue: "Accept")] = "/*"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Capabilities")] = "3brTPw=="
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Connection-Type")] = "WIFI"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-FB-HTTP-Engine")] = "Liger"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Connection-Speed")] = "1736kbps"

//        // http body
         let content = String(format: "{\"security_code\":\"%@\",\"device_id\":\"%@\"}", code ?? "", deviceUDID)
        
        let secretKey = content.hmac(algorithm: .SHA1, key: definedInstaKey)
        let signedBody = "\(secretKey).\(content)"
        var parameters = [String:String]()
        parameters["ig_sig_key_version"] = NSNumber(value: signKeyVersion).stringValue
        parameters["signed_body"] = signedBody
        let sereParmeterString = parameters.formEncodedComponents()
        request.httpBody  = sereParmeterString.data(using: .utf8)
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            let res = jsonResponse.response
                            let allHeaders = res?.allHeaderFields
                            let cookieDic = allHeaders?["Set-Cookie"] as? String
                            let userInfo = resp["logged_in_user"]
                            if userInfo != nil {
                                complete(true, nil, userInfo as? [String : Any?], cookieDic);
                            } else {
                
                                complete(true, NSLocalizedString("Verification succeeded. Please enter your user name and log in again.", comment: "Verification succeeded. Please enter your user name and log in again."), nil, nil);
                            }
                        } else {
                            if let data = jsonResponse.data {
                                do {
                                    let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                    let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                    
                                    print("login error: \(String(describing: resposeDic))")
                                    let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                    complete(false, errorMessage,nil, nil)
                                    
                                }  catch let jsonError {
                                    debugPrint(jsonError)
                                    complete(false, jsonError.localizedDescription, nil, nil)
                                }
                            } else {
                                complete(false, "No error data", nil, nil)
                            }
                        }
                    }
                } else {
                   complete(false, "No data", nil,nil)
                }
            case .failure(let error):
                debugPrint(error)
                complete(false, error.localizedDescription, nil, nil)
            }
        }
    }
    
    func fetchIGChallengeVerifyCode(choice:String?,
                                    subApi:String?,
                                    complete:@escaping(_ success:Bool, _ errorMessage:String?,_ verifyDict:[String:Any?]?, _ subApi:String?)->Void) {
      
        guard let requestURL = URL(string: "\(baseUrl)/api/v1\(subApi == nil ? "" : subApi! )") else {
            complete(false,"Invalid url", nil, subApi)
            return
        }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        
        request.httpMethod = "POST"
        
        let deviceUDID = NSUUID().uuidString
        
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("3brTPw==", forHTTPHeaderField: "X-IG-Capabilities")
        request.setValue("WIFI", forHTTPHeaderField: "X-IG-Connection-Type")
        request.setValue("Liger", forHTTPHeaderField: "X-FB-HTTP-Engine")
        request.setValue(defaultHotHTTPHeaderField, forHTTPHeaderField: "Host")
        request.setValue("0", forHTTPHeaderField: "X-FB-ABSURL-DEBUG")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        

        let content = String(format: "{\"choice\":\"%@\",\"device_id\":\"%@\"}", choice ?? "", deviceUDID)
        let secretKey = content.hmac(algorithm: .SHA1, key: definedInstaKey)
        let signedBody = "\(secretKey).\(content)"
        var parameters = [String:String]()
        parameters["ig_sig_key_version"] = NSNumber(value: signKeyVersion).stringValue
        parameters["signed_body"] = signedBody
        let sereParmeterString = parameters.formEncodedComponents()
        request.httpBody  = sereParmeterString.data(using: .utf8)
        
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            complete(true, nil, resp,subApi)
                        }
                    } else {
                        if let data = jsonResponse.data {
                            do {
                                let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                
                                print("login error: \(String(describing: resposeDic))")
                                let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                complete(false, errorMessage,nil, nil)
                                
                            }  catch let jsonError {
                                debugPrint(jsonError)
                                complete(false, jsonError.localizedDescription, nil, nil)
                            }
                        } else {
                            complete(false, "No error data", nil, nil)
                        }
                    }
                }  else {
                     complete(false, "No data", nil,subApi)
                }
            case .failure(let error):
                debugPrint(error)
                complete(false, error.localizedDescription, nil, nil)
            }
        }
    }
    
    
    func  verifyIGTwoFactorCode(code:String?,twoFactorIdentifier:String?,username:String?,csrftoken:String?,complete:@escaping(_ success:Bool, _ errorMessage:String?,_ loginUserDic:[String:Any?]?, _ cookie:String?)->Void) {
        
        guard let requestURL = URL(string: "\(baseUrl)/api/v1/accounts/two_factor_login/") else {
            complete(false,"Invalid url", nil, nil)
            return
        }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: reqTimeOutInterval)
        
        request.httpMethod = "POST"
        
        let deviceUDID = NSUUID().uuidString
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.userAgentString(), forHTTPHeaderField:"User-Agent")
        
        var cookieDic = [HTTPCookiePropertyKey:Any]()
        let countryCode = Locale.current.regionCode
        if countryCode != nil {
            cookieDic[HTTPCookiePropertyKey(rawValue: "ccode")] = countryCode!
        }
        
        cookieDic[HTTPCookiePropertyKey(rawValue: "Connection")] = "keep-alive"
        cookieDic[HTTPCookiePropertyKey(rawValue: "Accept")] = "/*"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Capabilities")] = "3brTPw=="
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Connection-Type")] = "WIFI"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-FB-HTTP-Engine")] = "Liger"
        cookieDic[HTTPCookiePropertyKey(rawValue: "X-IG-Connection-Speed")] = "1736kbps"
        
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        let content = String(format: "{\"_csrftoken\":\"%@\",\"device_id\":\"%@\",\"guid\":\"%@\",\"two_factor_identifier\":\"%@\",\"username\":\"%@\",\"verification_code\":\"%@\"}", csrftoken ?? "",uuid ?? "" ,deviceUDID,twoFactorIdentifier ?? "", username ?? "", code ?? "")
        let secretKey = content.hmac(algorithm: .SHA1, key: definedInstaKey)
        let signedBody = "\(secretKey).\(content)"
        var parameters = [String:String]()
        parameters["ig_sig_key_version"] = NSNumber(value: signKeyVersion).stringValue
        parameters["signed_body"] = signedBody
        let sereParmeterString = parameters.formEncodedComponents()
        request.httpBody  = sereParmeterString.data(using: .utf8)
        
        AF.request(request).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                if let resp = value as? Dictionary<String,Any> {
                    if let metaCode =  resp["status"] as? String  {
                        if metaCode == "ok" {
                            let res = jsonResponse.response
                            let allHeaders = res?.allHeaderFields
                            let cookieDic = allHeaders?["Set-Cookie"] as? String
                            let userInfo = resp["logged_in_user"] as? [String:Any]
                            if userInfo != nil {
                                complete(true, nil, userInfo,cookieDic)
                            } else {
                                complete(false, NSLocalizedString("Verification succeeded. Please enter your user name and log in again.", comment: ""), nil, nil);
                            }
                        } else {
                            if let data = jsonResponse.data {
                                do {
                                    let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                    let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                    
                                    print("login error: \(String(describing: resposeDic))")
                                    let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                    complete(false, errorMessage,nil, nil)
                                    
                                }  catch let jsonError {
                                    debugPrint(jsonError)
                                    complete(false, jsonError.localizedDescription, nil, nil)
                                }
                            } else {
                                complete(false, "No error data", nil, nil)
                            }
                        }
                    } else {
                        if let data = jsonResponse.data {
                            do {
                                let resposeDicJ = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                                let  resposeDic = resposeDicJ as? Dictionary<String,Any>
                                
                                print("login error: \(String(describing: resposeDic))")
                                let errorMessage = (resposeDic?["message"] != nil  ? resposeDic?["message"]:  jsonResponse.error?.localizedDescription) as? String
                                complete(false, errorMessage,nil, nil)
                                
                            }  catch let jsonError {
                                debugPrint(jsonError)
                                complete(false, jsonError.localizedDescription, nil, nil)
                            }
                        } else {
                            complete(false, "No error data", nil, nil)
                        }
                    }
                }  else {
                    complete(false, "No data", nil,nil)
                }
            case .failure(let error):
                debugPrint(error)
                complete(false, error.localizedDescription, nil, nil)
            }
        }
    }
}


extension InnRequestHelper {

    func userAgentString() -> String {
        let currentIdentify = Locale.current.identifier
        let languageIdentify = Locale.preferredLanguages[0]
        
        let definedAgent = reqUserAgent
        
        var resolutionString = "scale=\(UIScreen.main.nativeScale); \(UIScreen.main.nativeBounds.width)x\(UIScreen.main.nativeBounds.height)"
        
        let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        var userAgent = ""
        
        #if targetEnvironment(simulator)
        
        userAgent = "\(definedAgent)(iPhone 7,1; \(UIDevice.current.systemName) \(systemVersion); \(currentIdentify); \(languageIdentify); \(resolutionString)) AppleWebKit/420+"
     
        #else
        
        userAgent = "\(definedAgent)(\(Device.identifier); \(UIDevice.current.systemName) \(systemVersion); \(currentIdentify); \(languageIdentify); \(resolutionString)) AppleWebKit/420+"
        #endif
        return userAgent
        
    }

}
