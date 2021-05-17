//
//  PhotoMultiCanvasView.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/12.
//

import UIKit
import SVGKit
import YPImagePicker

extension PhotoMultiCanvasView {
    func updateFilter(filteredImgs: [UIImage]) {
        contentImages.removeAll()
        for (index, img) in filteredImgs.enumerated() {
            let photoView = photoViews[safe: index]
            photoView?.contentImage = img
        }
    }
//    func updateFilter(filter: YPFilter) {
//        contentImages.removeAll()
//        for (index, img) in contentImages_origin.enumerated() {
//            let imgProcess = SSPFilterManager.default.processImage(image: img, filter: filter)
//            contentImages.append(imgProcess)
//            let photoView = photoViews[safe: index]
//            photoView?.contentImage = imgProcess
//        }
//    }
    
    func updateMoban(moban: String, imgs: [UIImage]) {
        contentImages = imgs
        mobanSVGName = moban
        let svgName = mobanSVGName
        let svgWidth: CGFloat = 120
        let svgHeight: CGFloat = 120
        let svgImage = SVGKImage.init(contentsOfFile: Bundle.main.path(forResource: svgName, ofType: nil))
        svgImage?.size = CGSize.init(width: svgWidth, height: svgHeight)
        removeSubviews()
        photoViews = []
        
        let strings = svgName.components(separatedBy: "_")
        if let numbStr = strings.first?.replacingOccurrences(of: "moban", with: ""), let numb = numbStr.int {
            let preStr = "view"
            for itemIdx in 1...numb {
                let layer = svgImage?.layer(withIdentifier: "\(preStr)\(itemIdx)")
                
                let xBili = (layer?.frame.origin.x ?? 0) / svgWidth
                let yBili = (layer?.frame.origin.y ?? 0) / svgHeight
                let widthBili = (layer?.frame.size.width ?? 0) / svgWidth
                let heightBili = (layer?.frame.size.height ?? 0) / svgHeight
                
                let photoX = frame.size.width * xBili
                let photoY = frame.size.height * yBili
                let photoW = frame.size.width * widthBili
                let photoH = frame.size.height * heightBili
                
                let msPhotoView = MSCanvasPhotoView.init(frame: CGRect.init(x: photoX, y: photoY, width: photoW, height: photoH))
                addSubview(msPhotoView)
                photoViews.append(msPhotoView)
            }
            
        }
        for (index, img) in contentImages.enumerated() {
            
            let photoView = photoViews[safe: index]
            photoView?.contentImage = img
        }
    }
}

class PhotoMultiCanvasView: UIView {
    var mobanSVGName: String
    var contentImages: [UIImage]
    var photoViews: [MSCanvasPhotoView] = []
    
    init(frame: CGRect, mobanName: String, images: [UIImage]) {
        self.mobanSVGName = "\(mobanName).svg"
        self.contentImages = images
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let svgName = mobanSVGName
        let svgWidth: CGFloat = 120
        let svgHeight: CGFloat = 120
        let svgImage = SVGKImage.init(contentsOfFile: Bundle.main.path(forResource: svgName, ofType: nil))
        svgImage?.size = CGSize.init(width: svgWidth, height: svgHeight)
        
        removeSubviews()
        photoViews = []
        
        let strings = svgName.components(separatedBy: "_")
        if let numbStr = strings.first?.replacingOccurrences(of: "moban", with: ""), let numb = numbStr.int {
            let preStr = "view"
            for itemIdx in 1...numb {
                let layer = svgImage?.layer(withIdentifier: "\(preStr)\(itemIdx)")
                
                let xBili = (layer?.frame.origin.x ?? 0) / svgWidth
                let yBili = (layer?.frame.origin.y ?? 0) / svgHeight
                let widthBili = (layer?.frame.size.width ?? 0) / svgWidth
                let heightBili = (layer?.frame.size.height ?? 0) / svgHeight
                
                let photoX = frame.size.width * xBili
                let photoY = frame.size.height * yBili
                let photoW = frame.size.width * widthBili
                let photoH = frame.size.height * heightBili
                
                let msPhotoView = MSCanvasPhotoView.init(frame: CGRect.init(x: photoX, y: photoY, width: photoW, height: photoH))
                addSubview(msPhotoView)
                photoViews.append(msPhotoView)
            }
            
        }
        for (index, img) in contentImages.enumerated() {
            
            let photoView = photoViews[safe: index]
            photoView?.contentImage = img
        }
        
    }

}
