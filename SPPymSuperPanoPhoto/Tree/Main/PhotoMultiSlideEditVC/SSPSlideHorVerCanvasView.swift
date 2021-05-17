//
//  SSPSlideHorVerCanvasView.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/14.
//

import UIKit

class SSPSlideHorVerCanvasView: UIView {
    
    enum SlideType {
        case hor
        case ver
    }
    let scrollBgView = UIScrollView()
    
    var contentImages: [UIImage]
    var slideType: SlideType = .hor
    var contentImageViews: [UIImageView] = []
    
    init(frame: CGRect, images: [UIImage]) {
        
        self.contentImages = images
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateContentFilteredImgs(imgs: [UIImage]) {
        contentImages = imgs
        for (index, imgV) in contentImageViews.enumerated() {
            let img = contentImages[safe: index]
            imgV.image = img
        }
    }
    
    func updateSlideType(slide: SlideType, imgs: [UIImage]) {
        slideType = slide
        contentImages = imgs
        updateScrollContent()
    }
    
}

extension SSPSlideHorVerCanvasView {
    func setupView() {
        
        addSubview(scrollBgView)
        scrollBgView.backgroundColor = .white
        scrollBgView.snp.makeConstraints {
            $0.top.right.bottom.left.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        updateScrollContent()
        
    }
    
    func updateScrollContent() {
        
        scrollBgView.removeSubviews()
        contentImageViews = []
        
        if slideType == .hor {
            //
            var totalWidth: CGFloat = 0
            var totalHieght: CGFloat = frame.size.height
            
            for img in contentImages {
                let imgW = totalHieght * (img.size.width / img.size.height)
                let imgV = UIImageView(image: img)
                imgV.frame = CGRect(x: totalWidth, y: 0, width: imgW, height: totalHieght)
                scrollBgView.addSubview(imgV)
                contentImageViews.append(imgV)
                //
                totalWidth += imgW
                
            }
            scrollBgView.contentSize = CGSize(width: totalWidth, height: totalHieght)
            
        } else {
            var totalWidth: CGFloat = frame.size.width
            var totalHieght: CGFloat = 0
            
            for img in contentImages {
                let imgH = totalWidth * (img.size.height / img.size.width)
                let imgV = UIImageView(image: img)
                imgV.frame = CGRect(x: 0, y: totalHieght, width: totalWidth, height: imgH)
                scrollBgView.addSubview(imgV)
                contentImageViews.append(imgV)
                //
                totalHieght += imgH
                
            }
            scrollBgView.contentSize = CGSize(width: totalWidth, height: totalHieght)
        }
         
    }
    
    
}

