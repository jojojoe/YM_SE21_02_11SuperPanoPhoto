//
//  VideoEditView.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/8.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

protocol VideoEditViewDelegate: class {
    func startAnimation()
    func pauseAnimation()
}

class VideoEditView: UIView {
    
    let scrolleView = UIScrollView.init()
    let contentImageView = UIImageView()
    var image: UIImage = UIImage()
    var isHorizontal = true
    var proporIndex = 1
    var playButton: UIButton?
    weak var delegate: VideoEditViewDelegate?
    
    init(frame: CGRect, contentImage: UIImage) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.scrolleView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrolleView.backgroundColor = .white
        self.addSubview(self.scrolleView)
        
        self.image = contentImage
        let contentImage = contentImage
        if contentImage.size.width > contentImage.size.height {
            //横图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.height / (contentImage.size.height) * (contentImage.size.width), height: scrolleView.frame.size.height)
            isHorizontal = true
            
        } else {
            //竖图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.width, height: scrolleView.frame.size.width / (contentImage.size.width) * (contentImage.size.height))
            isHorizontal = false
        }

        contentImageView.image = contentImage
        contentImageView.contentMode = .scaleAspectFit
        self.scrolleView.addSubview(contentImageView)
        self.scrolleView.contentSize = contentImageView.frame.size
        
        self.playButton = UIButton().then({ (button) in
            button.addTarget(self, action: #selector(playButtonClick(button:)), for: .touchUpInside)
            button.setBackgroundImage(UIImage(named: "ic_play"), for: .normal)
            button.setBackgroundImage(UIImage(named: "ic_purse"), for: .selected)
            self.addSubview(button)
            button.snp.makeConstraints {
                $0.width.height.equalTo(78)
                $0.center.equalToSuperview()
                
            }
             
        })
    }
    
    func updateUI() {
        self.scrolleView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        let contentImage = self.image
        if contentImage.size.width > contentImage.size.height {
            //横图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.height / (contentImage.size.height) * (contentImage.size.width), height: scrolleView.frame.size.height)
            
        } else {
            //竖图
            contentImageView.frame = CGRect(x: 0, y: 0, width: scrolleView.frame.size.width, height: scrolleView.frame.size.width / (contentImage.size.width) * (contentImage.size.height))
        }
        self.scrolleView.contentSize = contentImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func playButtonClick(button: UIButton) {
        
        if button.isSelected {
            pauseAnimation()
            self.delegate?.pauseAnimation()
        } else {
            startAnimation()
            self.delegate?.startAnimation()
        }
        button.isSelected = !button.isSelected
    }
    
    func startAnimation() {
        self.scrolleView.contentOffset = CGPoint(x: 0, y: 0)
        UIView.animate(withDuration: TimeInterval(commentAnimationTime), animations: {
            self.scrolleView.contentOffset = CGPoint(x: self.scrolleView.contentSize.width - self.frame.size.width, y: 0)
        }) { (succeed) in
            self.layoutIfNeeded()
            self.layoutSubviews()
            self.playButton?.isSelected = false
        }
    }
    
    func pauseAnimation() {
        self.scrolleView.layer.removeAllAnimations()
        self.scrolleView.contentOffset = CGPoint(x: 0, y: 0)
        self.layoutIfNeeded()
    }
    
  
}
