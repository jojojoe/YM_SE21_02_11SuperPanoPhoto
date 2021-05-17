//
//  DataManager.swift
//  MGymMakeGrid
//
//  Created by JOJO on 2021/2/8.
//

import UIKit
import SwifterSwift
class GCFilterItem: Codable {

    let filterName : String
    let type : String
    let imageName : String
    
    enum CodingKeys: String, CodingKey {
        case filterName
        case type
        case imageName
    }
    
}


struct GridItem: Codable {
    var isPro: Bool? = false
    var thumb: String? = ""
    var gridIndexs: [Int]? = [0, 3, 6,]
    
}

struct ShapeItem: Codable {
    var isPro: Bool? = false
    var thumb: String? = ""
    var bigImg: String? = ""
    
}


class GCStickerItem: Codable {
    let contentImageName : String
    let thumbnail : String
    let isPro : Bool?
}


class DataManager: NSObject {
    static let `default` = DataManager()
    
    var textColors: [String] = []
    var textFontNames: [String] = []
    var bgColors: [String] = []
    var gridList: [GridItem] {
        return DataManager.default.loadJson([GridItem].self, name: "GridList") ?? []
    }
    var shapeList: [ShapeItem] {
        return DataManager.default.loadJson([ShapeItem].self, name: "ShapeList") ?? []
    }
    
    var filterList : [GCFilterItem] {
        return DataManager.default.loadPlist([GCFilterItem].self, name: "FilterList") ?? []
    }
    var stickerList : [GCStickerItem] {
        return DataManager.default.loadJson([GCStickerItem].self, name: "StickerList") ?? []
    }
    var slideMoban1List: [String] = ["moban1_1"]
    var slideMoban2List: [String] = ["moban2_1","moban2_2","moban2_3","moban2_4","moban2_5","moban2_6"]
    var slideMoban3List: [String] = ["moban3_1","moban3_2","moban3_3","moban3_4","moban3_5","moban3_6"]
    var slideMoban4List: [String] = ["moban4_1","moban4_2","moban4_3","moban4_4","moban4_5","moban4_6","moban4_7"]
    var slideMoban5List: [String] = ["moban5_1","moban5_2","moban5_3","moban5_4","moban5_5","moban5_6","moban5_7","moban5_8"]
    var slideMoban6List: [String] = ["moban6_1","moban6_2","moban6_3","moban6_4","moban6_5","moban6_6","moban6_7","moban6_8"]
    
    
    
    override init() {
        super.init()
        loadData()
    }
    
    func loadData() {
        
        
        textColors = ["#000000","#FFFFFF","#FFB6C1","#FF69B4","#FF00FF","#7B68EE","#0000FF","#4169E1","#00BFFF","#00FFFF","#F5FFFA","#3CB371","#98FB98","#32CD32","#FFFF00","#FFD700","#FFA500","#FF7F50","#CD853F","#00FA9A"]
        textFontNames = ["Avenir-Heavy", "Baskerville-BoldItalic", "ChalkboardSE-Bold", "Courier-BoldOblique", "Didot-Bold", "DINCondensed-Bold", "Futura-MediumItalic", "Georgia-Bold", "KohinoorBangla-Semibold", "NotoSansKannada-Bold", "Palatino-BoldItalic", "SnellRoundhand-Bold", "Verdana-Bold",  "GillSans-Bold", "Rockwell-Bold", "TrebuchetMS-Bold"]
        
        bgColors = ["#FFFFFF","#000000","#FFB6C1","#FF69B4","#FF00FF","#7B68EE","#0000FF","#4169E1","#00BFFF","#00FFFF","#F5FFFA","#3CB371","#98FB98","#32CD32","#FFFF00","#FFD700","#FFA500","#FF7F50","#CD853F","#00FA9A"]
        
        
    }
    
}

extension DataManager {
    func loadJson<T: Codable>(_: T.Type, name: String, type: String = "json") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try! JSONDecoder().decode(T.self, from: data)
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        return nil
    }
    
    func loadJson<T: Codable>(_:T.Type, path:String) -> T? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            do {
                return try PropertyListDecoder().decode(T.self, from: data)
            } catch let error as NSError {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func loadPlist<T: Codable>(_:T.Type, name:String, type:String = "plist") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            return loadJson(T.self, path: path)
        }
        return nil
    }
    
}


// filter
extension DataManager {
    func filterOriginalImage(image: UIImage, lookupImgNameStr: String) -> UIImage? {
        
        if let gpuPic = GPUImagePicture(image: image), let lookupImg = UIImage(named: lookupImgNameStr), let lookupPicture = GPUImagePicture(image: lookupImg) {
            let lookupFilter = GPUImageLookupFilter()
            
            gpuPic.addTarget(lookupFilter, atTextureLocation: 0)
            lookupPicture.addTarget(lookupFilter, atTextureLocation: 1)
            lookupFilter.intensity = 0.7
            
            lookupPicture.processImage()
            gpuPic.processImage()
            lookupFilter.useNextFrameForImageCapture()
            let processedImage = lookupFilter.imageFromCurrentFramebuffer()
            return processedImage
        } else {
            return nil
        }
        return nil
    }
}


