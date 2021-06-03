//
//  ModelManagerStruct.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/19.
//

import Foundation

class StoreItem: Identifiable, ObservableObject {
    var id: Int = 0
    var iapId: String = ""
    var coin: Int  = 0
    @Published var price: String = ""
    var color: String = ""
    init(id: Int, iapId: String, coin: Int, price: String, color: String) {
        self.id = id
        self.iapId = iapId
        self.coin = coin
        self.price = price
        self.color = color
        
    }
}
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
