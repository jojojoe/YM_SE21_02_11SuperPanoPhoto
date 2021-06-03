//
//  DataEncoding.swift
//  HighLighting
//
//  Created by Charles on 2020/12/14.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit
import Foundation
import CryptoSwift


class DataEncoding {
    static let shared = DataEncoding()
    private init() {
        
    }
    let SHAkey = "HightLigting"
    let key = ("HightLigting".data(using: .utf8)?.bytes)!
    let iv = ("1234567890123456".data(using: .utf8)?.bytes)!
    //AES-ECB128加密
    func aesEncrypted(string:String) -> String? {
        var encryptedBytes:String?
        let ps = (string.data(using: .utf8)?.bytes)!
        do {
            encryptedBytes = try AES(key:  Padding.zeroPadding.add(to: SHAkey.bytes, blockSize: AES.blockSize), blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(ps).toBase64()
        } catch {
            debugPrint(error)
        }

        return encryptedBytes
    }


        //AES-ECB128解密
    func aesDecrypted(string:String?) -> String? {
        //decode base64
        guard let rString = string else { return nil }
        let data = Data(base64Encoded: rString)
        guard let encrypted = data?.bytes else { return nil }
        var decryptedString:String?
        do {
            let decrypted = try AES(key:  Padding.zeroPadding.add(to: SHAkey.bytes, blockSize: AES.blockSize), blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(encrypted)

            let decryptedData = Data(decrypted)

            decryptedString = String(data: decryptedData, encoding: .utf8)
            // block size exceeded
        } catch {
           debugPrint(error)
        }


        return decryptedString
    }


}
