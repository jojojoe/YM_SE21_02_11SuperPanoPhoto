//
//  HightLightingPriceManager.swift
//  HighLighting
//
//  Created by Charles on 2020/8/13.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import Defaults
import SwiftyStoreKit

public class HightLightingPriceManager  {
    
    public static var `default` = HightLightingPriceManager()
    struct IAPProduct: Codable {
         public var iapID: String
         public var price: Double
         public var priceLocale: Locale
         public var localizedPrice: String?
         public var currencyCode: String?
     }
    
    static var localIAPProducts: [IAPProduct]? = Defaults[.localIAPProducts] {
        didSet { Defaults[.localIAPProducts] = localIAPProducts }
    }

    static var localIAPCacheTime: TimeInterval? = Defaults[.localIAPCacheTime] {
        didSet { Defaults[.localIAPCacheTime] = localIAPCacheTime }
    }
    
    func removeAllLocalIAPProducts() {
        HightLightingPriceManager.localIAPProducts = nil
        HightLightingPriceManager.localIAPCacheTime = nil
    }
    
    func retrieveProductsInfo(iapList: [String],
                              completion: @escaping (([IAPProduct]?) -> Void)) {
        let requestList = Set(iapList)
        SwiftyStoreKit.retrieveProductsInfo(requestList) { result in
            if  result.error != nil {
                completion(nil)
                return
            }
          
            let priceList = result.retrievedProducts.compactMap { $0 }
            let localList = priceList.compactMap { HightLightingPriceManager.IAPProduct(
                iapID: $0.productIdentifier,
                price: $0.price.doubleValue,
                priceLocale: $0.priceLocale,
                localizedPrice: $0.localizedPrice,
                currencyCode: $0.priceLocale.currencyCode
                ) }
            
            HightLightingPriceManager.localIAPProducts = localList
            HightLightingPriceManager.localIAPCacheTime = Date().unixTimestamp
            completion(localList)
        }
    }
}


