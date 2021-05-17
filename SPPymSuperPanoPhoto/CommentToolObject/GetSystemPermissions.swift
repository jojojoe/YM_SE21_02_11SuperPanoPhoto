//
//  GetSystemPermissions.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/6.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

class GetSystemPermissions: NSObject {
    static func getPhotoPermissions(comletion: @escaping (Bool)->Void) {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            comletion(true)
        case PHAuthorizationStatus.denied,PHAuthorizationStatus.restricted:
            comletion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    comletion(status == PHAuthorizationStatus.authorized ? true:false)
                }
            })
        @unknown default:
            comletion(false)
        }
    }
}
