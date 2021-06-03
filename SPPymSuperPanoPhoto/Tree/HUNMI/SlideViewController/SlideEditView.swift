//
//  SlideEditView.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/7.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

class SlideEditView: UIView {
    
    var proportion: TSToolSizeProportionBtn.SizeType = .size1_1
    var pageNumber: Int = 2000
    let scrolleView = UIScrollView.init()
    let contentImageView = UIImageView()
    var guideView = UIView.init()
    var myProportion: CGFloat = 1
    var miniProportion: CGFloat?
    var imageViewWidth: CGFloat?
    var imageViewHeight: CGFloat?
    var contentImageViewCenter = CGPoint.zero
    var isSelectZoom = true
    
    init(frame: CGRect, contentImage: UIImage) {
        super.init(frame: frame)
        
        self.scrolleView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrolleView.maximumZoomScale = 3
        scrolleView.backgroundColor = UIColor.color(hexString: "#FFFFFF")
        scrolleView.delegate = self
        self.addSubview(self.scrolleView)
        
        
        let contentImage = contentImage
        if contentImage.size.width > contentImage.size.height {
            //横图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.height / (contentImage.size.height) * (contentImage.size.width), height: scrolleView.frame.size.height)
            
        } else {
            //竖图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.width, height: scrolleView.frame.size.width / (contentImage.size.width) * (contentImage.size.height))
        }

        contentImageView.image = contentImage
        contentImageView.contentMode = .scaleAspectFit
        self.scrolleView.addSubview(contentImageView)
        self.scrolleView.contentSize = contentImageView.frame.size
        self.miniProportion = self.frame.size.width / contentImageView.frame.size.width
        self.scrolleView.minimumZoomScale = self.frame.size.width / contentImageView.frame.size.width
        
        self.guideView = UIView.init(frame: self.bounds)
        guideView.backgroundColor = .clear
        self.addSubview(guideView)
        
        getPageNumberAndProportion()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let resultView = super.hitTest(point, with: event)
        
        if resultView?.isDescendant(of: self) ?? false {
            return scrolleView
        } else {
            return resultView
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func changeGuideView(pageNum: Int, proportion: TSToolSizeProportionBtn.SizeType) {
        self.pageNumber = pageNum
        self.proportion = proportion
        
        for subView in self.guideView.subviews {
            subView.removeFromSuperview()
        }
        
        getPageNumberAndProportion()
    }
    
    func getPageNumberAndProportion() {
        self.isSelectZoom = false
        let pageNum = self.pageNumber + 1
        var proportionWidth: CGFloat = 1
        var proprotionHeight: CGFloat = 1
        
        switch self.proportion {
        case .size1_1:
            proportionWidth = 1
            proprotionHeight = 1
            break
        case .size4_5:
            proportionWidth = 4
            proprotionHeight = 5
            break
        case .size9_16:
            proportionWidth = 9
            proprotionHeight = 16
            break
        default:
            break
        }
        
        let imageViewWidth = self.frame.size.width / CGFloat(pageNum)
        let imageViewHeight = imageViewWidth / proportionWidth * proprotionHeight
        self.imageViewHeight = imageViewHeight
        let imageY = (self.frame.size.height - imageViewHeight) / 2
        
        
        for i in 0 ..< pageNum {
            let imageView = UIImageView.init(frame: CGRect(x: CGFloat(i) * imageViewWidth, y: imageY, width: imageViewWidth, height: imageViewHeight))
            imageView.image = UIImage(named: "border")
            self.guideView.addSubview(imageView)
        }
        
        self.myProportion = imageViewHeight / self.frame.size.height
        self.myProportion = self.myProportion < (miniProportion ?? 0.5) ? (miniProportion ?? 0.5) : self.myProportion
        self.scrolleView.minimumZoomScale = self.myProportion
        self.scrolleView.setZoomScale(self.myProportion, animated: true)
        
        zoomFunction()
    }
    

}

extension SlideEditView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        dPrint(item: scale)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if self.isSelectZoom {
                self.zoomFunction()
            } else {
                self.isSelectZoom = true
            }
        }
         
    }
    
    func zoomFunction() {
        let scale = self.scrolleView.zoomScale
        if self.contentImageView.frame.size.height * scale > self.frame.size.height {
            let difference = self.frame.size.height - (self.imageViewHeight ?? 0)
            
            
            self.scrolleView.contentSize = CGSize(width: self.scrolleView.contentSize.width,
                                                  height: self.contentImageView.bounds.size.height * self.scrolleView.zoomScale + difference)
            
            self.scrolleView.setContentOffset(CGPoint(x: self.scrolleView.contentOffset.x, y: self.scrolleView.contentOffset.y + difference / 2), animated: true)
        } else {
            let difference = self.contentImageView.bounds.size.height * scrolleView.zoomScale - (self.imageViewHeight ?? 0)
 
            self.scrolleView.contentSize = CGSize(width: self.scrolleView.contentSize.width,
                                                  height: self.frame.size.height + difference)

            
            
            self.scrolleView.setContentOffset(CGPoint(x: self.scrolleView.contentOffset.x, y: self.scrolleView.contentOffset.y + difference / 2), animated: true)
        }
        
        contentImageCenter()
    }
    
    func contentImageCenter() {
        let offsetX = (self.scrolleView.bounds.size.width > self.scrolleView.contentSize.width) ? (self.scrolleView.bounds.size.width - self.scrolleView.contentSize.width) / 2 : 0
        let offsetY = (self.scrolleView.bounds.size.height > self.scrolleView.contentSize.height) ? (self.scrolleView.bounds.size.height - self.scrolleView.contentSize.height) / 2 : 0
        self.contentImageView.center = CGPoint(x: CGFloat(self.scrolleView.contentSize.width / 2 + offsetX), y: CGFloat(self.scrolleView.contentSize.height / 2 + offsetY))

    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
//        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0
//        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0
//        contentImageView.center = CGPoint(x: CGFloat(scrollView.contentSize.width / 2 + offsetX), y: CGFloat(scrollView.contentSize.height / 2 + offsetY))
    }
}
