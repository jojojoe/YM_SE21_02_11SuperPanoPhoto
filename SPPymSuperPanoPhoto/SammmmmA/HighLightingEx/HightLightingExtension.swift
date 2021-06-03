//
//  HightLightingExtension.swift
//  HighLighting
//
//  Created by Charles on 2020/8/13.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import Defaults
import Alertift

public struct LightCookies: Codable, Equatable {
    public var userName: String?
    public var cookieString: String?
    public var dsUser: String?
    public var shbid: String?
    public var shbts: String?
    public var csrftoken: String?
    public var rur: String?
    public var mid: String?
    public var dsUserId: String?
    public var urlgen: String?
    public var sessionid: String?
    private enum CodingKeys: String, CodingKey {
        case dsUser = "ds_user"
        case shbid
        case shbts
        case csrftoken
        case rur
        case mid
        case dsUserId = "ds_user_id"
        case urlgen
        case sessionid
        case cookieString
        case userName
    }
}

extension Notification.Name {
    static let Pre = Notification.Name("Pre")
}

extension Bundle {
    static func loadJson<T: Codable>(_: T.Type, name: String, type: String = "json") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
//                do {
                return try! JSONDecoder().decode(T.self, from: data)
//                } catch let error as NSError {
//                    debugPrint(error)
//                }
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        return nil
    }
}


public extension Dictionary where Key == String, Value == String {
    func cookiesDictToModel() -> LightCookies? {
        let cookieString = compactMap { $0 + "=" + $1 }.joined(separator: "; ")
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
            var model = try? JSONDecoder().decode(LightCookies.self, from: data) else { return nil }
        model.cookieString = cookieString
        debugPrint("**cookiesDictToModel** = \(model)")
        return model
    }
}

extension String {
    func convertCookies() -> LightCookies? {
        let parameters = ["ds_user", "csrftoken", "ds_user_id",
                          "urlgen", "sessionid", "shbid",
                          "shbts", "rur", "mid","ig_did"]

        let array = components(separatedBy: "; ")

        var dict = [String: String]()
        array.forEach { str in
            parameters.forEach { parameter in
                if str.contains(parameter),
                    let index = str.range(of: "\(parameter)=")?.upperBound {
                    let item = str.suffix(from: index).description
                    if !item.isEmpty {
                        dict[parameter] = item
                    }
                }
            }
        }

        let cookieString = dict.compactMap { $0 + "=" + $1 }.joined(separator: "; ")
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            var model = try? JSONDecoder().decode(LightCookies.self, from: data) else { return nil }
        model.cookieString = cookieString
        debugPrint(model)
        return model
    }
}

func debugOnly(_ action: () -> Void) {
    assert(
        {
            action()
            return true
        }()
    )
}



struct Alert {
    static func error(_ value: String?, title: String? = "Error", success: (() -> Void)? = nil) {
        Alertift
            .alert(title: title, message: value)
            .action(.cancel("OK"), handler: { _, _, _ in
                success?()
            })
            .show(on: UIApplication.rootController?.visibleVC, completion: nil)
    }

    static func message(_ title:String?,_ value: String?, success: (() -> Void)? = nil) {
        Alertift
            .alert(title: title, message: value)
            .action(.cancel("OK"), handler: { _, _, _ in
                success?()
            })
            .show(on: UIApplication.rootController?.visibleVC, completion: nil)
    }
    
    static func message(_ value: String?, success: ((_ s:Bool) -> Void)? = nil) {
        Alertift
            .alert(message: value)
            .action(.default("OK"), handler: { _, _, _ in
                success?(true)
            })
            .action(.cancel("Cancel"), handler: { _, _, _ in
                success?(false)
            })
            .show(on: UIApplication.rootController?.visibleVC, completion: nil)
    }
}

extension Array where Element: Equatable {
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item) {
            move(at: index, to: newIndex)
        }
    }

    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }

    mutating func sendToBack(item: Element) {
        move(item, to: endIndex-1)
    }
}

extension Array {
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}

extension Encodable {
    func dictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

// MARK: - DefaultKeys

extension Defaults.Keys {
    static let cache = Key<HightLigtingHelper.Cache?>("HightLigting.Cache")
    static let lastTimeSpace = Key<TimeInterval>("ContentWebView_LastTimeSpace", default: Date().timeIntervalSince1970)
    static let currentlyFireUser =
        Key<HightLigtingCacheUser?>("UserManager.CurrentlyFireUser")
    static let HightLigtingUserList =
        Key<[HightLigtingCacheUser]>("UserManager.HightLigtingUserList", default: [])
    static let localIAPProducts = Key<[HightLightingPriceManager.IAPProduct]?>("PurchaseManager.LocalIAPProducts")
    static let localIAPCacheTime = Key<TimeInterval?>("PurchaseManager.LocalIAPCacheTime")

    static let isLoginButtonFirstStart = Key<Bool?>("Adjust.login_button_1ststart")
    static let isBaselineShowFirst = Key<Bool?>("Adjust.baseline_show_1st")
    static let isLoginButtonFirstClick = Key<Bool?>("Adjust.login_button_1stclick")
    
}


