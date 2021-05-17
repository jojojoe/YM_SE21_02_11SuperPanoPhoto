//
//  MSCanvasPhotoView.swift
//  MSMagicStory
//
//  Created by JOJO on 2020/5/19.
//  Copyright © 2020 JOJO. All rights reserved.
//

import UIKit

class MSCanvasPhotoView: UIView {

    
    var scrollBgView: UIScrollView = UIScrollView.init(frame: .zero)
    var contentImageView: UIImageView = UIImageView.init(frame: .zero)
    var stuffAddView: UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    var contentImage: UIImage? {
        didSet {
            contentImageView.image = contentImage
            updateContent()
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupUIStuffView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(scrollBgView)
        scrollBgView.showsHorizontalScrollIndicator = false
        scrollBgView.showsVerticalScrollIndicator = false
        scrollBgView.addSubview(contentImageView)
        
        scrollBgView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        scrollBgView.contentSize = CGSize.init(width: frame.width, height: frame.height)
        contentImageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        
        
    }
    
    func setupUIStuffView() {
        stuffAddView.image = UIImage(named: "")
        stuffAddView.contentMode = .center
        stuffAddView.center = CGPoint.init(x: frame.width / 2, y: frame.height / 2)
        addSubview(stuffAddView)
    }
    
    func updateContent() {
        if let contentImage = contentImage {
            scrollBgView.backgroundColor = .clear
            contentImageView.backgroundColor = .clear
            stuffAddView.isHidden = true
            
            let imgWH = contentImage.size.width / contentImage.size.height
            let bgWH = bounds.width / bounds.height
            var contentWidth: CGFloat = 0
            var contentHeight: CGFloat = 0
            if imgWH > bgWH {
                //hor scroll
                contentHeight = bounds.height
                contentWidth = contentHeight * imgWH
            } else {
                //ver scroll
                contentWidth = bounds.width
                contentHeight = contentWidth / imgWH
            }
            contentImageView.frame = CGRect.init(x: 0, y: 0, width: contentWidth, height: contentHeight)
            scrollBgView.contentSize = CGSize.init(width: contentWidth, height: contentHeight)
            
        } else {
            scrollBgView.backgroundColor = UIColor.init(hexString: "F3F3F3")
            contentImageView.backgroundColor = UIColor.init(hexString: "F3F3F3")
            stuffAddView.isHidden = false
        }
    }

    
    func updateContentImage(image: UIImage) {
        contentImage = image
    }
    
    
    
    func showAddIconStatus(isShow: Bool) {
        
        if let _ = contentImage {
            stuffAddView.isHidden = true
        } else {
            stuffAddView.isHidden = !isShow
        }
    }
    
    
}
