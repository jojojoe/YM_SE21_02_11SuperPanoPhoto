//
//  ApLoginManager.swift
//  CAymCircleAvatarForTT
//
//  Created by JOJO on 2021/4/16.
//


import UIKit
import FirebaseUI
import Firebase
import CryptoKit
import AuthenticationServices



import UIKit

class ApploginUserInfoModel: NSObject {
    
    var userName: String? = ""
    var isAppleLogin = false

}


let keyChainKey = "appLogInasdlfkjas;ljfl;asdjf;ald"

class LoginManage: NSObject, FUIAuthDelegate {
    
    let authUI = FUIAuth.defaultAuthUI()
    fileprivate var currentNonce: String?
    
    class func receivesAuthenticationProcess(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
          if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
          }
          // other URL handling goes here.
          return false
    }
    
    class func fireAppInit() {
        FirebaseApp.configure()
        
        
    }
    
    static let shared = LoginManage()
    private override init() {
        super.init()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth.init(authUI: authUI!),
        ]
        authUI?.providers = providers
    }
    
    class func saveAppleUserIDAndUserName(userID: String, userName: String) {
        
        let keychainManager = Keychain(service: keyChainKey)
        do {
            try keychainManager.set(userID, key: "AppleUserID")
            try keychainManager.set(userName, key: "AppleUserName")
        } catch let error {
            print(error)
        }
    }
    
    class func obtainAppleUserID() -> String {
        let keychainManager = Keychain(service: keyChainKey)
        let userID = keychainManager["AppleUserID"]
        return userID ?? ""
    }
    
    class func obtainAppleUserName() -> String {
        let keychainManager = Keychain(service: keyChainKey)
        let userID = keychainManager["AppleUserName"]
        return userID ?? ""
    }
    
    class func currentLoginUser() -> ApploginUserInfoModel? {
        
        let userModel = ApploginUserInfoModel()
        
        if let currentUser = Auth.auth().currentUser {
            
            userModel.isAppleLogin = false
            if let userName = currentUser.providerData[0].displayName {
                userModel.userName = userName
            } else {
                userModel.userName = currentUser.providerData[0].email
            }
            
            return userModel
            
        }
        
        if self.obtainAppleUserID().count > 0 {
            userModel.isAppleLogin = false
            userModel.userName = self.obtainAppleUserName()
            return userModel
        }
        
        return nil
    }
    
    
    func googleUserLogout() {
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
    }
    
    func appleUserLogout() {
        let keychainManager = Keychain(service: keyChainKey)
        do {
            try keychainManager.set("", key: "AppleUserID")
            try keychainManager.set("", key: "AppleUserName")
        } catch let error {
            print(error)
        }
    }
    
    func logout() {
        googleUserLogout()
        appleUserLogout()
    }
    
    func obtainVC() -> FUIAuthPickerViewController {
        return APLoginVC.init(authUI: self.authUI!)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        var a = authDataResult?.additionalUserInfo?.profile?["name"]
    }
    
}

extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", block: ()->Void) {
        objc_sync_enter(self)
        
        defer
        {
            objc_sync_exit(self)
        }

        if _onceToken.contains(token)
        {
            return
        }

        _onceToken.append(token)
        block()
    }
}
