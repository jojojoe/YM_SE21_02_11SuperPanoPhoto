//
//  PublicFile.swift
//  BlukEdit
//
//  Created by 薛忱 on 2019/8/26.
//  Copyright © 2019 薛忱. All rights reserved.
//

import Foundation
import UIKit
import Then


 
let screenScale = UIScreen.main.scale

let testImageName = "123"

let commentAnimationTime = 18

//默认字体名称
let def_fontName = "PingFangSC-Semibold"

//默认字体颜色
//let def_fontColor = "#021D3D"

//屏幕宽 高
let screen_width_CGFloat = UIScreen.main.bounds.width
let screen_width_int = Int(UIScreen.main.bounds.width)

let screen_hight_CGFloat = UIScreen.main.bounds.height
let screen_hight_int = Int(UIScreen.main.bounds.height)

//判断是否为iPad
let isIpad = (UIDevice.current.model == "iPad")
//判断是否为iPhone
let isIphone = (UIDevice.current.model == "iPhone")

// 多国
func localizedString(key: String) -> String {
    return Bundle.main.localizedString(forKey: key, value:"", table: nil)
}

//判断手机是否为刘海屏

func newIsFullScreen() -> (Bool) {
    let size = UIScreen.main.bounds.size
    let notchValue: Int = Int(size.width / size.height * 100)
    
    if 216 == notchValue || 46 == notchValue {
        return true
    }
    
    return false
}

func isFullScreen() -> (Bool) {
        
    let size = UIScreen.main.bounds.size
    let notchValue: Int = Int(size.width / size.height * 100)
    
    if 216 == notchValue || 46 == notchValue {
        return true
    }
    
    return false
}

//自定义字体
func customFont(fontName: String, size: CGFloat) -> UIFont {
    if fontName.count <= 0 || fontName == def_fontName{
        return UIFont(name: def_fontName, size: size)!
    }
    let stringArray: Array = fontName.components(separatedBy: ".")
    let path = Bundle.main.path(forResource: stringArray[0], ofType: stringArray[1])
    let fontData = NSData.init(contentsOfFile: path ?? "")
    
    let fontdataProvider = CGDataProvider(data: CFBridgingRetain(fontData) as! CFData)
    let fontRef = CGFont.init(fontdataProvider!)!
    
    var fontError = Unmanaged<CFError>?.init(nilLiteral: ())
    CTFontManagerRegisterGraphicsFont(fontRef, &fontError)
    
    let fontName: String =  fontRef.postScriptName as String? ?? ""
    
    let font = UIFont(name: fontName, size: size)
    
    return font ?? UIFont(name: def_fontName, size: size)!
}

//UIView 转 UIimage
func getImageFromView(view: UIView) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
    let content = UIGraphicsGetCurrentContext()!
    content.setFillColor(UIColor.clear.cgColor)
    view.layer.render(in: content)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
    
}

func getImageFromView(view: UIView, size: CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let content = UIGraphicsGetCurrentContext()!
    content.setFillColor(UIColor.clear.cgColor)
    view.layer.render(in: content)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
    
}

//email
let infoForDictionary = Bundle.main.infoDictionary
//func feefbackInfo(appName:String,appVersion:String,deviceModel:String,systemVersion:String,deviceName:String) -> String {
//    //    , kCurrentAppVersion, UIDevice.current.model, UIDevice.current.systemVersion, kDeviceName
//    return "<br /><br /><br /><br /><font color=\"#9F9F9F\" style=\"font-size: 13px;\"> <i>(\(appName) \(appVersion) on \(appVersion) running with iOS \(systemVersion), device \(deviceName)</i>)</font>"
//}
//let feedbackDeviceInfoFormat = "<br /><br /><br /><br /><font color=\"#9F9F9F\" style=\"font-size: 13px;\"> <i>(%@ %@ on %@ running with iOS %@, device %@</i>)</font>"
func feefbackInfo(appName:String,appVersion:String,deviceModel:String,systemVersion:String,deviceName:String) -> String {
    //    , kCurrentAppVersion, UIDevice.current.model, UIDevice.current.systemVersion, kDeviceName
    return "<br /><br /><br /><br /><font color=\"#9F9F9F\" style=\"font-size: 13px;\"> <i>(\(appName) \(appVersion) on iPhone running with iOS \(systemVersion), device \(deviceName)</i>)</font>"
}
let feedbackDeviceInfoFormat = "<br /><br /><br /><br /><font color=\"#9F9F9F\" style=\"font-size: 13px;\"> <i>(%@ %@ on %@ running with iOS %@, device %@</i>)</font>"
let CurrentAppVersion = infoForDictionary?["CFBundleShortVersionString"] as? String

var DeviceName = UIDevice.current.systemName


//debug print
func dPrint(item: @autoclosure () -> Any) {
    #if DEBUG
    debugPrint(item())
    #endif
}

extension UIColor {
    public class func color(hexString: String, alpha: CGFloat? = 1.0) -> UIColor {
        var cString = hexString.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = String(cString[cString.index(after: cString.startIndex)..<cString.endIndex])
            
        }
        if (cString.count != 6) {
            return UIColor.clear
        }
        let rString = cString[..<cString.index(cString.startIndex, offsetBy: 2)]
        let gString = cString[cString.index(cString.startIndex, offsetBy: 2)..<cString.index(cString.startIndex, offsetBy: 4)]
        let bString = cString[cString.index(cString.endIndex, offsetBy: -2)..<cString.endIndex]
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: String(rString)).scanHexInt32(&r)
        Scanner(string: String(gString)).scanHexInt32(&g)
        Scanner(string: String(bString)).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha!)
    }
}

extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}

extension UIImage {
    
    func getPixelColor(pos:CGPoint) -> UIColor {
        let pixelData = (self.cgImage?.dataProvider)!.data
        let data = CFDataGetBytePtr(pixelData)
        let pixelInfo = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let red = CGFloat(data?[pixelInfo] ?? 0) / 255
        let green = CGFloat(data?[pixelInfo + 1] ?? 0) / 255
        let blue = CGFloat(data?[pixelInfo + 2] ?? 0) / 255
        let alpha = CGFloat(data?[pixelInfo + 3] ?? 0) / 255
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    /**
     * 改变UIimage 的 imageOrientation 为 .up
     */
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    
    func originImageToScaleSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage ?? UIImage()
    }
}

extension UIView {
    
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func customCorner(byRoundingCorners corners: UIRectCorner, roundedRect: CGRect, cornerRadii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

extension String {
    func getLableHeigh(font:UIFont, width:CGFloat) -> CGFloat {
        
        let size = CGSize.init(width: width, height:  CGFloat(MAXFLOAT))
        
        //        let dic = [NSAttributedStringKey.font:font] // swift 4.0
        let dic = [NSAttributedString.Key.font:font] // swift 3.0
        
        let strSize = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size
        
        return ceil(strSize.height) + 1
    }
    ///获取字符串的宽度
    func getLableWidth(font:UIFont, height:CGFloat) -> CGFloat {
        
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
}

extension UIScrollView {
    func captureScrollView() -> UIImage {
        var image = UIImage()
        
        UIGraphicsBeginImageContext(self.contentSize)
        
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        
        self.contentOffset = CGPoint.zero
        self.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
